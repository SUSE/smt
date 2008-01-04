package YEP::Mirror::RpmMd;
use strict;

use LWP::UserAgent;
use URI;
use XML::Parser;
use File::Path;
use Crypt::SSLeay;
use IO::Zlib;
use Time::HiRes qw(gettimeofday tv_interval);

use YEP::Mirror::Job;

BEGIN 
{
    if(exists $ENV{https_proxy})
    {
        # required for Crypt::SSLeay HTTPS Proxy support
        $ENV{HTTPS_PROXY} = $ENV{https_proxy};
    }
}

# constructor
sub new
{
    my $pkgname = shift;
    my %opt   = @_;
    
    my $self  = {};
    $self->{URI}   = undef;
    # local destination ie: /var/repo/download.suse.org/foo/10.3
    $self->{LOCALPATH}   = undef;
    $self->{JOBS}   = [];
    $self->{STATISTIC}->{DOWNLOAD} = 0;
    $self->{STATISTIC}->{UPTODATE} = 0;
    $self->{STATISTIC}->{ERROR}    = 0;
    $self->{DEBUG} = 0;
    
    # Do _NOT_ set env_proxy for LWP::UserAgent, this would break https proxy support
    $self->{USERAGENT}  = LWP::UserAgent->new(keep_alive => 1);
    if(exists $ENV{http_proxy})
    {
        $self->{USERAGENT}->proxy("http",  $ENV{http_proxy});
    }

    if(exists $opt{debug} && defined $opt{debug} && $opt{debug})
    {
        $self->{DEBUG} = 1;
    }
    

    bless($self);
    return $self;
}

# URI property
sub uri
{
    my $self = shift;
    if (@_) { $self->{URI} = shift }
    return $self->{URI};
}

# creates a path from a url
sub localUrlPath()
{
  my $self = shift;
  my $uri;
  my $repodest;

  $uri = URI->new($self->{URI});
  $repodest = join( "/", ( $uri->host, $uri->path ) );
  return $repodest;
}

# mirrors the repository to destination
sub mirrorTo()
{
    my $self = shift;
    my $dest = shift;
    my $options = shift;
  
    if ( not -e $dest )
    { die $dest . " does not exist"; }
    my $t0 = [gettimeofday] ;
    
    # extract the url components to create
    # the destination directory
    # so we save the repo to:
    # $destdir/hostname.com/path
    my $uri = URI->new($self->{URI});

    if ( $$options{ urltree } eq 1 )
    {
      $self->{LOCALPATH} = join( "/", ( $dest, $self->localUrlPath() ) );
    }
    else
    {
      $self->{LOCALPATH} = $dest;
    }
    print "Mirroring: ", $self->{URI}, "\n";
    print "Target:    ", $self->{LOCALPATH}, "\n";

    my $destfile = join( "/", ( $self->{LOCALPATH}, "repodata/repomd.xml" ) );

    # get the repository index
    my $job = YEP::Mirror::Job->new(debug => $self->{DEBUG}, UserAgent => $self->{USERAGENT});
    $job->uri( $self->{URI} );
    $job->resource( "/repodata/repomd.xml" );
    $job->localdir( $self->{LOCALPATH} );
    
    # get the file
    my $result = $job->mirror();
    if( $result == 1 )
    {
        $self->{STATISTIC}->{ERROR} += 1;
    }
    elsif( $result == 2 )
    {
        # FIXME: Question: If repomd.xml is "up to date" and the
        #                  local repo is valid, can we skip the 
        #                  rest and directly return with success?

        $self->{STATISTIC}->{UPTODATE} += 1;
    }
    else
    {
        $self->{STATISTIC}->{DOWNLOAD} += 1;
    }
    

    # parse it and find more resources
    $self->_parseXmlResource( $destfile );

    my $lastresource = "";
    foreach ( sort {$a->resource cmp $b->resource} @{$self->{JOBS}} )
    {
        # skip duplicates
        next if( $lastresource eq $_->resource() );
        $lastresource = $_->resource();
        
        my $mres = $_->mirror();
        if( $mres == 1 )
        {
            $self->{STATISTIC}->{ERROR} += 1;
        }
        elsif( $mres == 2 )
        {
            $self->{STATISTIC}->{UPTODATE} += 1;
        }
        else
        {
            $self->{STATISTIC}->{DOWNLOAD} += 1;
        }
    }

    print "=> Finished mirroring ".$self->{URI}."\n";
    print "=> Downloaded Files: ".$self->{STATISTIC}->{DOWNLOAD}."\n";
    print "=> Up to date Files: ".$self->{STATISTIC}->{UPTODATE}."\n";
    print "=> Download Errors : ".$self->{STATISTIC}->{ERROR}."\n";
    print "=> Mirror Time:      ".(tv_interval($t0))." seconds\n";
    print "\n";
}

# deletes all files not referenced in
# the rpmmd resource chain
sub clean()
{
    my $self = shift;

    # algorithm
    
}

# parses a xml resource
sub _parseXmlResource()
{
    my $self = shift;
    my $path = shift;

    my $parser = XML::Parser->new( Handlers =>
                                   { Start=> sub { handle_start_tag($self, @_) },
                                     End=>\&handle_end_tag,
                                   });
    if ( $path =~ /(.+)\.gz/ )
    {
      my $fh = IO::Zlib->new($path, "rb");
      eval {
          # using ->parse( $fh ) result in errors
          my @cont = $fh->getlines();
          $parser->parse( join("", @cont ));
      };
      if($@) {
          # ignore the errors, but print them
          chomp($@);
          print STDERR "Error: $@\n";
      }
    }
    else
    {
      eval {
          $parser->parsefile( $path );
      };
      if($@) {
          # ignore the errors, but print them
          chomp($@);
          print STDERR "Error: $@\n";
      }
    }
}

# handles XML reader start tag events
sub handle_start_tag()
{
    my $self = shift;
    my( $expat, $element, %attrs ) = @_;
    # ask the expat object about our position
    my $line = $expat->current_line;

    # we are looking for <location href="foo"/>
    if ( $element eq "location" )
    {
        # get the repository index
        my $job = YEP::Mirror::Job->new(debug => $self->{DEBUG}, UserAgent => $self->{USERAGENT});
        $job->resource( $attrs{"href"} );
        $job->localdir( $self->{LOCALPATH} );
        $job->uri( $self->{URI} );

        # if it is an xml file we have to download it now and
        # process it
        if (  $job->resource =~ /(.+)\.xml(.*)/ )
        {
          # mirror it first, so we can parse it
            my $mres = $job->mirror();
            if( $mres == 1 )
            {
                $self->{STATISTIC}->{ERROR} += 1;
            }
            elsif( $mres == 2 )
            {
                $self->{STATISTIC}->{UPTODATE} += 1;
            }
            else
            {
                $self->{STATISTIC}->{DOWNLOAD} += 1;
            }
            
            $self->_parseXmlResource( $job->local() );
        }
        else
        {
            # download it later
            push @{$self->{JOBS}}, $job;
        }
    }
}

sub handle_end_tag()
{
  my( $expat, $element, %attrs ) = @_;
}

=head1 NAME

YEP::Mirror::RpmMd - mirroring of a rpm metadata repository

=head1 SYNOPSIS

  use YEP::Mirror::RpmMd;

  $mirror = YEP::Mirror::RpmMd->new();
  $mirror->uri( "http://repo.com/10.3" );
  $mirror->mirrorTo( "/somedir", { urltree => 1 });

=head1 DESCRIPTION

Mirroring of a rpm metadata repository.

The mirror function will not download the same files twice.

In order to clean the repository, that is removing all files
which are not mentioned in the metadata, you can use the clean method:

 $mirror->clean();

=head1 METHODS

=over 4

=item new([$params])

Create a new YEP::Mirror::RpmMd object:

  my $mirror = YEP::Mirror::RpmMd->new(debug => 1);

Arguments are an anonymous hash array of parameters:

=over 4

=item debug

Set to 1 to enable debug. 

=back

=item uri()

 $mirror->uri( "http://repo.com/10.3" );

 Specify the YUM source where to mirror from.

=item mirrorTo()

 $mirror->mirrorTo( "/somedir", { urltree => 1 });

 Sepecify the target directory where to place the mirrored files.

=over 4

=item urltree

The option urltree of the mirror method controls 
how the repo is mirrored. If urltree is true, then subdirectories
with the hostname and path of the repo url are created inside the
target directory.
If urltree is false, then the repo is mirrored right below the target
directory.

=back

=back

=head1 AUTHOR

dmacvicar@suse.de

=head1 COPYRIGHT

Copyright 2007, 2008 SUSE LINUX Products GmbH, Nuernberg, Germany.


=cut


1;  # so the require or use succeeds

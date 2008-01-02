package YEP::Mirror::RpmMd;
use strict;

use LWP;
use URI;
use XML::Parser;
use File::Path;

use YEP::Mirror::Job;

#@ISA = qw(Math::BigFloat);

# constructor
sub new
{
    my $self  = {};
    $self->{URI}   = undef;
    # local destination ie: /var/repo/download.suse.org/foo/10.3
    $self->{LOCALPATH}   = undef;
    $self->{JOBS}   = [];
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
    print "Target: ", $self->{LOCALPATH}, "\n";

    my $destfile = join( "/", ( $self->{LOCALPATH}, "repodata/repomd.xml" ) );

    # get the repository index
    my $job = YEP::Mirror::Job->new();
    $job->uri( $self->{URI} );
    $job->resource( "/repodata/repomd.xml" );
    $job->localdir( $self->{LOCALPATH} );
    
    # get the file
    $job->mirror();

    # parse it and find more resources
    $self->_parseXmlResource( $destfile );

    print  "Mirroring ", $self->{URI}, "\n";
    foreach ( @{$self->{JOBS}} )
    {
      $_->print();
      $_->mirror();
    }
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
      use IO::Zlib;
      my $fh = IO::Zlib->new($path, "rb");
      eval {
          $parser->parse( $fh );
      };
      if($@) {
          # ignore the errors, but print them
          chomp($@);
          print "Error: $@\n";
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
          print "Error: $@\n";
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
        my $job = YEP::Mirror::Job->new();
        $job->resource( $attrs{"href"} );
        $job->localdir( $self->{LOCALPATH} );
        $job->uri( $self->{URI} );

        push @{$self->{JOBS}}, $job;

        # if it is an xml file we have to download it now and
        # process it
        if (  $job->resource =~ /(.+)\.xml(.*)/ )
        {
          # mirror it first, so we can parse it
          $job->mirror();
          $self->_parseXmlResource( $job->local() );
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

The option urltree of the mirror method controls 
how the repo is mirrored. If urltree is true, then subdirectories
with the hostname and path of the repo url are created inside the
target directory.
If urltree is false, then the repo is mirrored right below the target
directory.

$mirror->mirrorTo( "/somedir", { urltree => 1 });

The mirror function will not download the same files twice.

In order to clean the repository, that is removing all files
which are not mentioned in the metadata, you can use the clean method:

$mirror->clean();

=head1 CONSTRUCTION

=head2 new()

=head1 AUTHOR

dmacvicar@suse.de

=cut

1;  # so the require or use succeeds

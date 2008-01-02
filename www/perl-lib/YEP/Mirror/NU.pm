package YEP::Mirror::NU;

use strict;

use LWP;
use URI;
use XML::Parser;
use File::Path;

use YEP::Mirror::Job;
use YEP::Mirror::RpmMd;

=head1 NAME

YEP::Mirror::NU - mirroring of a Novell Update repository

=head1 SYNOPSIS

use YEP::Mirror::NU;

$mirror = YEP::Mirror::NU->new();
$mirror->uri( 'https://username:password@nu.novell.com');
$mirror->mirrorTo( "/srv/www/htdocs/");


=head1 DESCRIPTION

=head1 CONSTRUCTION

=head2 new()

=cut

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

    my $destfile = join( "/", ( $self->{LOCALPATH}, "repo/repoindex.xml" ) );

    # get the repository index
    my $job = YEP::Mirror::Job->new();
    $job->uri( $self->{URI} );
    $job->resource( "/repo/repoindex.xml" );
    $job->localdir( $self->{LOCALPATH} );
    
    # get the file
    $job->mirror();

    # parse it and find more resources
    $self->_parseXmlResource( $destfile );
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

    # we are looking for <repo .../>
    if ( $element eq "repo" )
    {
        # get the repository index
        my $mirror = YEP::Mirror::RpmMd->new();

        my $catalogURI = join("/", $self->{URI}, "/repo", $attrs{"path"});
        my $localPath = $self->{LOCALPATH}."/repo/".$attrs{"path"};

        &File::Path::mkpath( $localPath );

        $mirror->uri( $catalogURI );
        $mirror->mirrorTo( $localPath );
    }
}

sub handle_end_tag()
{
  my( $expat, $element, %attrs ) = @_;
}

1;

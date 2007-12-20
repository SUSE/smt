package YEP::Mirror::RpmMd;
use strict;

use LWP;
use URI;
use XML::Parser;
use File::Path;

use YEP::Mirror::Job;

#@ISA = qw(Math::BigFloat);

# self pointer for XML callback
my $_xmlSelf;

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

sub localRepoPath()
{
  my $self = shift;
  my $uri;
  my $repodest;

  $uri = URI->new($self->{URI});
  $repodest = join( "/", ( $self->{LOCALPATH}, $uri->host, $uri->path ) );
  return $repodest;
}

# mirrors the repository to destination
sub mirrorTo()
{
    my $self = shift;
    my $dest = shift;
  
    #URI->new($self->[$URI])

    if ( not -e $dest )
    { die $dest . " does not exist"; }

    $self->{LOCALPATH} = $dest;

    # extract the url components to create
    # the destination directory
    # so we save the repo to:
    # $destdir/hostname.com/path
    my $uri = URI->new($self->{URI});
    my $repodest = join( "/", ( $dest, $uri->host, $uri->path ) );

    my $destfile = join( "/", ( $repodest, "repodata/repomd.xml" ) );

    # get the repository index
    my $job = YEP::Mirror::Job->new();
    $job->uri( $self->{URI} );
    $job->resource( "/repodata/repomd.xml" );
    $job->local( $repodest );

    # parse it and find more resources
    $self->_parseXmlResource( $destfile );

    #print @#{$self->{JOBS}}; exit;

    foreach ( @{$self->{JOBS}} )
    {
      $_->print(); print "\n";
    }
}

# parses a xml resource
sub _parseXmlResource()
{
    #$_xmlSelf = $self;

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
      $parser->parse( $fh );
    }
    else
    {
      $parser->parsefile( $path );
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
        $job->local( $self->localRepoPath() );
        $job->uri( $self->{URI} );

        push @{$self->{JOBS}}, $job;

        # if it is an xml file we have to download it now and
        # process it
        if (  $job->resource =~ /(.+)\.xml(.+)/ )
        {
          $job->mirror();
          $self->_parseXmlResource( join( "/", ($job->local, $job->resource) ));
        }

    }
}

sub handle_end_tag()
{
  my( $expat, $element, %attrs ) = @_;
}

=head1 NAME

YYEP::Mirror::RpmMd - mirroring of a rpm metadata repository

=head1 SYNOPSIS

... todo

=head1 DESCRIPTION

=head1 CONSTRUCTION

=head2 new()

=cut

1;  # so the require or use succeeds
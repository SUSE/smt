package YEP::Mirror::Job;
use strict;

use LWP::UserAgent;
use File::Path;
use File::Basename;
use Date::Parse;

sub new
{
    my $self  = {};
    $self->{URI}        = undef;
    $self->{LOCALDIR}   = undef;
    $self->{RESOURCE}   = undef;
    $self->{CHECKSUM}   = undef;
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

# local resource container
sub localdir
{
    my $self = shift;
    if (@_) { $self->{LOCALDIR} = shift }
    return $self->{LOCALDIR};
}

# local full path
sub local
{
    my $self = shift;
    my $local = join( "/", ( $self->{LOCALDIR}, $self->{RESOURCE} ) );
    return $local;
}

# local full path
sub remote
{
    my $self = shift;
    my $remote = join( "/", ( $self->{URI}, $self->{RESOURCE} ) );
    return $remote;
}

# resource property
sub resource
{
    my $self = shift;
    if (@_) { $self->{RESOURCE} = shift }
    return $self->{RESOURCE};
}

# checksum property
sub checksum()
{
    my $self = shift;
    if (@_) { $self->{CHECKSUM} = shift }
    return $self->{CHECKSUM};
}

# mirror the resource to the local destination
sub mirror
{
    my $self = shift;

    if ( not $self->outdated() )
    {
      print "----> ", $self->{RESOURCE}, " is up to date\n";
      # no need to mirror
      return 2;
    }
    # make sure the container destination exists
    &File::Path::mkpath( dirname($self->local()) );

    my $ua = LWP::UserAgent->new;
    my $response = $ua->get( $self->remote(), ':content_file' => $self->local() );
    
    if ( $response->is_redirect )
    {
      print "Redirected", "\n";
    }

    $response->is_success or
    die "Failed to GET '$self->{RESOURCE}': ", $response->status_line;
}

# remote modification timestamp
sub modified
{
    my $self = shift;
    
    my $ua = LWP::UserAgent->new;

    my $response = $ua->head( $self->remote() );
    
    $response->is_success or
    die "Failed to GET '$self->{RESOURCE}': ", $response->status_line;

    return Date::Parse::str2time($response->header( "Last-Modified" ));
}

# true if remote is newer than local version
# or if local does not exists
sub outdated
{
  my $self = shift;

  if ( not -e $self->local() )
  {
    return 1;
  }

  open(HANDLE, $self->local());
  my $date = (stat HANDLE)[9];
  return ($date < $self->modified);
}

sub print
{
  my $self = shift;
  print "[", $self->resource(), "]\n";
}

=head1 NAME

YEP::Mirror::Job - represents a single resource mirror job

=head1 SYNOPSIS

$job = YEP::Mirror::Job->new();
$job->uri("http://foo.com/");
$job->local("/tmp");
$job->resource("/file.txt");
# when was it last time modified remotely
print $job->modified()
# is the local version outdated?
print $job->outdated()
$job->mirror();

=head1 DESCRIPTION

Represents a remote resource mirror job and provice
useful mehods to check if the resource exists local
or if it needs refresh and to transfer it.

=head1 CONSTRUCTION

=head2 new()

=head1 AUTHOR

dmacvicar@suse.de

=cut

1;  # so the require or use succeeds

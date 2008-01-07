package YEP::Mirror::Job;
use strict;

use LWP::UserAgent;
use File::Path;
use File::Basename;
use Date::Parse;
use Crypt::SSLeay;

BEGIN 
{
    if(exists $ENV{https_proxy})
    {
        # required for Crypt::SSLeay HTTPS Proxy support
        $ENV{HTTPS_PROXY} = $ENV{https_proxy};
    }
}

sub new
{
    my $pkgname = shift;
    my %opt   = @_;
    
    my $self  = {};
    $self->{URI}        = undef;
    $self->{LOCALDIR}   = undef;
    $self->{RESOURCE}   = undef;
    $self->{CHECKSUM}   = undef;
    # Do _NOT_ set env_proxy for LWP::UserAgent, this would break https proxy support
    $self->{USERAGENT}  = (defined $opt{UserAgent} && $opt{UserAgent})?$opt{UserAgent}:LWP::UserAgent->new(keep_alive => 1);
    $self->{DEBUG}      = 0;

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
      print "----> ", $self->{RESOURCE}, " is up to date\n" if($self->{DEBUG});
      # no need to mirror
      return 2;
    }
    else
    {
        if($self->{DEBUG})
        {
            print "Fetch ";
            $self->print();
        }
    }
    
    # make sure the container destination exists
    &File::Path::mkpath( dirname($self->local()) );

    my $response = $self->{USERAGENT}->get( $self->remote(), ':content_file' => $self->local() );
    
    if ( $response->is_redirect )
    {
      print "Redirected", "\n" if($self->{DEBUG});
      return 1;
    }

    if( $response->is_success )
    {
        return 0;
    }
    else
    {
        # FIXME: was 'die'; check if we should stop if a download failed
        print STDERR "Failed to GET '$self->{RESOURCE}': ".$response->status_line."\n";
        return 1;
    }
}

# remote modification timestamp
sub modified
{
    my $self = shift;
    
    my $response = $self->{USERAGENT}->head( $self->remote() );
    
    $response->is_success or do 
    {
        # FIXME: was 'die'; check if we should stop if a download failed
        print STDERR "Failed to GET '$self->{RESOURCE}': ".$response->status_line."\n";
        return undef;
    };

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

  my $date = (stat $self->local())[9];
  my $modifiedAt = $self->modified();
  
  return (!defined $modifiedAt || $date < $modifiedAt);
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

=head1 METHODS

=over 4

=item new([$params])

Create a new YEP::Mirror::Job object:

  my $mirror = YEP::Mirror::Job->new(debug => 1);

Arguments are an anonymous hash array of parameters:

=over 4

=item debug

Set to 1 to enable debug. 

=item UserAgent

LWP::UserAgent object to use for this job. Usefull for keep_alive. 

=back

=item mirror()

Returns 0 on success, 1 on error and 2 if the file is up to date

=back

=head1 AUTHOR

dmacvicar@suse.de

=head1 COPYRIGHT

Copyright 2007, 2008 SUSE LINUX Products GmbH, Nuernberg, Germany.

=cut

1;  # so the require or use succeeds

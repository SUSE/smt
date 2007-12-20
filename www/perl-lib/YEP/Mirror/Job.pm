package YEP::Mirror::Job;
use strict;

use LWP;
use LWP::Simple;
use File::Path;
use File::Basename;

sub new
{
    my $self  = {};
    $self->{URI}   = undef;
    $self->{LOCAL}   = undef;
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

# local path property
sub local
{
    my $self = shift;
    if (@_) { $self->{LOCAL} = shift }
    return $self->{LOCAL};
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
sub mirror()
{
    my $self = shift;
    my $remote = join( "/", ( $self->{URI}, $self->{RESOURCE} ) );
    my $local = join( "/", ( $self->{LOCAL}, $self->{RESOURCE} ) );
    # make sure the container destination exists
    &File::Path::mkpath( dirname($local) );

    use LWP::UserAgent;
    my $ua = LWP::UserAgent->new;
    my $response = $ua->get( $remote, ':content_file' => $local );
  
    $response->is_success or
    die "Failed to GET '$self->{RESOURCE}': ", $response->status_line;
}

# remote modification timestamp
# FIXME Do no use ::Simple here because https proxy
sub modified
{
    my $self = shift;
    my $remote = join( "/", ( $self->{URI}, $self->{RESOURCE} ) );


    my $content_type;
    my $document_length;
    my $modified_time;
    my $expires;
    my $server;

    ($content_type, $document_length, $modified_time, $expires, $server) = LWP::Simple::head($remote);

    return $modified_time;
}

sub print
{
  my $self = shift;
  my $remote = join( "/", ( $self->{URI}, $self->{RESOURCE} ) );
  print "[$remote]";
}

=head1 NAME

YEP::Mirror::Job - represents a single resource mirror job

=head1 SYNOPSIS

$job = YEP::Mirror::Job->new();
$job->uri("http://foo.com/");
$job->local("/tmp");
$job->resource("/file.txt");
print $job->modified()
$job->mirror();

=head1 DESCRIPTION

Represents a remote resource mirror job and provice
useful mehods to check if the resource exists local
or if it needs refresh and to transfer it.

=head1 CONSTRUCTION

=head2 new()

=cut

1;  # so the require or use succeeds
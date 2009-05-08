#!/usr/bin/perl -t
use strict;
use warnings;

use XML::Simple;
use UNIVERSAL 'isa';

use CGI '3.30', ();
use Scalar::Util qw/ reftype /; # reftype is better than ref sometimes
$ENV{REQUEST_METHOD} = 'GET' unless defined $ENV{REQUEST_METHOD};

my $q = CGI->new;

###############################################################################
# converts a string containing job arguments in xml format into a hash
# args:    job arguments (string)
# returns: job arguments (hash)
sub arg2hash
{
  my $xmldata = $_[0];
  my $dat = XMLin($xmldata, forcearray=>1);
  return $dat;
}

###############################################################################
# converts a job description into xml format
# args:    job id        (int)
#          job type      (string)
#          job args, xml (string)
# returns: xml job description
sub job2xml
{
  my ($jobid, $jobtype, $args) =  @_;

  my $job =
  {
   'jobtype' => $jobtype,
    'id' => $jobid,
    'arguments' =>  arg2hash( $args)

  };

  my $xmldata = XMLout($job, rootname => "job");
  return $xmldata;
}




###############################################################################
# exit with error
# args: message, jobid
sub error
{
  my ( $httpcode, $message) =  @_;

  print $q->header(-status => $httpcode, -type => 'text/plain');
  print $message;

  exit;
};


sub GET($$)
{
    my ($path, $code) = @_;
    return unless $q->request_method eq 'GET' or $q->request_method eq 'HEAD';
    return unless $q->path_info =~ $path;
    $code->();
    exit;
}

sub POST($$)
{
    my ($path, $code) = @_;
    return unless $q->request_method eq 'POST';
    return unless $q->path_info =~ $path;
    $code->();
    exit;
}

sub PUT($$)
{
    my ($path, $code) = @_;
    return unless $q->request_method eq 'PUT';
    return unless $q->path_info =~ $path;
    $code->();
    exit;
}

sub DELETE($$)
{
    my ($path, $code) = @_;
    return unless $q->request_method eq 'DELETE';
    return unless $q->path_info =~ $path;
    $code->();
    exit;
}

eval
{
    # look up next job 
    GET qr{^/=v1=/smt/job/id/next$} => sub
    {
	my $job={ id=>'48' };
	my $xmldata = XMLout( $job, rootname => "job" );
 	print $q->header( 'text/xml' );
	print $xmldata;
    };

    # look up job 
    GET qr{^/=v1=/smt/job/id/([\d-]+)$} => sub
    {

	## TODO: these values need to be collected from the database

	my $jobid = $1;
	my $jobtype = "softwarepush";
	my $jobargs =
		"<arguments>
		 <force>true</force>
		  <packages>
		   <package>xterm</package>
		   <package>yast2</package>
		   <package>firefox</package>
		  </packages>
		</arguments>";

	# let's create xml containing our data
 	print $q->header('text/xml');
	print job2xml ( $jobid, $jobtype, $jobargs );

    };

    # update job 
    POST qr{^/=v1=/smt/job/id/([\d-]+)$} => sub
    {
        my $id = $1;
	my $job;
	my $jobid;
	my $jobmessage;
	my $jobsuccess;


	if ($q->content_type ne 'text/xml') 
	{
		error( 400, "xml data expected." );                  
	}

	my $xmldata = $q->param('POSTDATA');

	eval { $job = XMLin( $xmldata,  forcearray=>1 ) };
	error( 400, "unable to parse xml: $@" )              if ( $@ );
	error( 400, "job description contains invalid xml" ) if ( ! ( isa ($job, 'HASH' )));

	$jobid   =    $job->{id}      if ( defined ( $job->{id} )      && ( $job->{id} =~ /^[0-9]+$/ ));
	$jobsuccess = $job->{success} if ( defined ( $job->{success} ) 
					  && ( $job->{success} == "true" || $job->{success} == "false" ));
	$jobmessage = $job->{message} if ( defined ( $job->{message} ) ) ;

	error( 400, "jobid unknown or invalid." )                    if ( ! defined( $jobid   ));
	error( 400, "argument success unknown or invalid.", $jobid ) if ( ! defined( $jobsuccess ));
	error( 400, "argument message unknown or invalid.", $jobid ) if ( ! defined( $jobmessage ));


	open (MYFILE, '>>/tmp/smt.txt');
	print (MYFILE "updateing $jobid...\n");
	print (MYFILE "success: $jobsuccess...\n");
	print (MYFILE "message: $jobmessage...\n");
	close (MYFILE);

	if (0)
	{
		error (400, "unable to update job");
	}

 	print $q->header('text/html');
	print "successfully updated job $id.";
    };

};

if ($@)
{

    if (ref $@ and reftype $@ eq 'HASH') {
        my $ERROR = $@;
        print $q->header( -status => $ERROR->{status}, -type => 'text/html' );
        print $q->h1( $ERROR->{title} );
        print $q->p( $ERROR->{message} ) if $ERROR->{message};
    }
    else {
        my $ERROR = $@;
        print $q->header( -status => 500, -type => 'text/html' );
        print $q->title('Server Error');
        print $q->p( $ERROR );
    }

    exit;
}

# Nothing handles this, throw back a standard 404
error ( 404, "Resource Not Found");

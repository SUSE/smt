#!/usr/bin/env perl
use strict;
use warnings;
package SMT::Agent::RestXML;
use HTTP::Request;
use HTTP::Request::Common;
use LWP::UserAgent;
use XML::Simple;
use UNIVERSAL 'isa';
use SMT::Agent::Constants;
use SMT::Agent::Config;
use SMT::Agent::Utils;



###############################################################################
# updates status of a job on the smt server
# args: jobid, success, message 
sub updatejob
{
  my ($jobid, $success, $message, $stdout, $stderr, $returnvalue) =  @_;

  SMT::Agent::Utils::logger( "updating job $jobid ($success) $message", $jobid);

  my $job =
  {
    'id' => $jobid,
    'success' =>  $success,
    'message' => $message,
    'stdout' => $stdout,
    'stderr' => $stderr,
    'returnvalue' => $returnvalue
  };
  my $xmljob = XMLout($job, rootname => "job");

  my $ua = createUserAgent();
  my $req = HTTP::Request->new( PUT => SMT::Agent::Config::smtUrl().SMT::Agent::Constants::REST_UPDATE_JOB.$jobid ,
	  'Content-Type' => 'text/xml',
          Content        => $xmljob );
  $req->header( 'If-SSL-Cert-Subject' => SMT::Agent::Constants::CERT_SUBJECT );

  my $response ;
  eval { $response = $ua->request( $req ); };
  SMT::Agent::Utils::error ( "Unable to update job : $@" )              if ( $@ );

  if (! $response->is_success )
  {
    # Do not pass the jobid to the error() because that 
    # causes an infinit recursion
    SMT::Agent::Utils::error( "Unable to update job: " . $response->status_line . "-" . $response->content );
  }
  else
  {
    SMT::Agent::Utils::logger( "successfully updated job $jobid");
  }
};


###############################################################################
# retrieve the a job from the smt server
# args: jobid
# returns: job description in xml
sub getjob
{
  my ($id) = @_;

  my $ua = createUserAgent();
  my $req = HTTP::Request->new(GET => SMT::Agent::Config::smtUrl().SMT::Agent::Constants::REST_GET_JOB.$id);
  $req->header( 'If-SSL-Cert-Subject' => SMT::Agent::Constants::CERT_SUBJECT );
  my $response ;
  eval { $response = $ua->request( $req ); };
  SMT::Agent::Utils::error ( "Unable to request job $id : $@" )              if ( $@ );

  if (! $response->is_success )
  {
    SMT::Agent::Utils::error( "Unable to request job $id: " . $response->status_line . "-" . $response->content );
  }

  return $response->content;
};


###############################################################################
# retrieve the next job from the smt server
# args: none
# returns: job description in xml
sub getnextjob
{
  my $ua = createUserAgent() ;

  my $req = HTTP::Request->new(GET => SMT::Agent::Config::smtUrl().SMT::Agent::Constants::REST_NEXT_JOB);
  $req->header( 'If-SSL-Cert-Subject' => SMT::Agent::Constants::CERT_SUBJECT );
  my $response ;
  eval { $response = $ua->request( $req ); };
  SMT::Agent::Utils::error ( "Unable to request next job : $@" )              if ( $@ );

  if (! $response->is_success )
  {
    SMT::Agent::Utils::error( "Unable to request next job: " . $response->status_line . "-" . $response->content );
  }

  return $response->content;
};



###############################################################################
# parse xml job description
# args:    xml
# returns: hash (id, type, args)
sub parsejob
{
  my $xmldata = shift;

  SMT::Agent::Utils::error( "xml doesn't contain a job description" ) if ( length( $xmldata ) <= 0 );

  my $job;
  my $jobid;
  my $jobtype;
  my $jobargs;

  # parse xml
  eval { $job = XMLin( $xmldata,  forcearray=>1 ) };
  SMT::Agent::Utils::error ( "unable to parse xml: $@" )              if ( $@ );
  SMT::Agent::Utils::error ( "job description contains invalid xml" ) if ( ! ( isa ($job, 'HASH' )));

  # retrieve variables
  $jobid   = $job->{id}        if ( defined ( $job->{id} )      && ( $job->{id} =~ /^[0-9]+$/ ));
  $jobtype = $job->{type}      if ( defined ( $job->{type} )    && ( $job->{type} =~ /^[0-9a-zA-Z.]+$/ ));
  $jobargs = $job->{arguments} if ( defined ( $job->{arguments} ));

  # check variables
  SMT::Agent::Utils::error ( "jobid unknown or invalid." )                if ( ! defined( $jobid   ));
  SMT::Agent::Utils::error ( "jobtype unknown or invalid.",      $jobid ) if ( ! defined( $jobtype ));
  SMT::Agent::Utils::error ( "jobarguments unknown or invalid.", $jobid ) if ( ! defined( $jobargs ));

  SMT::Agent::Utils::logger ( "got jobid \"$jobid\" with jobtype \"$jobtype\"", $jobid);

  return ( id=>$jobid, type=>$jobtype, args=>$jobargs );
};

###############################################################################
# parse xml job description                                                    
# args:    xml                                                                 
# returns: id                                                                  
sub parsejobid                                                                   
{                                                                              
  my $xmldata = shift;                                                         

  SMT::Agent::Utils::error ( "xml doesn't contain a job description" ) if ( length( $xmldata ) <= 0 );

  my $job;
  my $jobid;

  # parse xml
  eval { $job = XMLin( $xmldata,  forcearray=>1 ) };
  SMT::Agent::Utils::error ( "unable to parse xml: $@" )              if ( $@ );
  SMT::Agent::Utils::error ( "job description contains invalid xml" ) if ( ! ( isa ($job, 'HASH' ) ) );

  # retrieve variables
  $jobid = $job->{id} if ( defined ( $job->{id} ) && ( $job->{id} =~ /^[0-9]+$/ ) );

  return $jobid;
};



sub createUserAgent
{
    my %opts = @_;
    
    my $user = undef;
    my $pass = undef;

    my ($httpsProxy, $proxyUser) = SMT::Agent::Config::getProxySettings();
    
    if(defined $proxyUser)
    {
        ($user, $pass) = split(":", $proxyUser, 2);
    }
    
    if(defined $httpsProxy)
    {
        # required for Crypt::SSLeay HTTPS Proxy support
        $ENV{HTTPS_PROXY} = $httpsProxy;
        
        if(defined $user && defined $pass)
        {
            $ENV{HTTPS_PROXY_USERNAME} = $user;
            $ENV{HTTPS_PROXY_PASSWORD} = $pass;
        }
        elsif(exists $ENV{HTTPS_PROXY_USERNAME} && exists $ENV{HTTPS_PROXY_PASSWORD})
        {
            delete $ENV{HTTPS_PROXY_USERNAME};
            delete $ENV{HTTPS_PROXY_PASSWORD};
        }
    }

    $ENV{HTTPS_CA_DIR} = "/etc/ssl/certs/";
    
    # uncomment, if you want SSL debuging
    #$ENV{HTTPS_DEBUG} = 1;

    {
        package RequestAgent;
        @RequestAgent::ISA = qw(LWP::UserAgent);
        
        sub new
        {
            my($class, $puser, $ppass, %cnf) = @_;
            
            my $self = $class->SUPER::new(%cnf);
            
            bless {
                   puser => $puser,
                   ppass => $ppass
                  }, $class;
        }

        sub get_basic_credentials
        {
            my($self, $realm, $uri, $proxy) = @_;
            
            if($proxy)
            {
                if(defined $self->{puser} && defined $self->{ppass})
                {
                    return ($self->{puser}, $self->{ppass});
                }
            }
            return (undef, undef);
        }
    }

    my $ua = RequestAgent->new($user, $pass, %opts);

    $ua->protocols_allowed( [ 'https' ] );


    # required to workaround a bug in LWP::UserAgent
    $ua->no_proxy();

    $ua->max_redirect(2);

    # set timeout to the same value as the iChain timeout
    $ua->timeout(130);

    $ua->credentials( SMT::Agent::Constants::AUTH_NETLOC, SMT::Agent::Constants::AUTH_REALM, SMT::Agent::Config::getGuid(), SMT::Agent::Config::getSecret() );

    return $ua;
}


1;

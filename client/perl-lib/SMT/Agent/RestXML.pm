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
use XML::Writer;
use XML::Parser;

###############################################################################
# updates status of a job on the smt server
# args: jobid, status, message
sub updatejob
{
  my ($jobid, $status, $message, $stdout, $stderr, $exitcode, $result) =  @_;

  SMT::Agent::Utils::logger( "updating job $jobid ($status) message: $message", $jobid);

  # create the XML output
  my $w = undef;
  my $xmlout = '';
  # as the result section needs must be added as raw xml data, there is no other way than doing it in unsafe mode
  $w = new XML::Writer( OUTPUT => \$xmlout, DATA_MODE => 1, DATA_INDENT => 2, UNSAFE => 1 );
  SMT::Agent::Utils::error("Unable to create an answer for the current job.") unless $w;
  $w->xmlDecl( 'UTF-8' );

  $w->startTag('job', 'id'       => $jobid,
                      'guid'     => SMT::Agent::Config::getGuid() || '',
                      'status'   => $status,
                      'message'  => $message,
                      'exitcode' => $exitcode  );
  $stdout ? $w->cdataElement('stdout', $stdout ) : $w->emptyTag('stdout');
  $stderr ? $w->cdataElement('stderr', $stderr ) : $w->emptyTag('stderr');
  $w->raw($result) if ($result);
  $w->endTag('job');
  $w->end();

  # only check if well formed, meaning: no handles and no styles for parser
  my $parser =  new XML::Parser();
  SMT::Agent::Utils::error("Unable to merge job result data into an xml structure, not well-formed. Most likely a smt-client job handler is broken.", $jobid) unless $parser->parse($xmlout);

  my $ua = createUserAgent();
  my $req = HTTP::Request->new( PUT => SMT::Agent::Config::smtUrl().SMT::Agent::Constants::REST_UPDATE_JOB.$jobid );
  $req->authorization_basic(SMT::Agent::Config::getGuid(), SMT::Agent::Config::getSecret());
  $req->content_type( "text/xml" );
  $req->content( $xmlout );

  my $response ;
  eval { $response = $ua->request( $req ); };
  SMT::Agent::Utils::error( "Unable to update job : $@" ) if ( $@ );

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
  $req->authorization_basic(SMT::Agent::Config::getGuid(), SMT::Agent::Config::getSecret());
  my $response ;
  eval { $response = $ua->request( $req ); };
  SMT::Agent::Utils::error( "Unable to request job $id : $@" ) if ( $@ );

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
  $req->authorization_basic(SMT::Agent::Config::getGuid(), SMT::Agent::Config::getSecret());
  my $response ;
  eval { $response = $ua->request( $req ); };
  SMT::Agent::Utils::error( "Unable to request next job : $@" ) if ( $@ );

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
  # need to parse verbose flag as well (bnc#521952)
  my $verbose = 'false';

  # parse xml
  eval { $job = XMLin( $xmldata,  forcearray=>1 ) };
  SMT::Agent::Utils::error( "unable to parse xml: $@" ) if ( $@ );
  SMT::Agent::Utils::error( "job description contains invalid xml" ) if ( ! ( isa ($job, 'HASH' )));

  # retrieve variables
  $jobid   = $job->{id}        if ( defined ( $job->{id} )      && ( $job->{id} =~ /^[0-9]+$/ ));
  $jobtype = $job->{type}      if ( defined ( $job->{type} )    && ( $job->{type} =~ /^[0-9a-zA-Z.]+$/ ));
  $jobargs = $job->{arguments} if ( defined ( $job->{arguments} ));
  $verbose = 'true'            if ( defined $job->{verbose}  &&  ( $job->{verbose} =~ /^1$/  ||  $job->{verbose} =~ /^true$/   ));

  # check variables
  SMT::Agent::Utils::error( "jobid unknown or invalid." )                if ( ! defined( $jobid   ));
  SMT::Agent::Utils::error( "jobtype unknown or invalid.",      $jobid ) if ( ! defined( $jobtype ));
  SMT::Agent::Utils::error( "jobarguments unknown or invalid.", $jobid ) if ( ! defined( $jobargs ));

  SMT::Agent::Utils::logger( "got jobid \"$jobid\" with jobtype \"$jobtype\"", $jobid);

  return ( id=>$jobid, type=>$jobtype, args=>$jobargs, verbose=>$verbose );
};

###############################################################################
# parse xml job description
# args:    xml
# returns: id
sub parsejobid
{
  my $xmldata = shift;

  SMT::Agent::Utils::error( "xml doesn't contain a job description" ) if ( length( $xmldata ) <= 0 );

  my $job;
  my $jobid;

  # parse xml
  eval { $job = XMLin( $xmldata,  forcearray=>1 ) };
  SMT::Agent::Utils::error( "unable to parse xml: $@" )              if ( $@ );
  SMT::Agent::Utils::error( "job description contains invalid xml" ) if ( ! ( isa ($job, 'HASH' ) ) );

  # retrieve variables
  $jobid = $job->{id} if ( defined ( $job->{id} ) && ( $job->{id} =~ /^[0-9]+$/ ) );

  return $jobid;
};



sub createUserAgent
{

    my $ssl_ca_file = SMT::Agent::Config::getSysconfigValue("SSL_CA_FILE");
    $ssl_ca_file = undef if ( defined $ssl_ca_file && $ssl_ca_file eq "" );

    my $ssl_ca_path = SMT::Agent::Config::getSysconfigValue("SSL_CA_PATH");
    $ssl_ca_path = undef if ( defined $ssl_ca_path && $ssl_ca_path eq "" );

    my $ssl_cn_name = SMT::Agent::Config::getSysconfigValue("SSL_CN_NAME");
    $ssl_cn_name = undef if ( defined $ssl_cn_name && $ssl_cn_name eq "" );

    if ( defined $ssl_ca_path && defined $ssl_ca_file )
    {
      SMT::Agent::Utils::error( "Configuration is inconsistent. Don't define SSL_CA_PATH when you want to use SSL_CA_FILE."  );
    }

    use IO::Socket::SSL 'debug0';

    IO::Socket::SSL::set_ctx_defaults(
        SSL_verifycn_scheme => {
        wildcards_in_cn => 'anywhere',
        wildcards_in_alt => 'anywhere',
        check_cn => 'when_only'
        },
        SSL_verify_mode => 1,
        SSL_ca_file => $ssl_ca_file ,
        SSL_ca_path => $ssl_ca_path ,
        SSL_verifycn_name => $ssl_cn_name
    );



    # check whether smt url is allowed

    if ( SMT::Agent::Utils::isServerDenied( SMT::Agent::Config::smtUrl() ) )
    {
      SMT::Agent::Utils::error( "Configuration doesn't allow to connect to ".SMT::Agent::Config::smtUrl() );
    }



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

    # reset to default redirect limit of 7
    $ua->max_redirect(7);

    # allow redirecting of PUT and POST requests, as NCC relies on this functionality when binding an SMT server (acting as SMT client) to NCC
    $ua->requests_redirectable( ['GET', 'HEAD', 'PUT', 'POST'] );

    # adapt to new iChain timeout (as changed in SMT server lately), note: smt-client will talk to NCC as well, so the timeout needs to raise as well
    $ua->timeout(300);

    return $ua;
}


1;

#!/usr/bin/env perl
use strict;
use warnings;
package SMT::Agent::RestXML;
use HTTP::Request;
use HTTP::Request::Common;
use LWP::UserAgent;
use SMT::Agent::Constants;
use SMT::Agent::Config;
use SMT::Agent::Utils;
use XML::Writer;
use XML::Parser;
use XML::XPath;
use XML::XPath::XMLParser;

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
  eval { $parser->parse($xmlout) };
  SMT::Agent::Utils::error("Unable to merge job result data into an xml structure, not well-formed. Most likely a smt-client job handler is broken.", $jobid) if ( $@ );

  my $ua = createUserAgent();
  my $req = HTTP::Request->new( PUT => SMT::Agent::Config::smtUrl().SMT::Agent::Constants::REST_UPDATE_JOB.$jobid );
  $req->authorization_basic(SMT::Agent::Config::getGuid(), SMT::Agent::Config::getSecret());
  $req->content_type( "text/xml" );
  $req->content( $xmlout );

  my $response ;
  eval {
    local $SIG{ALRM} = sub { die "Error: Connection to server timed out.\n" };
    alarm(310);
    $response = $ua->request( $req );
    alarm(0);
  };
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
  return 1;
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
  eval {
    local $SIG{ALRM} = sub { die "Error: Connection to server timed out.\n" };
    alarm(310);
    $response = $ua->request( $req );
    alarm(0);
  };
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
  eval {
    local $SIG{ALRM} = sub { die "Error: Connection to server timed out.\n" };
    alarm(310);
    $response = $ua->request( $req );
    alarm(0);
  };
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
# returns: hash (id, type, args[XML], verbose)
sub parsejob
{
  my $xmldata = shift;

  my $xpQuery = XML::XPath->new(xml => $xmldata);
  my $jobSet;
  eval { $jobSet = $xpQuery->find('/job[@id and @type]') };
  SMT::Agent::Utils::error( "xml is not parsable" ) if ($@);
  SMT::Agent::Utils::error( "xml doesn't contain a job description" ) unless ( (defined $jobSet) && ($jobSet->size > 0) );
  my $job = $jobSet->pop();

  my $jobid   = $job->getAttribute('id');
  my $jobtype = $job->getAttribute('type');
  my $verbose = $job->getAttribute('verbose');
  $verbose = ($verbose =~ /^1$/ || $verbose =~ /^true$/) ? 1 : 0;

  my $argumentsSet;
  eval { $argumentsSet = $job->find('/job/arguments') };
  SMT::Agent::Utils::error( "xml is not parsable" ) if ($@);
  my $jobargs = ($argumentsSet->size() == 1) ? XML::XPath::XMLParser::as_string($argumentsSet->pop()) : undef;

  # check variables
  SMT::Agent::Utils::error( "jobid unknown or invalid." )                unless defined $jobid;
  SMT::Agent::Utils::error( "jobtype unknown or invalid.",      $jobid ) unless defined $jobtype;

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

  # parse xml
  my $xpQuery = XML::XPath->new(xml => $xmldata);
  my $jobSet;
  eval { $jobSet = $xpQuery->find('/job[@id]') };
  SMT::Agent::Utils::error( "xml is not parsable" ) if ($@);
  return undef unless ( (defined $jobSet) && ($jobSet->size > 0) );
  my $job = $jobSet->pop();
  my $jobid = $job->getAttribute('id');

  $jobid = undef unless ($jobid =~ /^[0-9]+$/);
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

    $ua->env_proxy();

    # reset to default redirect limit of 7
    $ua->max_redirect(7);

    # allow redirecting of PUT and POST requests, as SCC relies on this functionality when binding an SMT server (acting as SMT client) to SCC
    $ua->requests_redirectable( ['GET', 'HEAD', 'PUT', 'POST'] );

    # adapt to new iChain timeout (as changed in SMT server lately), note: smt-client will talk to SCC as well, so the timeout needs to raise as well
    $ua->timeout(300);

    return $ua;
}


1;

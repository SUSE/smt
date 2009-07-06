package SMT::RESTService;

use strict;
use warnings;

use APR::Brigade ();
use APR::Bucket ();
use APR::Const     -compile => qw(:error SUCCESS BLOCK_READ);
use constant IOBUFSIZE => 8192;
use Apache2::Filter ();

use APR::Brigade;


use Apache2::RequestRec ();
use Apache2::RequestIO ();
use Apache2::Access ();

use Apache2::Const -compile => qw(OK SERVER_ERROR HTTP_UNAUTHORIZED NOT_FOUND FORBIDDEN AUTH_REQUIRED MODE_READBYTES :log);
use Apache2::RequestUtil;


use XML::Writer;

use SMT::Utils;
use SMT::JobQueue;
use SMT::Job;
use SMT::Client;
use DBI qw(:sql_types);
use Data::Dumper;


#
# handle all GET requests
#
sub GEThandler($$)
{
    my $r = shift || return undef;
    my $dbh = shift || return undef;
    # username already checked in handler
    my $username = $r->user;

    # read smt.conf to get info about RESTAdminUser
    my $cfg = undef;
    eval {  $cfg = SMT::Utils::getSMTConfig();  };
    if ( $@ || ! defined $cfg )
    {
        $r->log_error("Cannot read the SMT configuration file: ".$@);
        return undef;
    }
    my $RR = 0;
    my $restEnable = $cfg->val('REST', 'enableRESTAdminAccess');
    if ( defined $restEnable && $restEnable =~ /^1$/ )
    {
        my $RAU = $cfg->val('REST', 'RESTAdminUser');
        $RR = ( defined $RAU  &&  $RAU eq $username ) ? 1:0;
        # password checked already in Auth handler
    }

    my $client = SMT::Client->new({ 'dbh' => $dbh });

    my $path = $r->path_info();
    # crop the prefix and trailing slash -  '/=' rest service identifier, '/1' version number
    # there is only version 1 so far
    $path =~ s/^\/(=\/)?1\///;
    $path =~ s/\/?$//;


    # jobs (per client)
    my $reJobs     = qr{^jobs(/?\@all)?$};    # get list of all MY jobs
    my $reJobsNext = qr{^jobs/\@next$};       # get MY next job
    my $reJobsId   = qr{^jobs/([\d]+)$};      # get MY next job information
    # clients
    my $reClients           = qr{^clients(/?\@all)?$};                 # get list of all clients
    my $reClientsId         = qr{^clients/([\w]+)$};                   # get client information
    # clients/jobs
    my $reClientsAllJobs    = qr{^clients/\@all/jobs(/?\@all)?$};      # get list of jobs of all clients
    my $reClientsIdJobs     = qr{^clients/([\w]+)/jobs(/?\@all)?$};    # get list of jobs of one client
    my $reClientsIdJobsNext = qr{^clients/([\w]+)/jobs/\@next$};       # get next job for one client
    my $reClientsIdJobsId   = qr{^clients/([\w]+)/jobs/(\d+)$};        # get job information of one job for one client
    # clients/patchstatus
    my $reClientsIdPatchstatus  = qr{^clients/([\d\w]+)/patchstatus$}; # get patchstatus info for one client
    my $reClientsAllPatchstatus = qr{^clients/\@all/patchstatus$};     # get patchstatus info for all clients

    # get a job request object
    my $jobq = SMT::JobQueue->new({ 'dbh' => $dbh }) || return undef;

    # jobs
    if    ( $path =~ $reJobs )      { return $jobq->getJobList( $username, 1 );   }
    elsif ( $path =~ $reJobsNext )  { return $jobq->getJob( $username, $jobq->getNextJobID($username, 0), 1)   }
    elsif ( $path =~ $reJobsId )    { return $jobq->retrieveJob( $username, $1, 1 ) }
    # clients
    elsif ( $path =~ $reClients )
    {
        return undef unless ($RR);
        return $client->getAllClientsInfoAsXML(); 
    }
    elsif ( $path =~ $reClientsId )
    {
        return undef unless ($RR);
        return $client->getClientsInfo({'GUID' => $1, 'asXML' => 'one', 'selectAll' => '' });
    }
    elsif ( $path =~ $reClientsAllJobs )
    {
        return undef unless ($RR);
        return $jobq->getAllJobsInfoAsXML();
    }
    elsif ( $path =~ $reClientsIdJobs )
    {
        return undef unless ($RR);
        return $jobq->getJobList( $1, 1 );
    }
    elsif ( $path =~ $reClientsIdJobsNext )
    {
        return undef unless ($RR);
        return $jobq->getJob( $1, $jobq->getNextJobID($1, 0), 1);
    }
    elsif ( $path =~ $reClientsIdJobsId )
    {
        return undef unless ($RR);
        return $jobq->getJob( $1, $2, 1);
    }
    elsif ( $path =~ $reClientsIdPatchstatus )
    {
        return undef unless ($RR);
        return $client->getClientsInfo( { 'GUID' => $1, 'ID' => '',
                                          'PATCHSTATUS' => '', 'asXML' => 'one' } );
    }
    elsif ( $path =~ $reClientsAllPatchstatus )
    {
        return undef unless ($RR);
        return $client->getClientsInfo( { 'GUID' => '', 'ID' => '',
                                          'PATCHSTATUS' => '', 'asXML' => '' } );
    }
    else
    {
        $r->log->error("Request to undefined REST handler ($path) with method GET");
        return undef;
    }
};


sub POSThandler($$)
{
    # DISABLE REQUEST TYPE
    return undef;

    # will be enabled when full REST support is implemented
    # then creating jobs via REST will work

    #my $r = shift;
    #return undef unless defined $r;
}



sub PUThandler($$)
{
    my $r = shift;
    my $dbh = shift || return undef;
    return undef unless defined $r;

    # username already checked in handler
    my $username = $r->user;

    my $path = $r->path_info();
    $path =~ s/^\/(=\/)?1\///;
    $path =~ s/\/?$//;

    # currently only supports job update via PUT:/job/<id>
    my $reJobsId   = qr{^jobs/([\d]+)$};

    my $jobq = SMT::JobQueue->new({ 'dbh' => $dbh });

    if ( $path =~ $reJobsId )
    {
        my $c = read_post($r);
        return $jobq->finishJob($username, $c);
    }
    else
    {
        $r->log->error("Request to undefined REST handler ($path) with method PUT.");
        return undef;
    }
}


sub DELETEhandler($$)
{
     # DISABLE REQUEST TYPE
    return undef;
    # will be enabled when full REST support is implemented
    # then deleting jobs via REST will work 

    #my $r = shift;
    #return undef unless defined $r;
}




sub handler {
    use Switch;
    my $r = shift;
    $r->log->info("REST service request");

    # try to connect to the database - else report server error
    my $dbh = undef;
    if ( ! ($dbh=SMT::Utils::db_connect()) ) 
    {
        $r->log->error("RESTService could not connect to database.");
        return Apache2::Const::SERVER_ERROR; 
    }

    my $res = undef;

    # all REST Services need authentication
    return Apache2::Const::AUTH_REQUIRED unless ( defined $r->user  &&  $r->user ne '' );

    my ($status, $password) = $r->get_basic_auth_pw;
    return $status unless $status == Apache2::Const::OK;
  

    switch( $r->method() )
    {
        case /^GET$/i     { $res = GEThandler( $r, $dbh ) }
        case /^PUT$/i     { $res = PUThandler( $r, $dbh ) }
        case /^POST$/i    { $res = POSThandler( $r, $dbh ) }
        case /^DELETE$/i  { $res = DELETEhandler( $r, $dbh ) }
        else
        {
            $r->log->error("Unknown request method in SMT rest service.");
            return Apache2::Const::NOT_FOUND
        }
    }

    if (not defined $res)
    {
        # errors are logged in method handlers
        return Apache2::Const::NOT_FOUND;
    }
    else
    {
        $r->content_type('text/xml');
        # $r->content_type('text/plain');
        $r->err_headers_out->add('Cache-Control' => "no-cache, public, must-revalidate");
        $r->err_headers_out->add('Pragma' => "no-cache");

        print $res;
    }


    # output some data for testing
    if (0) {
        my $writer = new XML::Writer(NEWLINES => 0);
        $writer->xmlDecl("UTF-8");

        $writer->startTag("jobs4smt");
        $writer->emptyTag('onejob',
                          'id'   =>  42,
                          'method'   => $r->method(),
                          'pathinfo' => $r->path_info(),
                          'unparsed_uri' => $r->unparsed_uri(),
                          'user'         => $r->user(),
                          'args'         => $r->args()
                     );
        $writer->startTag('resultdata');
        $writer->characters("$res");
        $writer->endTag('resultdata');
        $writer->endTag("jobs4smt");
        $writer->end();
    }

    return Apache2::Const::OK;
}






#
# read the content of a POST and return the data
#
sub read_post {
    my $r = shift;

    my $bb = APR::Brigade->new($r->pool,
                               $r->connection->bucket_alloc);

    my $data = '';
    my $seen_eos = 0;
    do {
        $r->input_filters->get_brigade($bb, Apache2::Const::MODE_READBYTES,
                                       APR::Const::BLOCK_READ, IOBUFSIZE);

        for (my $b = $bb->first; $b; $b = $bb->next($b)) {
            if ($b->is_eos) {
                $seen_eos++;
                last;
            }

            if ($b->read(my $buf)) {
                $data .= $buf;
            }

            $b->remove; # optimization to reuse memory
        }

    } while (!$seen_eos);

    $bb->destroy;

    $r->log->info("Got content: $data");

    return $data;
}






1;

package SMT::JobQueue;

use strict;
use warnings;

use Apache2::RequestRec ();
use Apache2::RequestIO ();

use Apache2::Const -compile => qw(OK SERVER_ERROR NOT_FOUND FORBIDDEN AUTH_REQUIRED :log);
##use Apache2::Const -compile => qw(OK SERVER_ERROR :log);
use Apache2::RequestUtil;
use XML::Writer;

use SMT::Utils;
use DBI qw(:sql_types);

#
# handle all GET requests
#
sub funcGET($)
{
    use Switch;   #need to "use" it inside each function ... grrrr
    my $r = shift;
    return undef unless defined $r;

    my $path = $r->path_info();
    # there is only version 1 so far
    $path =~ s/^\/(=\/)?1\///;  # crop the prefix:  '/=' rest service identifier, '/1' version number
    $path =~ s/\/?$//;          # crop a trailing slash

    # jobs (per client)
    my $reJobs     = qr{^jobs(/?\@all)?$};    # get list of all MY job ids
    my $reJobsNext = qr{^jobs/\@next$};       # get MY next job id
    my $reJobsId   = qr{^jobs/([\d]+)$};      # get MY next job information
    # clients
    my $reClients           = qr{^clients(/?\@all)?$};                 # get list of all client ids
    my $reClientsId         = qr{^clients/([\w]+)$};                   # get client information
    # clients/jobs
    my $reClientsAllJobs    = qr{^clients/\@all/jobs(/?\@all)?$};      # get list of jobs of all clients
    my $reClientsIdJobs     = qr{^clients/([\w]+)/jobs(/?\@all)?$};    # get list of jobs of one client
    my $reClientsIdJobsNext = qr{^clients/([\w]+)/jobs/\@next$};       # get next job id for one client
    my $reClientsIdJobsId   = qr{^clients/([\w]+)/jobs/(\d+)$};        # get job information of one job for one client
    # clients/patchstatus
    my $reClientsIdPatchstatus  = qr{^clients/([\d\w]+)/patchstatus$}; # get patchstatus info for one client
    my $reClientsAllPatchstatus = qr{^clients/\@all/patchstatus$};     # get patchstatus info for all clients

    # jobs
    if ( $path =~ $reJobs)      {  return "wanna have MY joblist"    }
    if ( $path =~ $reJobsNext ) {  return "wanna have MY next job"   }
    if ( $path =~ $reJobsId )   {  return "wanna MY job with id: $1" }

   # with "switch" the matched patterns in $1, $2 ... disappear ... grrr

   # switch ($path)
   #  {
        # clients
   #     case /$reClients/       return "wanna all clients";
   #     case /$reClientsId/     return "wanna one client with id $1";
   #     case /$reClientsIdJobs/  return "wanna all jobs of one client with id $1";
    #    else
    #    {
    #        $r->log->error("Request to undefined REST handler: $path");
    #        return undef;
    #    }
    #}

    return $path;
};


sub funcPOST($)
{
    my $r = shift;
    return unless defined $r;
    return "yepp - it is POST" if ($r->method() eq 'POST');
    return "nope - its not POST"; 
}



sub funcPUT($)
{
    my $r = shift;
    return unless defined $r;
    return "its PUT";
}


sub funcDELETE($)
{
    my $r = shift;
    return unless defined $r;
    return "its DELETE";
}




sub handler {
    use Switch;
    my $r = shift;
    $r->log->info("REST service request");

    # try to connect to the database - else report server error
    my $dbh = undef;
    if ( ! ($dbh=SMT::Utils::db_connect()) ) 
    {  
        $r->log->error("Could not connect to database.");
        return Apache2::Const::SERVER_ERROR; 
    }

    $r->content_type('text/xml');
##    $r->content_type('text/plain');
    $r->err_headers_out->add('Cache-Control' => "no-cache, public, must-revalidate");
    $r->err_headers_out->add('Pragma' => "no-cache");
 
    my $res = "foobar"; # undef;

    switch( $r->method() )
    {
        case /^GET$/i     { $res = funcGET($r) }
        case /^HEAD$/i    { $res = funcGET($r) }
        case /^PUT$/i     { $res = funcPUT($r) }
        case /^POST$/i    { $res = funcPOST($r) }
        case /^DELETE$/i  { $res = funcDELETE($r) }
        else              { return Apache2::Const::SERVER_ERROR }
    }

    if (not defined $res)
    {
         $res = "da ist was kaputt";
#        return Apache2::Const::NOT_FOUND;
    }

#    $res = '<jobs4smt>
#<onejob id="47" method="GET" pathinfo="/1/" unparsed_uri="/=/1/" user="" args=""/>
#<resultdata>yepp - it is GET</resultdata>
#</jobs4smt>';

#    print $res;

# output some data for testing
if (1) {
    my $writer = new XML::Writer(NEWLINES => 0);
    $writer->xmlDecl("UTF-8");

    $writer->startTag("jobs4smt");
    $writer->emptyTag('onejob',
                      'id'   =>  42,
                      'method'   => $r->method(),
                 # this is the path we have to parse
                      'pathinfo' => $r->path_info(),
                 # this is the full request path (including the offset)
                      'unparsed_uri' => $r->unparsed_uri(),
                      'user'         => $r->user(),
                 # we do not nee args
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
1;

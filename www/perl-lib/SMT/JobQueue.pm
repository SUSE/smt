package SMT::JobQueue;

use strict;
use warnings;

use Apache2::RequestRec ();
use Apache2::RequestIO ();

use Apache2::Const -compile => qw(OK SERVER_ERROR :log);
use Apache2::RequestUtil;
use XML::Writer;
use Switch;

use SMT::Utils;
use DBI qw(:sql_types);


sub funcGET($)
{
    my $r = shift;
    return unless defined $r;
    return "yepp - it is GET" if ($r->method() eq 'GET');
    return "nope - its not GET";
}


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
    my $r = shift;
    $r->log->info("REST service request");

    # try to connect to the database - else report server error
    my $dbh = undef;
    if ( ! ($dbh=SMT::Utils::db_connect()) ) 
    {  
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
        else           { return Apache2::Const::SERVER_ERROR }
    }


    my $writer = new XML::Writer(NEWLINES => 0);
    $writer->xmlDecl("UTF-8");

    # just some dummy XML for a quick test ...
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

#    print $res;

    return Apache2::Const::OK;
}
1;

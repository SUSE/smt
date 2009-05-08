package SMT::JobQueue;

use strict;
use warnings;

use Apache2::RequestRec ();
use Apache2::RequestIO ();

use Apache2::Const -compile => qw(OK SERVER_ERROR :log);
use Apache2::RequestUtil;
use XML::Writer;

use SMT::Utils;
use DBI qw(:sql_types);



sub handler {
    my $r = shift;
    #my $dbh = undef;
    #
    # try to connect to the database - else report server error
    #if ( ! ($dbh=SMT::Utils::db_connect()) ) 
    #{  
    #    return Apache2::Const::SERVER_ERROR; 
    #}

    
    $r->content_type('text/xml');
    $r->err_headers_out->add('Cache-Control' => "no-cache, public, must-revalidate");
    $r->err_headers_out->add('Pragma' => "no-cache");

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

    $writer->endTag("jobs4smt");

    return Apache2::Const::OK;
}
1;

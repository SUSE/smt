package SMT::RESTInfo;

use strict;
use warnings;

use Apache2::RequestRec ();
use Apache2::RequestIO ();

use Apache2::Const -compile => qw(OK SERVER_ERROR :log);
use Apache2::RequestUtil;

use XML::Writer;


sub handler {
    my $r = shift;
    $r->log->info("RESTInfo request");

    $r->content_type('text/html');
    $r->err_headers_out->add('Cache-Control' => "no-cache, public, must-revalidate");
    $r->err_headers_out->add('Pragma' => "no-cache");

    my $writer = new XML::Writer(NEWLINES => 0);
    $writer->xmlDecl("UTF-8");

    # just some dummy XML for a quick test ...
    $writer->startTag('html');
    $writer->startTag('head');
    $writer->startTag('title');
    $writer->characters('SMT REST service Information');
    $writer->endTag('title');
    $writer->endTag('head');

    $writer->startTag('body');
    $writer->startTag('h2');
    $writer->characters('SMT REST service Information');
    $writer->endTag('h2');
    $writer->startTag('p');
    $writer->characters('Find here some information about the REST service for the SMT JobQueue');
    $writer->endTag('p');
# TODO  : Write some documentation here
    $writer->endTag('body');
    $writer->endTag('html');
    $writer->end();

    return Apache2::Const::OK;
}
1;

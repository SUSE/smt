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

    $writer->startTag('html');
    $writer->startTag('head');
    $writer->startTag('title');
    $writer->characters('SMT REST Service');
    $writer->endTag('title');
    $writer->endTag('head');

    $writer->startTag('body');
    $writer->startTag('h2');
    $writer->characters('SMT REST Service');
    $writer->endTag('h2');
    $writer->startTag('p');
    $writer->characters('This is the REST service of SMT. It provides access to the SMT JobQueue for registered client machines.');
    $writer->endTag('p');
    $writer->startTag('p');
    $writer->characters('To enable administrative access to the JobQueue and SMT Client information please enable it on the SMT server.');
    $writer->endTag('p');
    $writer->endTag('body');
    $writer->endTag('html');
    $writer->end();

    return Apache2::Const::OK;
}
1;

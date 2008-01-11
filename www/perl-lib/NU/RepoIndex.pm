package NU::RepoIndex;
  
use strict;
use warnings;
  
use Apache2::RequestRec ();
use Apache2::RequestIO ();
  
use Apache2::Const -compile => qw(OK SERVER_ERROR);
use Apache2::RequestUtil;
use XML::Writer;

use YEP::Utils;
use Data::Dumper;  # for jdsn tests


sub getCatalogsByGUID($$)
{
    # first parameter:  DB handle
    # second parameter: guid
    my $dbh  = shift;
    my $guid = shift;
    return {} unless (defined $dbh && defined $guid);

    return $dbh->selectall_hashref( sprintf("select c.CATALOGID, c.NAME, c.DESCRIPTION, c.TARGET, c.LOCALPATH, c.CATALOGTYPE from Catalogs c, ProductCatalogs pc, Registration r where r.GUID=%s and r.PRODUCTID=pc.PRODUCTDATAID and c.CATALOGID=pc.CATALOGID and c.DOMIRROR like 'Y'", $dbh->quote($guid) ), "CATALOGID" );
}

sub getUsernameFromRequest($)
{
    # parameter: request handler
    my $r = shift;
    return undef unless defined $r;

    my $username = $r->user;
    return undef unless defined $username;

    return $username;
}



sub handler {
    my $r = shift;
    my $dbh = undef;

    # try to connect to the database - else report server error
    if ( not $dbh=YEP::Utils::db_connect() ) 
    {  return Apache2::Const::SERVER_ERROR; }

    $r->content_type('text/xml');
    # $r->content_type('text/plain');  # for testing

    my $username = getUsernameFromRequest($r);
    return Apache2::Const::SERVER_ERROR unless defined $username;
    my $catalogs = getCatalogsByGUID($dbh, $username);

    my $writer = new XML::Writer(NEWLINES => 0);
    $writer->xmlDecl();

    # start tag
    $writer->startTag("repoindex");

    # don't laugh, zmd requires a special look of the XML :-(
    print "\n";
    
    # create repos
    foreach my $val (values %{$catalogs})
    {
         $writer->emptyTag('repo',
                           'name' => ${$val}{'NAME'},
                           'alias' => ${$val}{'NAME'},                 # Alias == Name
                           'description' => ${$val}{'DESCRIPTION'},
                           'distro_target' => ${$val}{'TARGET'},
                           'path' => ${$val}{'LOCALPATH'},
                           'priority' => 0,                            # TODO are these parameters needed?
                           'pub' => 0                                  # TODO are these parameters needed?
                         );
         # don't laugh, zmd requires a special look of the XML :-(
         print "\n";

    }

    $writer->endTag("repoindex");

    # print Data::Dumper->Dump([$catalogs],["Catalogs: "]);
    return Apache2::Const::OK;
}
1;

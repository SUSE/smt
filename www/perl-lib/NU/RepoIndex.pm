package NU::RepoIndex;
  
use strict;
use warnings;
  
use Apache2::RequestRec ();
use Apache2::RequestIO ();
  
use Apache2::Const -compile => qw(OK SERVER_ERROR);
use Apache2::RequestUtil;
use XML::Writer;

use YEP::Utils;
#use Data::Dumper;  # for jdsn tests


sub getCatalogsByGUID($$)
{
    # first parameter:  DB handle
    # second parameter: guid
    my $dbh  = shift;
    my $guid = shift;
    return {} unless (defined $dbh && defined $guid);

    return $dbh->selectall_hashref( sprintf("select c.CatalogID, c.Name, c.Description, c.Target, c.LocalPath, c.CatalogType from Catalogs c, ProductCatalogs pc, Registration r where r.GUID=%s and r.ProductID=pc.ProductID and c.CatalogID=pc.CatalogID and c.DoMirror like 'Y'", $dbh->quote($guid) ), "CatalogID" );
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


    my $writer = new XML::Writer(NEWLINES => 1);
    $writer->xmlDecl();

    # start tag
    $writer->startTag("repoindex");

    # create repos
    foreach my $val (values %{$catalogs})
    {
         $writer->emptyTag('repo',
                           'name' => ${$val}{'Name'},
                           'alias' => ${$val}{'Name'},                 # Alias == Name
                           'description' => ${$val}{'Description'},
                           'distro_target' => ${$val}{'Target'},
                           'path' => ${$val}{'LocalPath'},
                           'priority' => 0,                            # TODO are these parameters needed?
                           'pub' => 0                                  # TODO are these parameters needed?
                         );
    }

    $writer->endTag("repoindex");

    # print Data::Dumper->Dump([$catalogs],["Catalogs: "]);
    return Apache2::Const::OK;
}
1;

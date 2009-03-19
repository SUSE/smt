package NU::RepoIndex;

use strict;
use warnings;

use Apache2::RequestRec ();
use Apache2::RequestIO ();

use Apache2::Const -compile => qw(OK SERVER_ERROR :log);
use Apache2::RequestUtil;
use XML::Writer;

use SMT::Utils;
use DBI qw(:sql_types);


sub getCatalogsByGUID($$)
{
    # first parameter:  DB handle
    # second parameter: guid
    my $dbh  = shift;
    my $guid = shift;
    return {} unless (defined $dbh && defined $guid);

    # see if the client has a target architecture
    my $targetselect = sprintf("select TARGET from Clients c where c.GUID=%s", $dbh->quote($guid));
    my $target = $dbh->selectcol_arrayref($targetselect);

    my $catalogselect = " select c.CATALOGID, c.NAME, c.DESCRIPTION, c.TARGET, c.LOCALPATH, c.CATALOGTYPE from Catalogs c, ProductCatalogs pc, Registration r ";
    $catalogselect   .= sprintf(" where r.GUID=%s ", $dbh->quote($guid));
    $catalogselect   .= " and r.PRODUCTID=pc.PRODUCTDATAID and c.CATALOGID=pc.CATALOGID and c.CATALOGTYPE='nu' and c.DOMIRROR like 'Y' ";
    # add a filter by target architecture if it is defined
    if (defined $target && defined ${$target}[0] )
    {
        $catalogselect .= sprintf(" and c.TARGET=%s", $dbh->quote( ${$target}[0] ));
    }

    return $dbh->selectall_hashref($catalogselect, "CATALOGID" );
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
    
    my $regtimestring = SMT::Utils::getDBTimestamp();

    my $LocalBasePath = "";

    $r->log->info("repoindex.xml requested");

    # try to connect to the database - else report server error
    if ( not $dbh=SMT::Utils::db_connect() ) 
    {  return Apache2::Const::SERVER_ERROR; }

    eval
    {
        my $cfg = SMT::Utils::getSMTConfig();
        $LocalBasePath = $cfg->val("LOCAL", "MirrorTo");
        if(!defined $LocalBasePath || $LocalBasePath eq "")
        {
            $LocalBasePath = "";
        }
    };
    if($@)
    {
        # for whatever reason we cannot read this
        # log the error and continue
        $r->log->error("Cannot read config file: $@");
        $LocalBasePath = "";
    }
    
    $r->content_type('text/xml');

    $r->err_headers_out->add('Cache-Control' => "no-cache, public, must-revalidate");
    $r->err_headers_out->add('Pragma' => "no-cache");

    my $username = getUsernameFromRequest($r);
    return Apache2::Const::SERVER_ERROR unless defined $username;
    my $catalogs = getCatalogsByGUID($dbh, $username);

    # see if the client uses a special namespace
    my $namespaceselect = sprintf("select NAMESPACE from Clients c where c.GUID=%s", $dbh->quote($guid));
    my $namespace = $dbh->selectcol_arrayref($namespaceselect);
    if (defined $namespace && defined ${$namespace}[0] )
    {
        $namespace = ${$namespace}[0];
    }
    else
    {
        $namespace = "";
    }
    
    eval
    {
        my $sth = $dbh->prepare("UPDATE Clients SET LASTCONTACT=? WHERE GUID=?");
        $sth->bind_param(1, $regtimestring, SQL_TIMESTAMP);
        $sth->bind_param(2, $username);
        $sth->execute;

        #$dbh->do(sprintf("UPDATE Clients SET LASTCONTACT=%s WHERE GUID=%s", $dbh->quote($regtimestring), $dbh->quote($username)));
    };
    if($@)
    {
        # we log an error, but nothing else
        $r->log_error("Update Clients table failed: ".$@);
    }

    my $writer = new XML::Writer(NEWLINES => 0);
    $writer->xmlDecl("UTF-8");

    # start tag
    $writer->startTag("repoindex");

    # don't laugh, zmd requires a special look of the XML :-(
    print "\n";

    # create repos
    foreach my $val (values %{$catalogs})
    {
        $r->log->info("repoindex return $username: ".${$val}{'NAME'}." - ".((defined ${$val}{'TARGET'})?${$val}{'TARGET'}:""));

        if(defined $LocalBasePath && $LocalBasePath ne "")
        {
            if(!-e $LocalBasePath."/$namespace/repo/".${$val}{'LOCALPATH'}."/repodata/repomd.xml")
            {
                # catalog does not exists on this server. Log it, that the admin has a chance 
                # to find the error.
                $r->log->warn("Return a catalog, which does not exists on this server (".$LocalBasePath."/$namespace/repo/".${$val}{'LOCALPATH'}.")");
                $r->log->warn("Run smt-mirror to create this catalog.");
            }
        }
        
        $writer->emptyTag('repo',
                          'name' => ${$val}{'NAME'},
                          'alias' => ${$val}{'NAME'},                 # Alias == Name
                          'description' => ${$val}{'DESCRIPTION'},
                          'distro_target' => ${$val}{'TARGET'},
                          'path' => ${$val}{'LOCALPATH'},
                          'priority' => 0,
                          'pub' => 0
                         );
        # don't laugh, zmd requires a special look of the XML :-(
        print "\n";
        
    }

    $writer->endTag("repoindex");

    return Apache2::Const::OK;
}
1;

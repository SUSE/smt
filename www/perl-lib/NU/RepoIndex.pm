package NU::RepoIndex;

use strict;
use warnings;

use Apache2::RequestRec ();
use Apache2::RequestIO ();

use Apache2::Const -compile => qw(OK SERVER_ERROR :log);
use Apache2::RequestUtil;
use XML::Writer;

use SMT::Utils;
use SMT::Repositories;
use DBI qw(:sql_types);


sub getCatalogsByGUID($$$)
{
    # 1st parameter: apache handle
    # 2nd parameter:  DB handle
    # 3rd parameter: guid

    my $r = shift;
    my $dbh  = shift;
    my $guid = shift;
    return {} unless (defined $dbh && defined $guid);

    # see if the client has a target architecture
    my $sql = sprintf("select TARGET, REGTYPE from Clients c where c.GUID=%s", $dbh->quote($guid));
    my $cnt = $dbh->selectrow_hashref($sql);

    my $catalogselect = sprintf("SELECT c.ID, c.NAME, c.DESCRIPTION, c.TARGET,
                                        c.LOCALPATH, c.CATALOGTYPE, c.STAGING,
                                        c.AUTOREFRESH, pc.OPTIONAL
                                   FROM Catalogs c, ProductCatalogs pc, Registration r
                                  WHERE r.GUID=%s
                                    AND r.PRODUCTID=pc.PRODUCTID
                                    AND c.ID=pc.CATALOGID
                                    AND c.DOMIRROR like 'Y'",
                                $dbh->quote($guid));
    # add a filter by target architecture if it is defined
    if ($cnt->{TARGET})
    {
        if ($cnt->{REGTYPE} && $cnt->{REGTYPE} eq "SC")
        {
            # REGTYPE SC get all repostypes, also zypp which has target = NULL
            $catalogselect .= sprintf(" AND (c.TARGET IS NULL OR c.TARGET=%s)", $dbh->quote( $cnt->{TARGET} ));
        }
        else
        {
            $catalogselect .= sprintf(" AND c.TARGET=%s", $dbh->quote( $cnt->{TARGET} ));
        }
    }
    if ($cnt->{REGTYPE} && $cnt->{REGTYPE} eq "SR")
    {
        # REGTYPE 'SR' only get CATALOGTYPE 'nu'
        $catalogselect .= " AND c.CATALOGTYPE='nu'";
    }

    $r->log->info("repoindex.xml STATEMENT: $catalogselect");
    return $dbh->selectall_hashref($catalogselect, "ID" );
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
    if ( ! ($dbh=SMT::Utils::db_connect()) )
    {
        return Apache2::Const::SERVER_ERROR;
    }

    my $aliasChange = 0;
    my $mirroruser = undef;
    eval
    {
        my $cfg = SMT::Utils::getSMTConfig();
        $LocalBasePath = $cfg->val("LOCAL", "MirrorTo");
        if(!defined $LocalBasePath || $LocalBasePath eq "")
        {
            $LocalBasePath = "";
        }

        $aliasChange = $cfg->val('NU', 'changeAlias');
        if(defined $aliasChange && $aliasChange eq "true")
        {
            $aliasChange = 1;
        }
        else
        {
            $aliasChange = 0;
        }

        $mirroruser = $cfg->val('LOCAL', 'mirrorUser', '');
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

    my $catalogs;
    my $namespace = "";
    # FATE #310105: return all repositories for the mirrorUser
    if ($mirroruser && $username eq $mirroruser)
    {
        my $rh = SMT::Repositories::new($dbh);
        # we do not filter, because we also want to return
        # earlier mirrored repos which are now disabled for mirroring
        $catalogs = $rh->getAllRepositories();
    }
    # for other users, return only relevant repos
    else
    {
        $catalogs = getCatalogsByGUID($r, $dbh, $username);

        # see if the client uses a special namespace
        my $namespaceselect = sprintf("select NAMESPACE from Clients c where c.GUID=%s", $dbh->quote($username));
        $namespace = $dbh->selectcol_arrayref($namespaceselect);
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
        my $LocalRepoPath = ${$val}{'LOCALPATH'};
        my $catalogName = ${$val}{'NAME'};

        if($namespace ne "" && uc(${$val}{'STAGING'}) eq "Y")
        {
            $LocalRepoPath = "$namespace/$LocalRepoPath";
            $catalogName = "$catalogName:$namespace" if($aliasChange);
        }
        elsif($mirroruser && $mirroruser eq $r->user && uc(${$val}{'STAGING'}) eq "Y")
        {
            # for mirror credentials always return full repos
            # if staging is enabled switch to full
            $LocalRepoPath = "full/$LocalRepoPath";
            $catalogName = "$catalogName:full" if($aliasChange);
        }

        $r->log->info("repoindex return $username: ".${$val}{'NAME'}." - ".((defined ${$val}{'TARGET'})?${$val}{'TARGET'}:""));

        if(defined $LocalBasePath && $LocalBasePath ne "")
        {
            if(!-e "$LocalBasePath/repo/$LocalRepoPath/repodata/repomd.xml")
            {
                next if ($mirroruser && $mirroruser eq $r->user);

                # catalog does not exists on this server. Log it, that the admin has a chance
                # to find the error.
                $r->log->warn("Return a catalog, which does not exists on this server ($LocalBasePath/repo/$LocalRepoPath/repodata/repomd.xml");
                $r->log->warn("Run smt-mirror to create this catalog.");
            }
        }

        my $autorefresh = 1;
        if(exists $val->{AUTOREFRESH} && $val->{AUTOREFRESH} eq 'N')
        {
            $autorefresh = 0;
        }

        my $enabled = 0;
        if(exists $val->{OPTIONAL} && $val->{OPTIONAL} eq 'N')
        {
            $enabled = 1;
        }

        $writer->emptyTag('repo',
                          'name' => $catalogName,
                          'alias' => $catalogName,                 # Alias == Name
                          'description' => ${$val}{'DESCRIPTION'},
                          'distro_target' => ${$val}{'TARGET'},
                          'path' => $LocalRepoPath,
                          'priority' => 0,
                          'pub' => 0,
                          'autorefresh' => $autorefresh,
                          'enabled' => $enabled
                         );
        # don't laugh, zmd requires a special look of the XML :-(
        print "\n";

    }

    $writer->endTag("repoindex");

    return Apache2::Const::OK;
}
1;

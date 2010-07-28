package NU::RepoIndex;

use strict;
use warnings;

use Apache2::RequestRec ();
use Apache2::RequestIO ();

use Apache2::Const -compile => qw(OK SERVER_ERROR :log);
use Apache2::RequestUtil;
use Log::Log4perl qw(get_logger :levels);
use XML::Writer;
use SMT::Utils;
use SMT::Repositories;
use DBI qw(:sql_types);

use Data::Dumper;

sub getCatalogsByGUID($$)
{
    # first parameter:  DB handle
    # second parameter: guid
    my $dbh  = shift;
    my $guid = shift;
    return {} unless (defined $dbh && defined $guid);
    my $log = get_logger();
    
    # see if the client has a target architecture
    my $targetselect = sprintf("select TARGET from Clients c where c.GUID=%s", $dbh->quote($guid));
    $log->debug("STATEMENT: $targetselect");
    my $target = $dbh->selectcol_arrayref($targetselect);

    $target = $target->[0] if($target->[0]);
    
    my $statement = sprintf("SELECT PRODUCTID from Registration WHERE GUID=%s",$dbh->quote($guid));
    $log->debug("STATEMENT: $statement");
    my $pidarr = $dbh->selectcol_arrayref($statement);
    
    my $catalogs = SMT::Utils::findCatalogs( $dbh, $target, $pidarr,
                                             SMT::Utils::getGroupIDforGUID($dbh, $guid));
    return $catalogs;
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
    my $log = get_logger();
    
    my $regtimestring = SMT::Utils::getDBTimestamp();

    my $LocalBasePath = "";

    $log->debug("repoindex.xml requested");

    # try to connect to the database - else report server error
    if ( ! ($dbh=SMT::Utils::db_connect()) ) 
    {
      $log->error("Cannot access the database");
      return Apache2::Const::SERVER_ERROR;
    }

    my $aliasChange = 0;
    my $mirroruser = undef;
    eval
    {
        my $cfg = SMT::Utils::getSMTConfig();
        $LocalBasePath = $cfg->val("LOCAL", "MirrorTo", "/srv/www/htdocs");
        
        $aliasChange = $cfg->val('NU', 'changeAlias');
        if(defined $aliasChange && $aliasChange eq "true")
        {
            $aliasChange = 1;
        }
        else
        {
            $aliasChange = 0;
        }
        
        $mirroruser = $cfg->val('LOCAL', 'mirrorUser');
    };
    if($@)
    {
        # for whatever reason we cannot read this
        # log the error and continue
        $log->error("Cannot read config file: $@");
        $LocalBasePath = "/srv/www/htdocs";
    }
    
    $r->content_type('text/xml');

    $r->err_headers_out->add('Cache-Control' => "no-cache, public, must-revalidate");
    $r->err_headers_out->add('Pragma' => "no-cache");

    my $username = getUsernameFromRequest($r);
    return Apache2::Const::SERVER_ERROR unless defined $username;
    
    my $catalogs;
    # FATE #310105: return all repositories for the mirrorUser
    if ($mirroruser && $username eq $mirroruser)
    {
        my $rh = SMT::Repositories::new($dbh);
        $catalogs = $rh->getAllRepositories(); 
    }
    # for other users, return only relevant repos
    else
    {
        $catalogs = getCatalogsByGUID($dbh, $username);
    }

    # see if the client uses a special namespace
    my $namespaceselect = sprintf("select NAMESPACE from Clients c where c.GUID=%s", $dbh->quote($username));
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
    };
    if($@)
    {
        # we log a warning, but nothing else
        $log->warn("Update Clients table failed: ".$@);
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
        $log->info("repoindex return $username: ".${$val}{'NAME'}." - ".((defined ${$val}{'TARGET'})?${$val}{'TARGET'}:""));
        
        $writer->emptyTag('repo',
                          'name' => $catalogName,
                          'alias' => $catalogName,                 # Alias == Name
                          'description' => ${$val}{'DESCRIPTION'},
                          'distro_target' => ${$val}{'TARGET'},
                          'path' => $LocalRepoPath,
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

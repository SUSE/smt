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
use SMT::DB;


sub getReposByGUID($$$)
{
    # 1st parameter: apache handle
    # 2nd parameter:  DB handle
    # 3rd parameter: guid

    my $r = shift;
    my $dbh  = shift;
    my $guid = shift;
    return {} unless (defined $dbh && defined $guid);

    my $sth = $dbh->prepare("SELECT repository_id AS id,
                                    repository_name AS name,
                                    repository_description AS description,
                                    repository_target AS target,
                                    localpath,
                                    repotype,
                                    autorefresh,
                                    optional,
                                    regtype,
                                    client_target
                               FROM ClientRepositories
                              WHERE guid = :guid
                                AND domirror = 'Y'");

    $sth->execute_h(guid => $guid);
    my $ref = $sth->fetchall_hashref("id");
    foreach my $id (keys %{$ref})
    {
        if ($ref->{$id}->{regtype} eq "SC")
        {
            if ($ref->{$id}->{client_target} &&
                $ref->{$id}->{target} &&
                $ref->{$id}->{target} ne $ref->{$id}->{client_target})
            {
                # skip
                delete $ref->{$id};
            }
        }
        else
        {
            if ($ref->{$id}->{target} ne $ref->{$id}->{client_target} ||
                $ref->{$id}->{repotype} ne 'nu')
            {
                # skip
                delete $ref->{$id};
            }
        }
    }
    return $ref;
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
        $r->log->error("Cannot connect to database");
        return Apache2::Const::SERVER_ERROR;
    }

    my $mirroruser = undef;
    eval
    {
        my $cfg = SMT::Utils::getSMTConfig();
        $LocalBasePath = $cfg->val("LOCAL", "MirrorTo");
        if(!defined $LocalBasePath || $LocalBasePath eq "")
        {
            $LocalBasePath = "";
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

    my $repos;
    my $namespace = "";
    # FATE #310105: return all repositories for the mirrorUser
    if ($mirroruser && $username eq $mirroruser)
    {
        my $rh = SMT::Repositories::new($dbh);
        # we do not filter, because we also want to return
        # earlier mirrored repos which are now disabled for mirroring
        $repos = $rh->getAllRepositories();
    }
    # for other users, return only relevant repos
    else
    {
        $repos = getReposByGUID($r, $dbh, $username);

        eval
        {
            my $sth = $dbh->prepare("UPDATE Clients SET lastcontact = CURRENT_TIMESTAMP WHERE guid = :guid");
            $sth->execute_h(guid => $username);
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
    foreach my $val (values %{$repos})
    {
        my $LocalRepoPath = ${$val}{'localpath'};
        my $repoName = ${$val}{'name'};

        $r->log->info("repoindex return $username: $repoName - ".((${$val}{'target'})?${$val}{'target'}:""));

        if(defined $LocalBasePath && $LocalBasePath ne "")
        {
            if(!-e "$LocalBasePath/repo/$LocalRepoPath/repodata/repomd.xml")
            {
                next if ($mirroruser && $mirroruser eq $r->user);

                # catalog does not exists on this server. Log it, that the admin has a chance
                # to find the error.
                $r->log->warn("Return a repo, which does not exists on this server ($LocalBasePath/repo/$LocalRepoPath/repodata/repomd.xml");
                $r->log->warn("Run smt-mirror to create this repository.");
            }
        }

        my $autorefresh = 1;
        if(exists $val->{autorefresh} && $val->{autorefresh} eq 'N')
        {
            $autorefresh = 0;
        }

        my $enabled = 0;
        if(exists $val->{optional} && $val->{optional} eq 'N')
        {
            $enabled = 1;
        }

        $writer->emptyTag('repo',
                          'name' => $repoName,
                          'alias' => $repoName,                 # Alias == Name
                          'description' => ${$val}{'description'},
                          'distro_target' => ${$val}{'target'},
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
    $dbh->commit();
    $dbh->disconnect();
    return Apache2::Const::OK;
}
1;

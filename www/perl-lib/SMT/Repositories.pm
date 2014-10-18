# SMT::Repositories
package SMT::Repositories;

use strict;
use warnings;
use XML::Simple;
use SMT::DB;
use Date::Parse;

use SMT::Utils;
use SMT::Mirror::Utils;

use Config::IniFiles;

# TODO seems we have a mess in logging and error reporting:
# we should use
# - newErrorMessage() to set __(translated) message to show to user
#   * does this module have anything interesting to say to the user?
# - printLog to print and/or log untranslated message
#   * or even better, we should not print anything in this module
#     (use printLog with doprint = 0 parameter), the front-end code (UI) should
#   * OR the verbosity level should be adjustable in new() and proper level
#     should be used

=head1 NAME

SMT::Repositories - reads SMT repositories and returns their states

TODO: move to SMT::DB::Repos (Repositories DB table accessor module), except the
functions where written otherwise.

=head1 SYNOPSIS

 # Constructor
 # DB connection is required
 my $repos = SMT::Repositories::new ($dbh)

 # Returns all repositories matching the filter
 # Filter can be empty (in that case the repository data is cached and reused
 # in other functions. Reload by calling the following method again).
 my $filter = {
   SMT::Repositories::MIRRORABLE => SMT::Repositories::MIRRORABLE_TRUE,
 };
 my $filtered_rs = $repos->getAllRepositories ($filter);

 # Returns local path to a repository
 # (relative to the current SMT mirroring base-path)
 my $repository_id = '6df36d5532f9a85b362a93a55f8452c6adb72165';
 my $path = $repos->getRepositoryPath ($repository_id);

=head1 DESCRIPTION

TODO

=head1 CONSTANTS

=over 4

=item SQL Table Cells

MIRRORABLE
    Defines whether repository can be mirrored

MIRRORABLE_TRUE
    Flag saying: repository can be mirrored

MIRRORABLE_FALSE
    Flag saying: repository can't be mirrored

MIRRORING
    Defines whether repository is being mirrored

MIRRORING_TRUE
    Flag saying: repository is being mirrored

MIRRORING_FALSE
    Flag saying: repository is not being mirrored

STAGING
    Defines whether repository has Staging feature enabled

STAGING_TRUE
    Flag saying: repository has staging feature enabled

STAGING_FALSE
    Flag saying: repository has not staging feature enabled

REPOSITORYID
    Defines ID to match a repository

REPOSITORIES
    Table containing repositories

=back

=cut

use constant {
    # Repository can be mirrored
    MIRRORABLE		=> 'mirrorable',
    MIRRORABLE_TRUE	=> 'Y',
    MIRRORABLE_FALSE	=> 'N',

    # Repository is being mirrored
    MIRRORING		=> 'domirror',
    MIRRORING_TRUE	=> 'Y',
    MIRRORING_FALSE	=> 'N',

    LAST_MIRROR         => 'last_mirror',

    NAME                => 'name',
    TARGET              => 'target',

    REPOSITORYID	=> 'id',
    REPOSITORIES	=> 'Repositories',

    VBLEVEL		=> LOG_ERROR|LOG_WARN|LOG_INFO1|LOG_INFO2|LOG_DEBUG|LOG_DEBUG2,
};

=head1 METHODS

=over 4

=item new ($dbh[, $log])

Constructor. Log object parameter is optional.

 my $log = SMT::Utils::openLog ($logfile);
 my $repo = SMT::Repositories ($dbh, $log);

=cut

sub new
{
    my $dbh = shift;
    my $log = shift;

    my $new =
    {
	'dbh' => $dbh,
	'error_message' => '',
        REPOS => undef,
        GOTALLREPOS => 0
    };

    if (defined $log)
    {
	$new->{LOG} = $log;
    }

    # Checking the params
    if (! defined $new->{dbh} && defined $log)
    {
	SMT::Utils::printLog($new->{LOG}, VBLEVEL, LOG_ERROR, __("Parameter 'dbh' is required"))
    }

    bless $new;
    return $new;
}

=item newErrorMessage($message)

Sets $message as the last error message. Call getAndClearErrorMessage()
to retrieve.

=cut
sub newErrorMessage ($$) {
    my $self = shift;
    my $new_error = shift || '';

    $self->{'error_message'} .= $new_error."\n";
}

=item getAndClearErrorMessage()

Returns the last error message and clears it.

=cut
sub getAndClearErrorMessage () {
    my $self = shift;

    my $ret = $self->{'error_message'} || '';
    $self->{'error_message'} = '';

    return $ret;
}

=item getAllRepositories

Returns hash filled up with description of repositories matching the filter
given as a parameter. If not filter is given, all repositories are returned.
The hash has repository IDs as keys and hashes of repository data as values.

If no filter is used, all repositories are returned and cached. Any subsequent
calls to getRepository*() functions then reuse the cached data without
accessing the database until getAllRepositories() with filters is called.

Examples:

 # Returns list of all repositories than can be mirrored
 $repo->getAllRepositories ({
     SMT::Repositories::MIRRORABLE => SMT::Repositories::MIRRORABLE_TRUE,
 });

 # Returns list of all repositories that are being mirrored
 # and have Staging feature enabled.
 $repo->getAllRepositories ({
     SMT::Repositories::MIRRORING => SMT::Repositories::MIRRORING_TRUE,
     SMT::Repositories::STAGING => SMT::Repositories::STAGING_TRUE,
 });

=cut

sub getAllRepositories ($$) {
    my $self = shift;
    my $filter = shift || {};

    $self->{REPOS} = undef;
    $self->{GOTALLREPOS} = 0;

    my $sql_filter = '';

    # Constructing the 'WHERE' part of the SQL query
    foreach my $filter_key (keys %{$filter}) {
	$sql_filter .=
	    (length ($sql_filter) > 0 ? ' AND ':'').
	    $filter_key.'='.$self->{'dbh'}->quote($filter->{$filter_key});
    }

    my $sth = $self->{'dbh'}->prepare ('SELECT * FROM Repositories'.
	# Use the 'WHERE' part if defined
	(length ($sql_filter) > 0 ? ' WHERE '.$sql_filter : '') .
        # always order by name and target
	' ORDER BY name, target'
    );

    $sth->execute();

    my $ret = {};
    my $row = {};

    my $rownr = 1;
    while ($row = $sth->fetchrow_hashref())
    {
	$row->{'target'} = '' if (not defined $row->{'target'});
	$row->{'last_mirror'} = '' if (not defined $row->{'last_mirror'});
	$row->{rownr} = $rownr;
	$ret->{$row->{'id'}} = $row;
	$rownr++;
    }

    $self->{REPOS} = $ret;
    $self->{GOTALLREPOS} = 1 if (not %$filter);

    return $ret;
}

=item getAllRepository

Returns a hash of repository data for given repository ID. The hash keys
correspond to Repositories database table.

=cut
sub getRepository($$)
{
    my $self = shift;

    my $repository = shift || do {
        $self->newErrorMessage ("RepositoryID must be defined");
        return undef;
    };

    my $repo;
    if ($self->{GOTALLREPOS})
    {
        $repo = $self->{REPOS}->{$repository} || undef;
    }
    else
    {
        # Matches just one repository
        my $repos = $self->getAllRepositories({SMT::Repositories::REPOSITORYID => $repository});
        $repo = $repos->{$repository} || undef;
    }

    if (not defined $repo)
    {
        $self->newErrorMessage ("Repository with ID '$repository' not found.");
    }

    return $repo;
}

=item getRepositoryPath($repoid)

Returns relative path of given repository (ID). The path is relative to the
directory given in the LOCAL.MirrorTo option in smt.conf.

 $repo->getRepositoryPath ('262c8b023a6802b1b753868776a80aec2d08e85b')
     -> '$RCE/SLE11-SDK-Updates/sle-11-x86_64'

=cut

sub getRepositoryPath ($$) {
    my $self = shift;
    my $repository = shift;

    my $repo = $self->getRepository($repository);
    return undef if (not defined $repo);

    my $repo_local_path = '';
    if (defined $repo->{'localpath'}) {
	$repo_local_path = $repo->{'localpath'};
    } else {
	$self->newErrorMessage ("Repository ".$repository." matches but no 'LOCALPATH' is defined");
	return undef;
    }

    return $repo_local_path;
}

=item getRepositoryUrl($repoid)

Returns source URL of given repository (ID).

 $repo->getRepositoryPath ('262c8b023a6802b1b753868776a80aec2d08e85b')
     -> 'http://download.opensuse.org/update/11.1'

=cut

sub getRepositoryUrl ($$) {
    my $self = shift;
    my $repository = shift;

    my $repo = $self->getRepository($repository);
    return undef if (not defined $repo);

    my $repo_url = '';
    if (defined $repo->{'exturl'}) {
        $repo_url = $repo->{'exturl'};
    } else {
        $self->newErrorMessage ("Repository ".$repository." matches but no 'EXTURL' is defined");
        return undef;
    }

    return $repo_url;
}

=item updateLastMirror($repoid)

Updates the time of last mirroring in the database. Returns 0 on failure and 1
on success.

 $success = updateLastMirror('86fed7f9cee6d69dddabd721436faa7c63b8b403');

=cut

sub updateLastMirror ($$)
{
    my $self = shift;
    my $repositoryid = shift;

    if (not defined $repositoryid || !$repositoryid)
    {
	SMT::Utils::printLog($self->{LOG}, VBLEVEL, LOG_ERROR, __("Parameter 'repositoryid' is required"))
	    if (defined $self->{LOG});
	return 0;
    };

    $self->{'dbh'}->do('UPDATE Repositories set last_mirror=CURRENT_TIMESTAMP where id='.$self->{'dbh'}->quote($repositoryid));
    $self->{'dbh'}->commit();
    return 1;
}


=item changeRepoStatus ($arg)

Adjusts repository status, such as 'mirroring'.

 $repohandler = SMT::Repositories::new($dbh);
 $repoid = '86fed7f9cee6d69dddabd721436faa7c63b8b403';
 $repohandler->changeRepoStatus({ 'repositoryid' => $repoid, 'mirroring' => 1 })

=over

=item Required parameters:

repositoryid
 Identifies a repository

=item Optional parameters:

mirroring
 Defines whether a repository should be mirrored

=back

=cut

sub changeRepoStatus ($$)
{
    my $self = shift;
    my $arg = shift || {};

    if (! defined $arg->{'repositoryid'})
    {
	SMT::Utils::printLog($self->{LOG}, VBLEVEL, LOG_ERROR,
	    __("Parameter 'repositoryid' is required"));
	return 0;
    }

    if (! defined $arg->{'mirroring'})
    {
	SMT::Utils::printLog($self->{LOG}, VBLEVEL, LOG_WARN,
	    __("'mirroring' parameter is not defined"));
	return 1;
    }

    my $update_columns = '';
    my $where_plus = '';

    # 'mirroring' parameter
    if (defined $arg->{'mirroring'}) {
	$update_columns .= ' '.MIRRORING.'='.$self->{'dbh'}->quote($arg->{'mirroring'} ?
	    MIRRORING_TRUE:MIRRORING_FALSE);
	# only mirrorable repositories can be mirrored
	$where_plus .= ' AND '.MIRRORABLE.'='.$self->{'dbh'}->quote(MIRRORABLE_TRUE);
    }

    my $cmd = 'UPDATE '.REPOSITORIES.' '.
	'SET '.$update_columns.' '.
	'WHERE '.REPOSITORYID.'='.$self->{'dbh'}->quote($arg->{'repositoryid'}).' '.
	$where_plus;

    my $sth = $self->{'dbh'}->prepare($cmd);
    $sth->execute();
    $self->{'dbh'}->commit();

    return ($sth->rows() > 0);
}

=item getAllReposAsXML($dbh)
Returns XML for /repos REST GET request.
=cut

sub getAllReposAsXML
{
    my $dbh = shift;

    my $sql = 'select * from Repositories';
    my $sth = $dbh->prepare($sql);
    $sth->execute();

    my $data = { repo => []};
    while (my $p = $sth->fetchrow_hashref())
    {
        # <repo id="%s" name="%s" target"%s" mirrored="%s"/>
        push @{$data->{repo}}, {
            id => $p->{id},
            name => $p->{name},
            target => $p->{target},
            mirrored => str2time($p->{last_mirror})
            };
    }
    return XMLout($data,
        rootname => 'repos',
        xmldecl => '<?xml version="1.0" encoding="UTF-8" ?>');
}


=item getProductReposAsXML($dbh, $productid)
Returns XML for /products/$productid/repos REST GET request.
=cut

sub getProductReposAsXML
{
    my ($dbh, $productid) = @_;

    my $sth = $dbh->prepare('SELECT r.*, pr.optional
                               FROM Repositories r
                               JOIN ProductRepositories pr ON r.id = pr.repository_id
                              WHERE pr.product_id = :pid');
    $sth->execute_h(pid => $productid);

    my $data = { repo => []};
    while (my $p = $sth->fetchrow_hashref())
    {
        # <repo id="%s" name="%s" target"%s" mirrored="%s" optional="%s"/>
        push @{$data->{repo}}, {
            id => $p->{id},
            name => $p->{name},
            target => $p->{target},
            mirrored => str2time($p->{last_mirror}),
            optional => $p->{optional}
        };
    }
    return XMLout($data,
        rootname => 'repos',
        xmldecl => '<?xml version="1.0" encoding="UTF-8" ?>');
}


=item getRepositoryAsXML($dbh, $repoid)
Returns XML for /repos REST GET request.
=cut

sub getRepositoryAsXML
{
    my ($dbh, $repoid) = @_;

    my $sth = $dbh->prepare('SELECT * FROM Repositories WHERE id = :rid;');
    $sth->execute_h(rid => $repoid);

    my $r = $sth->fetchrow_hashref();
    return undef if (not $r);

    # read smt.conf to get info base MirrorTo path
    my $localpath = SMT::Utils::cleanPath('/srv/www/htdocs/repo/', $r->{localpath});
    eval
    {
        my $cfg = SMT::Utils::getSMTConfig();

        # can't use getFullRepoPath() 'cause that would load all repos needlessly
        $localpath = SMT::Utils::cleanPath(
            $cfg->val('LOCAL', 'MirrorTo', '/srv/www/htdocs'),
            'repo',
            $r->{localpath});
    };
    # don't have access to logger here
    #log_error("Cannot read the SMT configuration file: ".$@)
    #    if ( $@ || ! defined $cfg );

    #<repo name="SLES11-SP1-Updates" target="sle-11-x86_64" type="nu">
    #  <description>SLES11-SP1-Updates for sle-11-x86_64</description>
    #  <url>https://nu.novell.com/repo/$RCE/SLES11-SP1-Updates/sle-11-x86_64/</url>
    #  <localpath>/srv/www/smt/repos/$RCE/SLES11-SP1-Updates/sle-11-x86_64</localpath>
    #  <mirrored date="1271723799"/>
    #</repo>

    my $xdata = {
        id => $r->{id},
        name => $r->{name},
        target => $r->{target},
        type => $r->{repotype},
        description => [$r->{description}],
        url => [$r->{exturl}],
        mirrored => [{date => str2time($r->{last_mirror})}],
        localpath => [ $localpath ]
    };
    return XMLout($xdata,
        rootname => 'repo',
        xmldecl => '<?xml version="1.0" encoding="UTF-8" ?>');
}

=back

=head1 NOTES

=head1 AUTHOR

locilka@suse.cz, jkupec@suse.cz

=head1 COPYRIGHT

Copyright 2009-2012 SUSE LINUX Products GmbH, Nuernberg, Germany.

=cut

1;

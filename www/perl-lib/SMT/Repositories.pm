# SMT::Repositories AKA SMT::Catalogs
package SMT::Repositories;

use strict;
use warnings;

use SMT::Utils;
use SMT::Mirror::Utils;

=head1 NAME

SMT::Repositories - reads SMT repositories and returns their states

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
    MIRRORABLE		=> 'MIRRORABLE',
    MIRRORABLE_TRUE	=> 'Y',
    MIRRORABLE_FALSE	=> 'N',

    # Repository is being mirrored
    MIRRORING		=> 'DOMIRROR',
    MIRRORING_TRUE	=> 'Y',
    MIRRORING_FALSE	=> 'N',

    # Repository has Staging feature enabled
    STAGING		=> 'STAGING',
    STAGING_TRUE	=> 'Y',
    STAGING_FALSE	=> 'N',

    REPOSITORYID	=> 'CATALOGID',
    REPOSITORIES	=> 'Catalogs',

    VBLEVEL		=> LOG_ERROR|LOG_WARN|LOG_INFO1|LOG_INFO2,
};

=head1 METHODS 

=over 4

=item new ($dbh, $logfile)

Constructor. Logfile parameter is optional.

 my $repo = SMT::Repositories ($dbh, $logfile);

=cut

sub new ($)
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
	$new->{LOG} = SMT::Utils::openLog ($log);
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

    my $sth = $self->{'dbh'}->prepare ('SELECT * FROM Catalogs'.
	# Use the 'WHERE' part if defined
	(length ($sql_filter) > 0 ? ' WHERE '.$sql_filter:'')
    );
    $sth->execute();

    my $ret = {};
    my $row = {};

    while ($row = $sth->fetchrow_hashref()) {
	$row->{'TARGET'} = '' if (not defined $row->{'TARGET'});
	$row->{'LAST_MIRROR'} = '' if (not defined $row->{'LAST_MIRROR'});
	$ret->{$row->{'CATALOGID'}} = $row;
    }

    $self->{REPOS} = $ret;
    $self->{GOTALLREPOS} = 1 if (not %$filter);

    return $ret;
}

=item getAllRepositories

Returns a hash of repository data for given repository ID. The hash keys
correspond to Catalogs database table. 

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
    if (defined $repo->{'LOCALPATH'}) {
	$repo_local_path = $repo->{'LOCALPATH'};
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
    if (defined $repo->{'EXTURL'}) {
        $repo_url = $repo->{'EXTURL'};
    } else {
        $self->newErrorMessage ("Repository ".$repository." matches but no 'EXTURL' is defined");
        return undef;
    }

    return $repo_url;
}

=item stagingAllowed($repositoryid, $basepath)

Whether staging/filtering can be enabled for given repository.

=cut
sub stagingAllowed($$$)
{
    my ($self, $repository, $basepath) = @_;
    
    if (not defined $repository || not $repository || not defined $basepath || not $basepath)
    {
        $self->newErrorMessage ("RepositoryID and local base path must be defined.");
        return 0;
    }

    my $repo = $self->getRepository($repository);
    if (not defined $repo) {
	$self->newErrorMessage ('Cannot get repository data for '.$repository);
	return undef;
    }

    my $relrepopath = $repo->{'LOCALPATH'};
    
    if (defined $relrepopath && $relrepopath)
    {
        my $absrepopath = SMT::Utils::cleanPath($basepath, 'repo', $relrepopath);
    
        if (-d $absrepopath)
        {
            return 1 if (-e $absrepopath.'/repodata/updateinfo.xml.gz');
            return 0;
        }
        
        $absrepopath = SMT::Utils::cleanPath($basepath, 'repo/full', $relrepopath);
    
        if (-d $absrepopath)
        {
            return 1 if (-e $absrepopath.'/repodata/updateinfo.xml.gz');
            return 0;
        }
    }

    # if local repo dirs (production nor full) do not exist or can't be
    # determined, check the remote repo URL

    my $url = $repo->{'EXTURL'};
    if (defined $relrepopath && $relrepopath)
    {
        #return 1 if TODO
        return 0;
    }   

    $self->newErrorMessage("Could not get the local path nor remote URL for repository '$repository'.");

    return 0;
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

    $self->{'dbh'}->do('UPDATE Catalogs set LAST_MIRROR=now() where CATALOGID='.$self->{'dbh'}->quote($repositoryid));

    return 1;
}

=item getStagingRepoPath($repoid, $basepath, $prefix)

Returns absolute path to repository using specified $prefix.

For internal use.

=cut
sub getStagingRepoPath($$$$)
{
    my ($self, $repoid, $basepath, $prefix) = @_;

    $basepath = '' if (not defined $basepath);

    my $repopath = $self->getRepositoryPath($repoid);

    return SMT::Utils::cleanPath($basepath, 'repo', $prefix, $repopath);
}

=item getProductionRepoPath($repoid [, $basepath])

Returns path to production repository. This path is where
the repository from which clients will get updates is meant to reside.

If $basepath is specified, it is prependend to the resulting path, otherwise
the portion of the path relative to a base path is returned. The returned path
always starts with a slash.

 $repohandler = SMT::Repositories::new($dbh);
 $basepath = '/my/base/path' # or $cfg->val("LOCAL", "MirrorTo")
 $repoid = '86fed7f9cee6d69dddabd721436faa7c63b8b403';
 $thepath = $repohandler->getProductionRepoPath($repoid, $basepath);

=cut

sub getProductionRepoPath($$$)
{
    getStagingRepoPath(shift, shift, shift, '');
}

=item getFullRepoPath($repoid [, $basepath])

Returns path to full (unfiltered) repository. This is the path where
the repository is mirrored, without any filtering. This repository must not be
exported to the clients. Testing and production repositories are generated out
of this repository.

If $basepath is specified, it is prependend to the resulting path, otherwise
the portion of the path relative to a base path is returned. The returned path
always starts with a slash.

 $repohandler = SMT::Repositories::new($dbh);
 $basepath = '/my/base/path' # or $cfg->val("LOCAL", "MirrorTo")
 $repoid = '86fed7f9cee6d69dddabd721436faa7c63b8b403';
 $thepath = getFullRepoPath($repoid, $basepath); 

=cut

sub getFullRepoPath($$$)
{
    getStagingRepoPath(shift, shift, shift, 'full');
}

=item getTestingRepoPath($repoid [, $basepath])

Returns path to testing repository. This is the path where
the repository is mirrored, eventually with filters applied, for testing.
This repository can be exported to clients only using a special registration
option.

If $basepath is specified, it is prependend to the resulting path, otherwise
the portion of the path relative to a base path is returned. The returned path
always starts with a slash.

 $repohandler = SMT::Repositories::new($dbh);
 $basepath = '/my/base/path' # or $cfg->val("LOCAL", "MirrorTo")
 $repoid = '86fed7f9cee6d69dddabd721436faa7c63b8b403';
 $thepath = getTestingRepoPath($repoid, $basepath); 

=cut

sub getTestingRepoPath($$$)
{
    getStagingRepoPath(shift, shift, shift, 'testing');
}

=item changeRepoStatus ($arg)

Adjusts repository status, such as 'mirroring' or 'staging'.

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

staging
 Defines whether a repository should support a staging feature

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

    if (! defined $arg->{'mirroring'} && ! defined $arg->{'staging'})
    {
	SMT::Utils::printLog($self->{LOG}, VBLEVEL, LOG_WARN,
	    __("Neither 'mirroring' nor 'staging' parameter is defined"));
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

    # staging parameter
    if (defined $arg->{'staging'}) {
	$update_columns .= ' '.STAGING.'='.$self->{'dbh'}->quote($arg->{'staging'} ?
	    STAGING_TRUE:STAGING_FALSE);
    }

    my $cmd = 'UPDATE '.REPOSITORIES.' '.
	'SET '.$update_columns.' '.
	'WHERE '.REPOSITORYID.'='.$self->{'dbh'}->quote($arg->{'repositoryid'}).' '.
	$where_plus;

    my $sth = $self->{'dbh'}->prepare($cmd);
    $sth->execute();

    return ($sth->rows() > 0);
}

=item isSnapshotUpToDate($args)

=over

=item Required parameters:

repositoryid
 Identifies a repository

basepath
 Defines the the base SMT path

type
 Defines a subrepository type ('testing' or 'production')

=back

=cut

sub isSnapshotUpToDate ($)
{
    my $self = shift;
    my $arg = shift || {};

    # Checking all the parameters
    if (! defined $arg->{'repositoryid'})
    {
	SMT::Utils::printLog($self->{LOG}, VBLEVEL, LOG_ERROR, __("Parameter 'repositoryid' is required"));
	return undef;
    }

    if (! defined $arg->{'basepath'})
    {
	SMT::Utils::printLog($self->{LOG}, VBLEVEL, LOG_ERROR, __("Parameter 'basepath' is required"));
	return undef;
    }

    if (! defined $arg->{'type'})
    {
	SMT::Utils::printLog($self->{LOG}, VBLEVEL, LOG_ERROR, __("Parameter 'type' is required"));
	return undef;
    }

    # Define the paths to full and selected subrepositories
    my $full_repopath = $self->getFullRepoPath($arg->{'repositoryid'}, $arg->{'basepath'});
    my $subrepo_path = undef;

    if ($arg->{'type'} eq 'testing')
    {
	$subrepo_path = $self->getTestingRepoPath($arg->{'repositoryid'}, $arg->{'basepath'});
    }
    elsif ($arg->{'type'} eq 'production')
    {
	$subrepo_path = $self->getProductionRepoPath($arg->{'repositoryid'}, $arg->{'basepath'});
    }
    else
    {
	SMT::Utils::printLog($self->{LOG}, VBLEVEL, LOG_ERROR, sprintf (__("Unknown type %s"), $arg->{'type'}));
	return undef;
    }

    my $timestamp_full = SMT::Mirror::Utils::getStatus($full_repopath);
    my $timestamp_subrepo = SMT::Mirror::Utils::getStatus($subrepo_path);

    if (! defined $timestamp_full || $timestamp_full eq '')
    {
	SMT::Utils::printLog($self->{LOG}, VBLEVEL, LOG_WARN, sprintf (__("Cannot get repository status %s"), $full_repopath));
	return undef;
    }

    if (! defined $timestamp_subrepo || $timestamp_subrepo eq '')
    {
	SMT::Utils::printLog($self->{LOG}, VBLEVEL, LOG_ERROR, sprintf (__("Cannot get repository status %s"), $subrepo_path));
	return undef;
    }

    # $timestamp_full > $timestamp_subrepo -> full subrepo is newer
    # $timestamp_full < $timestamp_subrepo -> full subrepo is older (nonsense)
    # $timestamp_full = $timestamp_subrepo -> the same age
    return ($timestamp_subrepo == $timestamp_full);
}

=back

=head1 NOTES

=head1 AUTHOR

locilka@suse.cz, jkupec@suse.cz

=head1 COPYRIGHT

Copyright 2009 SUSE LINUX Products GmbH, Nuernberg, Germany.

=cut

1;

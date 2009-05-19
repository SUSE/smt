# SMT::Repositories AKA SMT::Catalogs
package SMT::Repositories;

use strict;
use warnings;

use SMT::Utils; 

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

=item updateLastMirror($args)

Updates the database and re/creates a .mirror file containing timestamp of the last
repository mirroring. File is re/created only if something has been changed.

 updateLastMirror({
   'repositoryid' => '86fed7f9cee6d69dddabd721436faa7c63b8b403',
   'statistics'   => { 'DOWNLOAD' => 152 },
   'fullrepopath' => '/srv/www/htdocs/repo/full/RPMMD/SLE10-SDK-Updates/i586/',
 })

=over

=item Args

'repositoryid'
  A repository ID

'statistics'
  Mirroring statistics hash. Important is key 'DOWNLOAD'

'fullrepopath'
  Full local path to a mirrored repository.

=back

=cut

sub updateLastMirror ($$)
{
    my $self = shift;
    my $arg = shift || {};

    my $repositoryid = $arg->{'repositoryid'} || do {
	SMT::Utils::printLog($self->{LOG}, VBLEVEL, LOG_ERROR, __("Parameter 'repositoryid' is required"))
	    if (defined $self->{LOG});
	return 0;
    };

    my $statistics = $arg->{'statistics'} || do {
	SMT::Utils::printLog($self->{LOG}, VBLEVEL, LOG_ERROR, __("Parameter 'repositoryid' is required"))
	    if (defined $self->{LOG});
	return 0;
    };

    my $repopath = $arg->{'fullrepopath'} || do {
	SMT::Utils::printLog($self->{LOG}, VBLEVEL, LOG_ERROR, __("Parameter 'fullrepopath' is required"))
	    if (defined $self->{LOG});
	return 0;
    };

    $self->{'dbh'}->do('UPDATE Catalogs set LAST_MIRROR=now() where CATALOGID='.$self->{'dbh'}->quote($repositoryid));
    
    # Something new has been downloaded, update the mirroring timestamp 
    if (defined $statistics->{DOWNLOAD} && $statistics->{DOWNLOAD} > 0)
    {
	if ($repopath eq '')
	{
	    SMT::Utils::printLog($self->{LOG}, VBLEVEL, LOG_ERROR, __("Cannot update mirroring timestamp"))
		if (defined $self->{LOG});
	}
	else
	{
	    my $mirrorfile = $repopath.'/.mirror';

	    unlink $mirrorfile if (-e $mirrorfile);

	    # Creates a .mirror file in the root of a repository 
	    open MIRROR, ">$mirrorfile" || do {
		SMT::Utils::printLog($self->{LOG}, VBLEVEL, LOG_ERROR,
		    sprintf(__("Cannot update mirroring timestamp: %s: %s"), $mirrorfile, $!))
			if (defined $self->{LOG});
		return 1;
	    };
	    print MIRROR time;
	    close MIRROR;
	}
    }

    return 1;
}


=back

=head1 NOTES

=head1 AUTHOR

locilka@suse.cz, jkupec@suse.cz

=head1 COPYRIGHT

Copyright 2009 SUSE LINUX Products GmbH, Nuernberg, Germany.

=cut

1;

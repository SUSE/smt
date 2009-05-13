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
 # filter can be empty
 my $filter = {
   SMT::Repositories::MIRRORABLE => SMT::Repositories::MIRRORABLE_TRUE,
 };
 my $filtered_rs = $repos->GetAllRepositories ($filter);

 # Returns local path to a repository
 # (relative to the current SMT mirroring base-path)
 my $repository_id = '6df36d5532f9a85b362a93a55f8452c6adb72165';
 my $path = $repos->GetRepositoryPath ($repository_id);

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
};

=head1 METHODS 

=over 4

=item new ($dbh)

Constructor.

my $repo = SMT::Repositories ($dbh);

=cut

sub new ($) {
    my $dbh = shift;

    my $new = {
	'dbh' => $dbh,
	'error_message' => '',
        REPOS => undef,
        GOTALLREPOS => 0
    };

    bless $new;
    return $new;
}

sub NewErrorMessage ($$) {
    my $self = shift;
    my $new_error = shift || '';

    $self->{'error_message'} .= (length ($self->{'error_message'}) > 0 ? "\n":"").$new_error;
}

sub GetAndClearErrorMessage () {
    my $self = shift;

    my $ret = $self->{'error_message'} || '';
    $self->{'error_message'} = '';

    return $ret;
}

=item GetAllRepositories

Returns hash filled up with repository description according to a filter
given as a parameter.

# Returns list of all repositories than can be mirrored
$repo->GetAllRepositories ({
    SMT::Repositories::MIRRORABLE => SMT::Repositories::MIRRORABLE_TRUE,
});

# Returns list of all repositories that are being mirrored
# and have Staging feature enabled.
$repo->GetAllRepositories ({
    SMT::Repositories::MIRRORING => SMT::Repositories::MIRRORING_TRUE,
    SMT::Repositories::STAGING => SMT::Repositories::STAGING_TRUE,
});

=cut

sub GetAllRepositories ($$) {
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

sub GetRepository($$)
{
    my $self = shift;

    my $repository = shift || do {
        $self->NewErrorMessage ("RepositoryID must be defined");
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
        my $repos = $self->GetAllRepositories({SMT::Repositories::REPOSITORYID => $repository});
        $repo = @{$repos}[0] || undef;
    }

    if (not defined $repo)
    {
        $self->NewErrorMessage ("Repository with ID '$repository' not found.");
    }

    return $repo;
}

=item GetRepositoryPath

Returns a relative path of a given repository (ID) 

$repo->GetRepositoryPath ('262c8b023a6802b1b753868776a80aec2d08e85b')
    -> '$RCE/SLE11-SDK-Updates/sle-11-x86_64'

=cut

sub GetRepositoryPath ($$) {
    my $self = shift;
    my $repository = shift;

    my $repo = $self->GetRepository($repository);
    return undef if (not defined $repo); 

    my $repo_local_path = '';
    if (defined $repo->{'LOCALPATH'}) {
	$repo_local_path = $repo->{'LOCALPATH'};
    } else {
	$self->NewErrorMessage ("Repository ".$repository." matches but no 'LOCALPATH' is defined");
	return undef;
    }

    return $repo_local_path;
}

sub GetRepositoryUrl ($$) {
    my $self = shift;
    my $repository = shift;

    my $repo = $self->GetRepository($repository);
    return undef if (not defined $repo); 

    my $repo_url = '';
    if (defined $repo->{'EXTURL'}) {
        $repo_url = $repo->{'EXTURL'};
    } else {
        $self->NewErrorMessage ("Repository ".$repository." matches but no 'EXTURL' is defined");
        return undef;
    }

    return $repo_url;
}

=item StagingAllowed($repositoryid, $basepath)

Whether staging/filtering can be enabled for given repository.

=cut
sub StagingAllowed($$$)
{
    my ($self, $repository, $basepath) = @_;
    
    if (not defined $repository || not $repository || not defined $basepath || not $basepath)
    {
        $self->NewErrorMessage ("RepositoryID and local base path must be defined.");
        return 0;
    }

    my $repo = $self->GetRepository($repository);
    return undef if (not defined $repo); 

    my $relrepopath = $repo->{'LOCALPATH'};
    
    if (defined $relrepopath && $relrepopath)
    {
        my $absrepopath = SMT::Utils::cleanPath($basepath, $relrepopath);
    
        if (-d $absrepopath)
        {
            return 1 if (-e "$absrepopath/repodata/updateinfo.xml.gz");
            return 0;
        }
        
        $absrepopath = SMT::Utils::cleanPath($basepath, 'full', $relrepopath);
    
        if (-d $absrepopath)
        {
            return 1 if (-e "$absrepopath/repodata/updateinfo.xml.gz");
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

    $self->NewErrorMessage("Could not get the local path nor remote URL for repository '$repository'.");

    return 0;
}

=back

=head1 NOTES

=head1 AUTHOR

locilka@suse.cz

=head1 COPYRIGHT

Copyright 2009 SUSE LINUX Products GmbH, Nuernberg, Germany.

=cut

1;

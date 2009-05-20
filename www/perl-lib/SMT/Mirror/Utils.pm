package SMT::Mirror::Utils;

use strict;
use warnings;

use File::Copy;

use SMT::Utils;

=item saveStatus($path)

Saves mirror status in the .mirror file under $path. $path must be
the full local path to the mirrored repository.

Use this function only if something changes in the repository.

=cut
sub saveStatus($)
{
    my $repopath = shift;
    return 0 if (not $repopath || not -d $repopath);

    my $mirrorfile = $repopath.'/.mirror';
    unlink $mirrorfile if (-e $mirrorfile);

    # Creates a .mirror file in the root of a repository 
    open MIRROR, ">$mirrorfile" || return 0;
    print MIRROR time;
    close MIRROR;
    
    return 1;
}

=item copyStatus($from, $to)

Copy the mirror status file from one repository to another. Use this function
after creating a testing/production snapshot (another mirror) of the original
mirror. The status file will serve to check whether the correspoding mirror
is out of date.

$from and $to must be full local paths of source and target repositories.

Returns 1 if arguments are valid and copying succeeds, 0 otherwise.

$rh = SMT::Repositories::new($dbh);
$from = $rh->getFullRepoPath($repoid, $cfg);
$to = $rh->getProductionRepoPath($repoid, $cfg);

# ... create the 'production' snapshot here ...

if ($snapshotcreated)
{
    my $success = copyStatus($from, $to);
    # ...
}

=cut
sub copyStatus($$)
{
    my ($from, $to) = @_;

    # check for .mirror file in full repo
    return 0 if (not defined $from || not $from || not -e $from.'/.mirror');
    return 0 if (not defined $to || not $to || not -d $to);

    return 1 if File::Copy::copy($from.'/.mirror', $to.'/.mirror');
    return 0;
}

# from path
sub getStatus($)
{
    
}

1;
package SMT::Mirror::Utils;

use strict;
use warnings;

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

# from path to path
sub copyStatus($$)
{
    my ($from, $to) = @_;
   
}

# from path
sub getStatus($)
{
    
}

1;
package SMT::Parser::FilteredRepoChecker;

use solv;
use File::Temp qw/ tempdir /;

use SMT::Filter;
use SMT::Utils;

# use Data::Dumper;

=head1 NAME

SMT::Parser::FilteredRepoChecker

=head1 SYNOPSIS

  use SMT::Parser::FilteredRepoChecker;

  my $checker = SMT::Parser::FilteredRepoChecker->new();
  $checker->repoPath($localrepopath);
  $checker->filter($filter);

  my ($result, $problems, $causes) = $checker->check();

=head1 DESCRIPTION

Functions for checking consistency of update repositories with filters applied.

=head1 METHODS

=over 4

=item new([%opt])

=cut

sub new()
{
    my $class = shift;
    my %opt   = @_;
    my $self  = {};

    # set up logger

    $self->{VBLEVEL} = LOG_ERROR;
    $self->{LOG} = undef;

    if(exists $opt{vblevel} && defined $opt{vblevel})
    {
        $self->{VBLEVEL} = $opt{vblevel};
    }

    if(exists $opt{log} && defined $opt{log} && $opt{log})
    {
        $self->{LOG} = $opt{log};
    }
    else
    {
        $self->{LOG} = SMT::Utils::openLog();
    }

    my $tmpdir = tempdir(CLEANUP => 1);
    $self->{SOLV} = "$tmpdir/solv";

    bless($self, $class);
    return $self;
}

=item repoPath()

Set or get the path of the repository to check. Must be a local dir - repo2solv
does not handle different media.

=cut

sub repoPath()
{
    my $self = shift;
    if (@_) { $self->{PATH} = shift }
    return $self->{PATH};
}

=item filter()

Set or get the filter.

=cut

sub filter()
{
    my $self = shift;
    if (@_) { $self->{FILTER} = shift }
    return $self->{FILTER};
}


=item check()

Checks given repository with given filters for dependency problems.

Returns ($result, $problems), where $result is a boolean and $problems is
a hash reference. $result is true if the repository checks out fine, false if
there is some problem. In the latter case, $problems contains a hash with
to-be-removed (filtered) packages needed by allowed patches; the package
'name-version' as key and the patch ID ('patchname-version') of the patch which
needs it as value. Similarily $causes contains the patches, whose ban cause the
problem, as values.

=cut

sub check()
{
    my $self = shift;

    my $result = 1;
    my $problems = {};
    my $causes = {};

    # parse the repo into solv file
    if (not -e $self->{SOLV})
    {
        return (0, undef) if not $self->repo2solv();
    }
    else
    {
        printLog($self->{LOG}, $self->{VBLEVEL}, LOG_DEBUG,
            'Using cached solv file ' . $self->{SOLV}, 0);
    }

    # load the solv file
    my $pool = new solv::Pool;
    # $pool->set_arch('x86_64'); # is this needed if we only want to search the pool?
    my $repo = $pool->create_repo('checked-repo');
    $repo->add_solv($self->{SOLV});

    printLog($self->{LOG}, $self->{VBLEVEL}, LOG_DEBUG,
        'FilteredRepoChecker: repo loaded. Pool size: ' . $pool->size() .
        ', count: ' . $pool->count(), 0);

    # get the patches
    my $allowed = {};
    my $forbiden = {};
    my $allowedpkgs = {};
    my $forbidenpkgs = {};
    foreach my $solvable ($pool->solvables())
    {
        next if($solvable->name() !~ /^patch\:(.*)$/);

        my $patch = {
            name => $1,
            version => $solvable->evr(),
            type => $solvable->attr_values('solvable:patchcategory')
            #title =>       # not used in match() so far
            #description => # not used in match() so far
        };
        my $patchid = $patch->{name}.'-'.$patch->{version};

        if ($self->{FILTER}->matches($patch))
        {
            $forbiden->{$patchid} = $patch;

            for (my $i = 0; $i < $solvable->conflicts()->size(); $i++)
            {
                my $rel = $solvable->conflicts()->get($i);
                $forbidenpkgs->{$rel->name() . '-' . $rel->evr()} = $patchid;
            }
        }
        else
        {
            $allowed->{$patchid} = $patch;

            for (my $i = 0; $i < $solvable->conflicts()->size(); $i++)
            {
                my $rel = $solvable->conflicts()->get($i);
                $allowedpkgs->{$rel->name() . '-' . $rel->evr()} = $patchid;
            }
        }
    }

    # print Dumper($allowed, $forbiden, $allowedpkgs, $forbidenpkgs);

    # look for problems
    # for all packages to remove, check if some allowed patch has it
    # add to problems if it does
    foreach my $pkg (keys %$forbidenpkgs)
    {
        if (exists $allowedpkgs->{$pkg})
        {
            $result = 0;
            $problems->{$pkg} = $allowedpkgs->{$pkg};
            $causes->{$pkg} = $forbidenpkgs->{$pkg};
        }
    }

    return ($result, $problems, $causes);
}


=repo2solv()

Parses the repository into temporary solv file.

=cut

sub repo2solv()
{
    my $self = shift;

    my $repo2solv = '/usr/bin/repo2solv.sh';
    my @args = ('-o', $self->{SOLV}, $self->{PATH});

    my ($exitcode, $out, $err) =
        SMT::Utils::executeCommand(
            {log => $self->{LOG}, vblevel => $self->{VBLEVEL}},
            $repo2solv, @args);

    if ($exitcode != 0)
    {
        unlink $self->{SOLV};
        return 0;
    }
    return 1;
}

1;
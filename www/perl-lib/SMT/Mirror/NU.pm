package SMT::Mirror::NU;

use strict;

use URI;
use File::Path;

use SMT::Parser::NU;
use SMT::Mirror::Job;
use SMT::Mirror::RpmMd;
use SMT::Utils;

use Data::Dumper;

=head1 NAME

SMT::Mirror::NU - mirroring of a Novell Update repository

=head1 SYNOPSIS

  use SMT::Mirror::NU;

  $mirror = SMT::Mirror::NU->new();
  $mirror->uri( 'https://username:password@nu.novell.com');
  $mirror->mirrorTo( "/srv/www/htdocs/");

=head1 DESCRIPTION

Mirroring of a Novell Update repository.

The mirror function will not download the same files twice.

In order to clean the repository, that is removing all files
which are not mentioned in the metadata, you can use the clean method:

 $mirror->clean();

=head1 METHODS

=over 4

=item new([$params])

Create a new SMT::Mirror::RpmMd object:

  my $mirror = SMT::Mirror::RpmMd->new(debug => 1);

Arguments are an anonymous hash array of parameters:

=over 4

=item debug

Set to 1 to enable debug. 

=back

=item uri()

 $mirror->uri( 'https://user:pass@nu.novell.com/' );

 Specify the NU source where to mirror from.

=item mirrorTo()

 $mirror->mirrorTo( "/somedir", { urltree => 1 });

 Sepecify the target directory where to place the mirrored files.

=over 4

=item urltree

The option urltree of the mirror method controls 
how the repo is mirrored. If urltree is true, then subdirectories
with the hostname and path of the repo url are created inside the
target directory.
If urltree is false, then the repo is mirrored right below the target
directory.

=back

=back

=head1 AUTHOR

mc@suse.de

=head1 COPYRIGHT

Copyright 2007, 2008 SUSE LINUX Products GmbH, Nuernberg, Germany.

=cut

# constructor
sub new
{
    my $pkgname = shift;
    my %opt   = @_;
    
    my $self  = {};
    $self->{URI}   = undef;

    # starting with / upto  repo/
    $self->{LOCALBASEPATH} = undef;
    
    $self->{DEBUG}  = 0;
    $self->{LOG}    = 0;
    $self->{DEEPVERIFY} = 0;
    $self->{DBREPLACEMENT} = undef;
    $self->{MIRRORSRC} = 1;
    $self->{DBH} = undef;
    
    $self->{STATISTIC}->{DOWNLOAD} = 0;
    $self->{STATISTIC}->{UPTODATE} = 0;
    $self->{STATISTIC}->{ERROR}    = 0;
    $self->{STATISTIC}->{DOWNLOAD_SIZE} = 0;

    if(exists $opt{debug} && defined $opt{debug} && $opt{debug})
    {
        $self->{DEBUG} = 1;
    }

    if(exists $opt{dbh} && defined $opt{dbh} && $opt{dbh})
    {
        $self->{DBH} = $opt{dbh};
    }

    if(exists $opt{log} && defined $opt{log} && $opt{log})
    {
        $self->{LOG} = $opt{log};
    }
    else
    {
        $self->{LOG} = SMT::Utils::openLog();
    }
    
    if(exists $opt{mirrorsrc} && defined $opt{mirrorsrc} && !$opt{mirrorsrc})
    {
        $self->{MIRRORSRC} = 0;
    }    

    bless($self);
    return $self;
}

# URI property
sub uri
{
    my $self = shift;
    if (@_) { $self->{URI} = shift }
    return $self->{URI};
}

sub deepverify
{
    my $self = shift;
    if (@_) { $self->{DEEPVERIFY} = shift }
    return $self->{DEEPVERIFY};
}

sub localBasePath
{
    my $self = shift;
    if (@_) { $self->{LOCALBASEPATH} = shift }
    return $self->{LOCALBASEPATH};
}

# database handle
sub dbh
{
    my $self = shift;
    if (@_) { $self->{DBH} = shift }
    
    return $self->{DBH};
}

sub dbreplacement
{
    my $self = shift;
    if (@_) { $self->{DBREPLACEMENT} = shift }
    return $self->{DBREPLACEMENT};
}    

sub debug
{
    my $self = shift;
    if (@_) { $self->{DEBUG} = shift }
    
    return $self->{DEBUG};
}

sub statistic
{
    my $self = shift;
    return $self->{STATISTIC};
}

# mirrors the repository to destination
sub mirrorTo()
{
    my $self = shift;
    my %options = @_;
  
    if ( ! -d $self->localBasePath() )
    { 
        printLog($self->{LOG}, "error", $self->localBasePath()." does not exist");
        exit 1;
    }

    # extract the url components to create
    # the destination directory
    # so we save the repo to:
    # $destdir/hostname.com/path
    my $saveuri = URI->new( $self->uri() );
    $saveuri->userinfo(undef);
    
    printLog($self->{LOG}, "info", sprintf(__("Mirroring: %s"), $saveuri->as_string ));
    printLog($self->{LOG}, "info", sprintf(__("Target:    %s"), $self->localBasePath() ));

    #
    # store the repoindex to a temdir. It is needed only for mirroring.
    # To have it later in LOCALPATH may confuse our customers.
    #
    my $destdir = File::Temp::tempdir("smt-XXXXXXXX", CLEANUP => 1, TMPDIR => 1);
    my $destfile = SMT::Utils::cleanPath( $destdir, "repo/repoindex.xml" );

    # get the repository index
    my $job = SMT::Mirror::Job->new(debug => $self->debug(), log => $self->{LOG}, dbh => $self->{DBH} );
    $job->uri( $self->{URI} );
    $job->localBasePath( "/" );
    $job->localRepoPath( $destdir );
    $job->localFileLocation( "/repo/repoindex.xml" );
    
    # get the file
    if($job->mirror() == 1)
    {
        $self->{STATISTIC}->{ERROR} +=1;
    }
    else
    {
        $self->{STATISTIC}->{DOWNLOAD_SIZE} += int($job->downloadSize());
        $self->{STATISTIC}->{DOWNLOAD} += 1;
    
        # changing the MIRRORABLE flag is done by ncc-sync, no need to do it here too
        # $dbh->do("UPDATE Catalogs SET MIRRORABLE = 'N' where CATALOGTYPE='nu'");
    
        my $parser = SMT::Parser::NU->new(log => $self->{LOG});
        $parser->parse($destfile, sub{ mirror_handler($self, $options{dryrun}, @_) });
    }
    
    return $self->{STATISTIC}->{ERROR};
}

# deletes all files not referenced in
# the rpmmd resource chain
sub clean()
{
    my $self = shift;

    # algorithm
    
    if ( ! -d $self->localBasePath() )
    { 
        printLog($self->{LOG}, "error", sprintf(__("Destination '%s' does not exist"), $self->localBasePath() ));
        exit 1;
    }

    my $res = $self->{DBH}->selectcol_arrayref("select LOCALPATH from Catalogs where CATALOGTYPE='nu' and DOMIRROR='Y' and MIRRORABLE='Y'");
    
    foreach my $path (@{$res})
    {
        my $rpmmd = SMT::Mirror::RpmMd->new(debug => $self->debug(), log => $self->{LOG}, mirrorsrc => $self->{MIRRORSRC}, dbh => $self->{DBH});
        $rpmmd->localBasePath( $self->localBasePath() );
        $rpmmd->localRepoPath( $path );
        $rpmmd->deepverify( $self->deepverify() );
        
        $rpmmd->clean( );
    }
}

sub mirror_handler
{
    my $self   = shift;
    my $dryrun = shift;
    my $data   = shift;

    my $domirror = 0;

    if(defined $self->{DBH} && $self->{DBH})
    {
        my $res = $self->{DBH}->selectcol_arrayref( sprintf("select DOMIRROR from Catalogs where MIRRORABLE='Y' and CATALOGTYPE='nu' and NAME=%s and TARGET=%s", 
                                                            $self->{DBH}->quote($data->{NAME}), $self->{DBH}->quote($data->{DISTRO_TARGET}) ) );

        if(defined $res && exists $res->[0] && 
           defined $res->[0] && $res->[0] eq "Y")
        {
            $domirror = 1;
        }
    }
    else
    {
        # all catalogs in DBREPLACEMENT should be mirrored, but we have to strip out the "RPMMD" types
        if(exists $self->{DBREPLACEMENT}->{$data->{NAME}."-".$data->{DISTRO_TARGET}}->{CATALOGTYPE} && 
           defined $self->{DBREPLACEMENT}->{$data->{NAME}."-".$data->{DISTRO_TARGET}}->{CATALOGTYPE} &&
           $self->{DBREPLACEMENT}->{$data->{NAME}."-".$data->{DISTRO_TARGET}}->{CATALOGTYPE} eq "nu")
        {
            $domirror = 1;
        }
    }
    
    if($domirror)
    {
        my $catalogURI = join("/", $self->uri(), "repo", $data->{PATH});
        
        &File::Path::mkpath( SMT::Utils::cleanPath( $self->localBasePath(), $data->{PATH} ) );

        # get the repository index
        my $mirror = SMT::Mirror::RpmMd->new(debug => $self->debug(), log => $self->{LOG}, mirrorsrc => $self->{MIRRORSRC}, dbh => $self->{DBH});
        $mirror->localBasePath( $self->localBasePath() );
        $mirror->localRepoPath( $data->{PATH} );        
        $mirror->uri( $catalogURI );
        $mirror->deepverify( $self->deepverify() );

        $mirror->mirrorTo( dryrun => $dryrun );

        my $s = $mirror->statistic();
        
        $self->{STATISTIC}->{DOWNLOAD} += $s->{DOWNLOAD};
        $self->{STATISTIC}->{UPTODATE} += $s->{UPTODATE};
        $self->{STATISTIC}->{ERROR}    += $s->{ERROR};
        $self->{STATISTIC}->{DOWNLOAD_SIZE} += $s->{DOWNLOAD_SIZE};
    }
}

1;

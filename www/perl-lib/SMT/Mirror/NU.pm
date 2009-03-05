package SMT::Mirror::NU;

use strict;

use URI;
use File::Path;

use SMT::Parser::NU;
use SMT::Mirror::Job;
use SMT::Mirror::RpmMd;
use SMT::Utils;

#use Data::Dumper;

=head1 NAME

SMT::Mirror::NU - mirroring of a Novell Update repository

=head1 SYNOPSIS

  use SMT::Mirror::NU;

  $mirror = SMT::Mirror::NU->new();
  $mirror->uri( "https://nu.novell.com");
  $mirror->localBaseDir("/srv/www/htdocs/repo/");
  $mirror->mirror();

=head1 DESCRIPTION

Mirroring of a Novell Update repository.

The mirror function will not download the same files twice.

In order to clean the repository, that is removing all files
which are not mentioned in the metadata, you can use the clean method:

 $mirror->clean();

=head1 METHODS

=over 4

=item new([%params])

Create a new SMT::Mirror::NU object:

  my $mirror = SMT::Mirror::NU->new();

Arguments are an anonymous hash array of parameters:

=over 4

=item debug <0|1>

Set to 1 to enable debug. 

=item useragent

LWP::UserAgent object to use for this job. Usefull for keep_alive. 

=item dbh

DBI database handle.

=item log

Logfile handle

=item nohardlink

Set to 1 to disable the use of hardlinks. Copy is used instead of it.

=item mirrorsrc

Set to 0 to disable mirroring of source rpms.

=back

=cut

sub new
{
    my $pkgname = shift;
    my %opt   = @_;
    
    my $self  = {};
    $self->{URI}   = undef;

    # starting with / upto  repo/
    $self->{LOCALBASEPATH} = undef;
    
    $self->{VBLEVEL}  = 0;
    $self->{LOG}    = 0;
    $self->{DEEPVERIFY} = 0;
    $self->{DBREPLACEMENT} = undef;
    $self->{DBH} = undef;

    # Do _NOT_ set env_proxy for LWP::UserAgent, this would break https proxy support
    $self->{USERAGENT}  = (defined $opt{useragent} && $opt{useragent})?$opt{useragent}:SMT::Utils::createUserAgent(keep_alive => 1);
    
    $self->{STATISTIC}->{DOWNLOAD} = 0;
    $self->{STATISTIC}->{LINK} = 0;
    $self->{STATISTIC}->{COPY} = 0;
    $self->{STATISTIC}->{UPTODATE} = 0;
    $self->{STATISTIC}->{ERROR}    = 0;
    $self->{STATISTIC}->{DOWNLOAD_SIZE} = 0;

    $self->{MIRRORSRC} = 1;
    $self->{NOHARDLINK} = 0;

    if(exists $opt{vblevel} && defined $opt{vblevel})
    {
        $self->{VBLEVEL} = $opt{vblevel};
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

    if(exists $opt{nohardlink} && defined $opt{nohardlink} && $opt{nohardlink})
    {
        $self->{NOHARDLINK} = 1;
    }

    bless($self);
    return $self;
}

=item uri()

 $mirror->uri( 'https://user:pass@nu.novell.com/' );

 Specify the NU source where to mirror from.

=cut
sub uri
{
    my $self = shift;
    if (@_) { $self->{URI} = shift }
    return $self->{URI};
}

=item deepverify()

Enable or disable deepverify mode. 
Returns the current state.

=cut

sub deepverify
{
    my $self = shift;
    if (@_) { $self->{DEEPVERIFY} = shift }
    return $self->{DEEPVERIFY};
}

=item localBasePath([path])

Set and get the base path on the local system. Typically starting
with / upto repo/

=cut
sub localBasePath
{
    my $self = shift;
    if (@_) { $self->{LOCALBASEPATH} = shift }
    return $self->{LOCALBASEPATH};
}

=item dbh([handle])

Set and get the database handle.

=cut
sub dbh
{
    my $self = shift;
    if (@_) { $self->{DBH} = shift }
    
    return $self->{DBH};
}

=item dbreplacement([$hash])

Set and get the database replacement hash.

=cut
sub dbreplacement
{
    my $self = shift;
    if (@_) { $self->{DBREPLACEMENT} = shift }
    return $self->{DBREPLACEMENT};
}    

=item vblevel([level])

Set or get the verbose level.

=cut
sub vblevel
{
    my $self = shift;
    if (@_) { $self->{VBLEVEL} = shift }
    
    return $self->{VBLEVEL};
}

=item statistic()

Returns the statistic hash reference. 
Available keys in this has are:

=over 4

=item DOWNLOAD

Number of new files (downloaded, hardlinked or copied)   

=item UPTODATE

Number of files which are up-to-date

=item ERROR

Number of errors.

=item DOWNLOAD_SIZE

Size of files downloaded (in bytes)

=back

=cut

sub statistic
{
    my $self = shift;
    return $self->{STATISTIC};
}

sub job2statistic
{
    my $self = shift;
    my $job  = shift || return;

    $self->{STATISTIC}->{DOWNLOAD_SIZE} += int($job->downloadSize());
    if( $job->wasError() )
    {
        $self->{STATISTIC}->{ERROR} += 1;
    }
    elsif( $job->wasUpToDate() )
    {
        $self->{STATISTIC}->{UPTODATE} += 1;
    }
    elsif( $job->wasDownload() )
    {
        $self->{STATISTIC}->{DOWNLOAD} += 1;
    }
    elsif( $job->wasLink() )
    {
        $self->{STATISTIC}->{LINK} += 1;
    }
    elsif( $job->wasCopy() )
    {
        $self->{STATISTIC}->{COPY} += 1;
    }
} 

sub statistic2statistic
{
    my $self = shift;
    my $statistic  = shift || return;
    
    $self->{STATISTIC}->{DOWNLOAD_SIZE} += int($statistic->{DOWNLOAD_SIZE});
    $self->{STATISTIC}->{DOWNLOAD} += int($statistic->{DOWNLOAD});
    $self->{STATISTIC}->{LINK} += int($statistic->{LINK});
    $self->{STATISTIC}->{COPY} += int($statistic->{COPY});
    $self->{STATISTIC}->{ERROR} += int($statistic->{ERROR});
    $self->{STATISTIC}->{UPTODATE} += int($statistic->{UPTODATE});
}


=item mirror()

Iterate over all catalogs which are enabled for mirroring and start the mirror process for them. 
Returns the number of errors.

=over 4

=item dryrun

If set to 1, only the metadata are downloaded to a temporary directory and all
files which are outdated are reported. After this is finished, the directory 
containing the metadata is removed.

=back

=cut

sub mirror()
{
    my $self = shift;
    my %options = @_;
  
    if ( ! -d $self->localBasePath() )
    {
        printLog($self->{LOG}, $self->vblevel(), LOG_ERROR, $self->localBasePath()." does not exist");
        $self->{STATISTIC}->{ERROR} += 1;
        return $self->{STATISTIC}->{ERROR};
    }

    # extract the url components to create
    # the destination directory
    # so we save the repo to:
    # $destdir/hostname.com/path
    my $saveuri = URI->new( $self->uri() );
    $saveuri->userinfo(undef);
    
    printLog($self->{LOG}, $self->vblevel(), LOG_INFO1, sprintf(__("Mirroring: %s"), $saveuri->as_string ));
    printLog($self->{LOG}, $self->vblevel(), LOG_INFO1, sprintf(__("Target:    %s"), $self->localBasePath() ));

    #
    # store the repoindex to a temdir. It is needed only for mirroring.
    # To have it later in LOCALPATH may confuse our customers.
    #
    my $destdir = File::Temp::tempdir("smt-XXXXXXXX", CLEANUP => 1, TMPDIR => 1);
    my $destfile = SMT::Utils::cleanPath( $destdir, "repo/repoindex.xml" );

    # get the repository index
    my $job = SMT::Mirror::Job->new(vblevel => $self->vblevel(), log => $self->{LOG}, useragent => $self->{USERAGENT},
                                    dbh => $self->{DBH}, nohardlink => $self->{NOHARDLINK} );
    $job->uri( $self->{URI} );
    $job->localBasePath( "/" );
    $job->localRepoPath( $destdir );
    $job->localFileLocation( "/repo/repoindex.xml" );
    
    # get the file
    my $mres = $job->mirror();
    $self->job2statistic($job);
    if( $mres != 1 )
    {
        # changing the MIRRORABLE flag is done by ncc-sync, no need to do it here too
        # $dbh->do("UPDATE Catalogs SET MIRRORABLE = 'N' where CATALOGTYPE='nu'");
    
        my $parser = SMT::Parser::NU->new(log => $self->{LOG});
        $parser->parse($destfile, sub{ mirror_handler($self, $options{dryrun}, @_) });
    }
    
    return $self->{STATISTIC}->{ERROR};
}

=item clean()

Iterate over all catalogs which are enabled for mirroring and 
deletes all files not referenced in the rpmmd resource chain.

=cut
sub clean()
{
    my $self = shift;

    # algorithm
    
    if ( ! -d $self->localBasePath() )
    { 
        printLog($self->{LOG}, $self->vblevel(), LOG_ERROR, sprintf(__("Destination '%s' does not exist"), $self->localBasePath() ));
        return;
    }

    my $res = $self->{DBH}->selectcol_arrayref("select LOCALPATH from Catalogs where CATALOGTYPE='nu' and DOMIRROR='Y' and MIRRORABLE='Y'");
    
    foreach my $path (@{$res})
    {
        my $rpmmd = SMT::Mirror::RpmMd->new(vblevel => $self->vblevel(), log => $self->{LOG}, mirrorsrc => $self->{MIRRORSRC},
                                            dbh => $self->{DBH}, nohardlink => $self->{NOHARDLINK});
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
        my $mirror = SMT::Mirror::RpmMd->new(vblevel => $self->vblevel(), log => $self->{LOG}, mirrorsrc => $self->{MIRRORSRC},
                                             useragent => $self->{USERAGENT}, dbh => $self->{DBH}, nohardlink => $self->{NOHARDLINK});
        $mirror->localBasePath( $self->localBasePath() );
        $mirror->localRepoPath( $data->{PATH} );        
        $mirror->uri( $catalogURI );
        $mirror->deepverify( $self->deepverify() );

        $mirror->mirror( dryrun => $dryrun );

        $self->statistic2statistic( $mirror->statistic() );
    }
}


=back

=head1 AUTHOR

mc@suse.de

=head1 COPYRIGHT

Copyright 2007, 2008, 2009 SUSE LINUX Products GmbH, Nuernberg, Germany.

=cut

1;

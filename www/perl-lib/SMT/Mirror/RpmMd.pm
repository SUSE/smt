package SMT::Mirror::RpmMd;
use strict;

use URI;
use File::Path;
use File::Find;
use File::Temp qw/ tempdir /;
use File::Copy;
use File::Basename;
use IO::Zlib;
use Time::HiRes qw(gettimeofday tv_interval);
use Digest::SHA1  qw(sha1 sha1_hex);

use SMT::Mirror::Job;
use SMT::Parser::RpmMdLocation;
use SMT::Parser::RpmMdPatches;
use SMT::Parser::RpmMdPrimaryFilter; # for removing of filtered packages from MD
use SMT::Parser::RpmMdOtherFilter;   # for removing of filtered packages from MD
use SMT::Utils;

=head1 NAME

SMT::Mirror::RpmMd - mirroring and filtering of an RPMMD repository

=head1 SYNOPSIS

  use SMT::Mirror::RpmMd;

  $mirror = SMT::Mirror::RpmMd->new();
  $mirror->uri( "http://repo.com/10.3" );
  $mirror->localBasePath("/srv/www/htdocs/repo/");
  $mirror->localRepoPath("RPMMD/10.3/");

  $mirror->mirror();

  $mirror->clean();

=head1 DESCRIPTION

Provides mirroring and filtering of an RPMMD repository.

The mirror function will not download the same files twice.

In order to clean the repository, that is removing all files
which are not mentioned in the metadata, you can use the clean method:

 $mirror->clean();

In order to filter unwanted patches from the repository, pass an SMT::Filter
object to the constructor.

=head1 METHODS

=over 4

=item new([%params])

Create a new SMT::Mirror::RpmMd object:

  my $mirror = SMT::Mirror::RpmMd->new();

Arguments are an anonymous hash array of parameters:

=over 4

=item vblevel <level>

Set the verbose level.

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

=item filter

An SMT::Filter object defining patches that should be removed from the mirrored
repository.

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

    # catalog Path like LOCALPATH in the DB.
    # e.g. $RCE/SLES11-Updates/sle-11-i586/
    $self->{LOCALREPOPATH}   = undef;


    $self->{JOBS}         = {};
    $self->{REPODATAJOBS} = {};
    $self->{VERIFYJOBS}   = {};
    $self->{CLEANLIST}    = {};

    $self->{FILTER} = undef;

    $self->{VBLEVEL} = 0;
    $self->{LOG}   = undef;
    $self->{DEEPVERIFY}   = 0;
    $self->{DBH} = undef;

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

    if(exists $opt{filter} && defined $opt{filter})
    {
        $self->{FILTER} = $opt{filter};
    }

    $self->{STATISTIC} = {};
    resetStatistics($self->{STATISTIC});

    if(defined $opt{useragent} && $opt{useragent})
    {
        $self->{USERAGENT}  = $opt{useragent};
    }
    else
    {
        $self->{USERAGENT} = SMT::Utils::createUserAgent(log => $self->{LOG}, vblevel => $self->{VBLEVEL});
    }

    $self->{CFG} = undef;
    if($opt{cfg})
    {
        $self->{CFG} = $opt{cfg};
    }

    $self->{REPOID} = undef;
    if($opt{repoid})
    {
        $self->{REPOID} = $opt{repoid};
    }

    bless($self);
    return $self;
}

=item uri([url])

 $mirror->uri( "http://repo.com/10.3" );

 Specify the RpmMd source where to mirror from.

=cut

sub uri
{
    my $self = shift;
    if (@_) { $self->{URI} = shift }
    return $self->{URI};
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

=item localRepoPath([path])

Set and get the repository path on the local system.
E.g. $RCE/SLES11-Updates/sle-11-i586/

=cut

sub localRepoPath
{
    my $self = shift;
    if (@_) { $self->{LOCALREPOPATH} = shift }
    return $self->{LOCALREPOPATH};
}

=item fullLocalRepoPath()

Returns the full path to the repository on the local system. It concatenate
localBasePath() and localRepoPath().

=cut

sub fullLocalRepoPath
{
    my $self = shift;

    return SMT::Utils::cleanPath($self->localBasePath(), $self->localRepoPath());
}

=item localLicenseDir

Return the full local path to the license directory

=cut

sub localLicenseDir
{
    my $self = shift;
    my $path = $self->fullLocalRepoPath();
    $path =~ s/\/$//;
    $path .= ".license";
    return $path;
}

sub updateLicenseDir
{
    my $self = shift;
    my $licenseFile = shift;

    my $licdir = $self->localLicenseDir();
    return 0 if (not $licdir);
    return 0 if( ! -r $licenseFile || $licenseFile !~ /\.tar\./);
    if (-d "$licdir")
    {
        rmtree($licdir, 0, 0);
    }
    mkpath($licdir, {error => \my $err});
    if (@$err)
    {
        my ($file, $emsg) = each %{$err->[0]};
        printLog($self->{LOG}, $self->vblevel(), LOG_ERROR,
                 "Could not create the destination directory '$licdir': $emsg");
        $self->{STATISTIC}->{ERROR} += 1;
        return $self->{STATISTIC}->{ERROR};
    }
    my @cargs = ("-x", "-f", $licenseFile, "-C", $licdir);
    my ($exitcode, $out, $error) = SMT::Utils::executeCommand(
        {log => $self->{LOG}, vblevel => $self->vblevel()}, "/bin/tar", @cargs);
    if ($exitcode || $exitcode == -1)
    {
        $self->{STATISTIC}->{ERROR} += 1;
        printLog($self->{LOG}, $self->vblevel(), LOG_ERROR,
                 "Failed to unpack license: $out\n$error");
        return 0;
    }
    return 1;
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

=item dbh([handle])

Set and get the database handle.

=cut
sub dbh
{
    my $self = shift;
    if (@_) { $self->{DBH} = shift }

    return $self->{DBH};
}

=item statistic()

Returns the statistic hash reference.
Available keys in this has are:

=over 4

=item TOTALFILES

Total number of files in the repository (referenced from the metadata).

=item DOWNLOAD

Number of downloaded new/changed files.

=item LINK

Number of files hardlinked from the source repo to mirror.

=item COPY

Number of files copied from the source repo to mirror.

=item UPTODATE

Number of files which are up-to-date

=item ERROR

Number of errors.

=item DOWNLOAD_SIZE

Size of files downloaded (in bytes)

=item NEWSECPATCHES

Number of new security updates

=item NEWRECPATCHES

Number of new recommended updates

=item NEWSECTITLES

Array reference with the titles of the new security updates

=item NEWRECTITLES

Array reference with the titles of the new recommended updates

=back

=cut

sub statistic
{
    my $self = shift;
    return $self->{STATISTIC};
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


sub job2statistic
{
    my $self = shift;
    my $job  = shift || return;

    $self->{STATISTIC}->{DOWNLOAD_SIZE} += int($job->downloadSize());
    $self->{STATISTIC}->{TOTALFILES}++;
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

=item newpatches()

Returns a hash with new patches since last mirroring or an empty hash.
If mirror() has not been called so far, it returns undef.

The hash has the same structure as the one returned
by SMT::Parser::RpmMdPatches::parse().

=cut

sub newpatches
{
    my $self = shift;
    return $self->{NEWPATCHES};
}

# Internal function
sub resetStatistics($)
{
    my $stats = shift;

    $stats->{TOTALFILES}    = 0;
    $stats->{ERROR}         = 0;
    $stats->{UPTODATE}      = 0;
    $stats->{DOWNLOAD}      = 0;
    $stats->{LINK}          = 0;
    $stats->{COPY}          = 0;
    $stats->{DOWNLOAD_SIZE} = 0;
    $stats->{NEWSECPATCHES} = 0;
    $stats->{NEWRECPATCHES} = 0;
    $stats->{NEWSECTITLES} = [];
    $stats->{NEWRECTITLES} = [];

    return 1;
}


=item mirror()

 Start the mirror process.
 Returns the count of errors.

Available options:

=over 4

=item dryrun

If set to 1, only the metadata are downloaded to a temporary directory and all
files which are outdated are reported. After this is finished, the directory
containing the metadata is removed.

=item force

If set to 1, the mirroring will be forced even if the target seems to be
up to date with the source. Use full to when mirroring with filters and the
only thing changed is the filter.

=item keyid

ID of the GPG key to use to sign the metadata (repomd.xml file) in case they
have been changed (due to filtering). If not specified, any existing signature
and exported key will be deleted.

=item keypass

Passphrase to the GPG key for signing the metadata.

=back

=cut

sub mirror()
{
    my $self = shift;
    my %options = @_;
    my $dryrun  = 0;
    my $keyid   = undef;
    my $keypass = undef;
    my $force   = 0;

    my $isYum = (ref($self) eq "SMT::Mirror::Yum");
    my $t0 = [gettimeofday] ;

    $dryrun = 1
        if(exists $options{dryrun} && defined $options{dryrun} && $options{dryrun});
    $keyid = $options{keyid}
        if(exists $options{keyid} && defined $options{keyid} && $options{keyid});
    $keypass = $options{keypass}
        if(exists $options{keypass} && defined $options{keypass});
    $force = 1
        if(exists $options{force} && defined $options{force} && $options{force});

    # reset the counter
    resetStatistics $self->{STATISTIC};

    # hash to hold patches added since last mirroring
    $self->{NEWPATCHES} = {};

    # repository's metadata files info
    # gets initialized in download_handler form repomd.xml <data> data.
    #
    # see description in removePackages() for details of it's contents
    $self->{MDFILES} = {};

    my $dest = $self->fullLocalRepoPath();

    if ( ! -d $dest )
    {
        mkpath($dest, {error => \my $err});
        if (@$err)
        {
            my ($file, $emsg) = each %{$err->[0]};
            printLog($self->{LOG}, $self->vblevel(), LOG_ERROR,
                "Could not create the destination directory '$dest': $emsg");
            $self->{STATISTIC}->{ERROR} += 1;
            return $self->{STATISTIC}->{ERROR};
        }
    }
    if ( !defined $self->uri() ||
         $self->uri() !~ /^http/ && $self->uri() !~ /^file/ && $self->uri() !~ /^ftp/)
    {
        printLog($self->{LOG}, $self->vblevel(), LOG_ERROR, "Invalid URL: ".((defined $self->uri())?$self->uri():"") );
        $self->{STATISTIC}->{ERROR} += 1;
        return $self->{STATISTIC}->{ERROR};
    }


    # extract the url components to create
    # the destination directory
    # so we save the repo to:
    # $destdir/hostname.com/path
    my $saveuri = SMT::Utils::getSaveUri($self->{URI});

    printLog($self->{LOG}, $self->vblevel(), LOG_INFO1, sprintf(__("Mirroring: %s"), $saveuri )) if(!$isYum);
    printLog($self->{LOG}, $self->vblevel(), LOG_INFO1, sprintf(__("Target:    %s"), $self->fullLocalRepoPath() )) if(!$isYum);

    # get the repository index
    my $job = SMT::Mirror::Job->new(vblevel => $self->vblevel(), useragent => $self->{USERAGENT}, log => $self->{LOG},
                                    dbh => $self->{DBH}, nohardlink => $self->{NOHARDLINK}, dryrun => $dryrun );
    $job->uri( $self->uri() );
    $job->localBasePath( $self->localBasePath() );
    $job->localRepoPath( $self->localRepoPath() );
    $job->localFileLocation( "repodata/repomd.xml" );


    # We expect the data are ok. If repomd.xml does not exist we downlaod everything new
    # which is like deepverify
    my $verifySuccess = 1;

    if ( $self->deepverify() && -e $job->fullLocalPath() )
    {
        # a deep verify check is requested

        my $removeinvalid = 1;
        $removeinvalid = 0 if( $dryrun );

        $verifySuccess = $self->verify( removeinvalid => $removeinvalid, quiet => ($self->vblevel() != LOG_DEBUG) );

        resetStatistics $self->{STATISTIC};

        if ( ! $dryrun )
        {
            # reset deepverify. It was done so we do not need it during mirror again.
            $self->deepverify(0);
        }
    }

    if ( !$force && !$job->outdated() && $verifySuccess )
    {
        printLog($self->{LOG}, $self->vblevel(), LOG_INFO1, sprintf(__("=> Finished mirroring '%s' All files are up to date."), $saveuri)) if(!$isYum);
        printLog($self->{LOG}, $self->vblevel(), LOG_INFO1, "", 1, 0) if(!$isYum);
        return 0;
    }
    # else if $outdated, forced, or verify failed; we must download repomd.xml

    # copy repodata to .repodata
    # we do not want to damage the repodata until we
    # have them all

    my $metatempdir = SMT::Utils::cleanPath( $job->fullLocalRepoPath(), ".repodata" );

    if( -d "$metatempdir" )
    {
        rmtree($metatempdir, 0, 0);
    }

    &File::Path::mkpath( $metatempdir );

    if( -d $job->fullLocalRepoPath()."/repodata" )
    {
        opendir(DIR, $job->fullLocalRepoPath()."/repodata") or do
        {
            $self->{STATISTIC}->{ERROR} += 1;
            return $self->{STATISTIC}->{ERROR};
        };

        foreach my $entry (readdir(DIR))
        {
            next if ($entry =~ /^\./);

            my $fullpath = $job->fullLocalRepoPath()."/repodata/$entry";
            if( -f $fullpath )
            {
                my $success = 0;
                if(!$self->{NOHARDLINK})
                {
                    $success = link( $fullpath, $metatempdir."/$entry" );
                    #printLog($self->{LOG}, $self->vblevel(), LOG_DEBUG, "LINK: $fullpath, $metatempdir/$entry");
                }
                if(!$success)
                {
                    File::Copy::copy( $fullpath, $metatempdir."/$entry" ) or do
                    {
                        printLog($self->{LOG}, $self->vblevel(), LOG_ERROR, "copy metadata failed: $!");
                        $self->{STATISTIC}->{ERROR} += 1;
                        closedir(DIR);
                        return $self->{STATISTIC}->{ERROR};
                    };
                    #printLog($self->{LOG}, $self->vblevel(), LOG_DEBUG, "COPY: $fullpath, $metatempdir/$entry");
                }
            }
        }
        closedir(DIR);
    }

    my $resource = $job->localFileLocation();
    $job->remoteFileLocation($resource);
    $resource =~ s/repodata/.repodata/;
    $job->localFileLocation($resource);

    my $result = $job->mirror();
    $self->job2statistic($job);

    $job = SMT::Mirror::Job->new(vblevel => $self->vblevel(), useragent => $self->{USERAGENT}, log => $self->{LOG},
                                 dbh => $self->{DBH}, nohardlink => $self->{NOHARDLINK}, dryrun => $dryrun );
    $job->uri( $self->uri() );
    $job->localBasePath( $self->localBasePath() );
    $job->localRepoPath( $self->localRepoPath() );
    $job->remoteFileLocation("repodata/repomd.xml.asc");
    $job->localFileLocation(".repodata/repomd.xml.asc" );

    # if modified return undef, the file might not exist on the server
    # This is ok, signed repodata are not mandatory. So we do not try
    # to mirror it
    if( defined $job->modified(1) )
    {
        $self->{JOBS}->{".repodata/repomd.xml.asc"} = $job;
    }

    $job = SMT::Mirror::Job->new(vblevel => $self->vblevel(), useragent => $self->{USERAGENT}, log => $self->{LOG},
                                 dbh => $self->{DBH}, nohardlink => $self->{NOHARDLINK}, dryrun => $dryrun );
    $job->uri( $self->uri() );
    $job->localBasePath( $self->localBasePath() );
    $job->localRepoPath( $self->localRepoPath() );
    $job->remoteFileLocation("repodata/repomd.xml.key");
    $job->localFileLocation(".repodata/repomd.xml.key" );

    # if modified return undef, the file might not exist on the server
    # This is ok, signed repodata are not mandatory. So we do not try
    # to mirror it
    if( defined $job->modified(1) )
    {
        $self->{JOBS}->{".repodata/repomd.xml.key"} = $job;
    }


    # we ignore errors. The code work also without this variable set
    # create a hash with filename => checksum
    if ( defined $self->{DBH} )
    {
        my $statement = sprintf("SELECT localpath, checksum, checksum_type from RepositoryContentData where localpath like %s",
                                $self->{DBH}->quote($self->fullLocalRepoPath()."%"));
        $self->{EXISTS} = $self->{DBH}->selectall_hashref($statement, 'localpath');
        #printLog($self->{LOG}, $self->vblevel(), LOG_DEBUG, "STATEMENT: $statement \n DUMP: ".Data::Dumper->Dump([$self->{EXISTS}]));
    }

    my $p = SMT::Parser::RpmMdRepomd->new(log => $self->{LOG},
                                          vblevel => $self->vblevel());
    $p->resource($self->fullLocalRepoPath());
    my $repomd = $p->parse(".repodata/repomd.xml");

    # parse it and find more resources
    # download metadata right away and enqueue the rest of the files for later download
    my $parser = SMT::Parser::RpmMdLocation->new(log => $self->{LOG}, vblevel => $self->vblevel() );
    $parser->resource($self->fullLocalRepoPath());
    $parser->specialmdlocation(1);
    my $err = $parser->parse(".repodata/repomd.xml", sub { download_handler($self, $dryrun, @_)});
    $self->{STATISTIC}->{ERROR} += $err;

    $self->{EXISTS} = undef;

    #
    # parse old and new patch metadata
    #

    my $newpatches;
    my $oldpatches;
    my $pkgstoremove;

    # to store the new (filtered) repodata
    $self->{TMPDIR} = my $tmpdir = tempdir(CLEANUP => 1);

    # updateinfo.xml.gz file path
    my $olduifname = $self->fullLocalRepoPath().'/.'.$repomd->{data}->{updateinfo}->{location}->{href};

    # with filtering (will generate new metadata later)
    if (defined $self->{FILTER} && !$self->{FILTER}->empty() && -e $olduifname)
    {
        # new updateinfo.xml file path
        my $uifname = "$tmpdir/updateinfo.xml";

        # open file to write the new updateinfo.xml
        my $out = new IO::File();
        $out->open("> $uifname") or do {
            printLog($self->{LOG}, $self->vblevel(), LOG_ERROR,
                "Cannot open $uifname for reading.");
            return $self->{STATISTIC}->{ERROR}++;
        };
        printLog($self->{LOG}, $self->vblevel(), LOG_DEBUG,
            "Going to look for and parse new patch metadata.");

        # parse with filter and writer
        my $parsenew = SMT::Parser::RpmMdPatches->new(
            log => $self->{LOG}, vblevel => $self->vblevel(),
            filter => $self->{FILTER},
            savefiltered => 1,
            savepackages => 1,
            out => $out);
        $parsenew->resource($self->fullLocalRepoPath());
        $parsenew->specialmdlocation(1);
        $newpatches = $parsenew->parse(
            ".repodata/updateinfo.xml.gz", ".repodata/patches.xml" );
        $pkgstoremove = $parsenew->filteredpkgs();

        printLog($self->{LOG}, $self->vblevel(), LOG_DEBUG,
            "Going to look for and parse old patch metadata.");

        # parse the original metadata with the filter
        my $parseorig = SMT::Parser::RpmMdPatches->new(
            log => $self->{LOG}, vblevel => $self->vblevel(),
            filter => $self->{FILTER});
        $parseorig->resource($self->fullLocalRepoPath());
        $oldpatches = $parseorig->parse(
            "repodata/updateinfo.xml.gz", "repodata/patches.xml" );

        $out->flush();

        # compare checksums of old updateinfo & tmpfile

        # new checksum
        open(FILE, "< $uifname");
        my $sha1 = Digest::SHA1->new;
        $sha1->addfile(*FILE);
        my $digest = $sha1->hexdigest();
        close FILE;

        printLog($self->{LOG}, $self->vblevel(), LOG_DEBUG2,  sprintf("new checksum %s", $digest ), 1);

        # unzip the old file
        my $olddigest = 0;
        if (defined open(FILE, "> $uifname.old"))
        {
            my $fh = IO::Zlib->new($olduifname, "rb");
            print FILE while <$fh>;
            $fh->close;
            close FILE;

            # old checksum
            if (defined open(FILE, "< $uifname.old"))
            {
                $sha1 = Digest::SHA1->new;
                $sha1->addfile(*FILE);
                $olddigest = $sha1->hexdigest();
                close FILE;
            }
        }

        printLog($self->{LOG}, $self->vblevel(), LOG_DEBUG2,  sprintf("old checksum %s", $olddigest ), 1);

        # if checksums differ, overwrite the old updateinfo & update repomd later
        if (not $digest eq $olddigest)
        {
            #for (keys %{$self->{MDFILES}}) { if ($_ =~ /updateinfo.*xml/) { $mdkey = $_; last }}
            $self->{MDFILES}->{'repodata/updateinfo.xml.gz'}->{changednew} = $uifname;
            $self->{MDFILES}->{'repodata/updateinfo.xml.gz'}->{changedorig} = $olduifname;
        }
    }
    # without filtering (metadata stay untouched)
    else
    {
        my $parsenew = SMT::Parser::RpmMdPatches->new(
            log => $self->{LOG}, vblevel => $self->vblevel());
        $parsenew->resource($self->fullLocalRepoPath());
        $parsenew->specialmdlocation(1);
        $newpatches = $parsenew->parse(
            ".repodata/updateinfo.xml.gz", ".repodata/patches.xml" );

        my $parseorig = SMT::Parser::RpmMdPatches->new(
            log => $self->{LOG}, vblevel => $self->vblevel());
        $parseorig->resource($self->fullLocalRepoPath());
        $oldpatches = $parseorig->parse(
            "repodata/updateinfo.xml.gz", "repodata/patches.xml" );
    }

    #
    # create a list of new patches (the diff of before and after mirroring)
    #

    my $pid;
    foreach $pid (keys %{$oldpatches})
    {
        if( exists $newpatches->{$pid} )
        {
            delete $newpatches->{$pid};
        }
    }

    foreach $pid (keys %{$newpatches})
    {
        if($newpatches->{$pid}->{type} eq "security")
        {
            $self->{STATISTIC}->{NEWSECPATCHES} += 1;
            push @{$self->{STATISTIC}->{NEWSECTITLES}}, $newpatches->{$pid}->{title};
        }
        elsif($newpatches->{$pid}->{type} eq "recommended")
        {
            $self->{STATISTIC}->{NEWRECPATCHES} += 1;
            push @{$self->{STATISTIC}->{NEWRECTITLES}}, $newpatches->{$pid}->{title};
        }
    }

    # save the new patches for newpatches() function
    $self->{NEWPATCHES} = $newpatches;

    #
    # remove unwanted packages from metadata and the download queue
    # ($self->{JOBS})
    #

    if (defined $pkgstoremove && @$pkgstoremove)
    {
        if (!$self->removePackages($pkgstoremove, $self->{MDFILES}))
        {
            printLog($self->{LOG}, $self->vblevel(), LOG_ERROR,
                'Failed to remove filtered packages from the repository.');
            $self->{STATISTIC}->{ERROR}++;
        }
    }

    #
    # update repomd.xml with changed metadata files
    #

    my $repodatadir = $self->fullLocalRepoPath() . '/.repodata';
    if ($self->metadataChanged($self->{MDFILES}) &&
        $self->updateRepomd($self->{MDFILES}, $repodatadir))
    {
        # re-sign the repo
        $self->signrepo(
            $self->fullLocalRepoPath()."/.repodata/", $keyid, $keypass);

        # remove the signature and key file (we've got our own)
        # from download queue to avoid overwriting (bnc #560823)
        my @toremove = ('.repodata/repomd.xml.asc', '.repodata/repomd.xml.key');
        foreach my $file (@toremove)
        {
            next if (not exists $self->{JOBS}->{$file});
            delete $self->{JOBS}->{$file};
            printLog($self->{LOG}, $self->vblevel(), LOG_DEBUG,
                "Removing download job $file");
        }
    }

    #
    # execute enqueued jobs (download the files)
    #

    printLog($self->{LOG}, $self->vblevel(), LOG_INFO2,
        'Finished downloading and parsing the metadata, going to download the rest of the files...');
    foreach my $r ( sort keys %{$self->{JOBS}})
    {
        if( $dryrun )
        {
            #
            # we have here only outdated files, so dryrun can display them all as "New File"
            #
            printLog($self->{LOG}, $self->vblevel(), LOG_INFO2,
                sprintf("N %s", $self->{JOBS}->{$r}->fullLocalPath()));
            $self->{STATISTIC}->{DOWNLOAD} += 1;

            next;
        }

        my $mres = $self->{JOBS}->{$r}->mirror();
        $self->job2statistic($self->{JOBS}->{$r});
    }


    #
    # if no error happens copy .repodata to repodata
    #
    if(!$dryrun && $self->{STATISTIC}->{ERROR} == 0 && -d $job->fullLocalRepoPath()."/.repodata")
    {
        if( -d $job->fullLocalRepoPath()."/.old.repodata")
        {
            rmtree($job->fullLocalRepoPath()."/.old.repodata", 0, 0);
        }
        my $success = 1;
        if( -d $job->fullLocalRepoPath()."/repodata" )
        {
            $success = rename( $job->fullLocalRepoPath()."/repodata", $job->fullLocalRepoPath()."/.old.repodata");
            if(!$success)
            {
                printLog($self->{LOG}, $self->vblevel(), LOG_ERROR, sprintf(__("Cannot rename directory '%s'"), $job->fullLocalRepoPath()."/repodata"));
                $self->{STATISTIC}->{ERROR} += 1;
            }
        }
        if($success)
        {
            # unlink repodata before moving .repodata to repodata - any changed
            # metadata would otherwise overwrite the original file if hardlinked
            # from elsewhere
            rmtree($job->fullLocalRepoPath()."/repodata", 0, 0);

            $success = rename( $job->fullLocalRepoPath()."/.repodata", $job->fullLocalRepoPath()."/repodata");
            if(!$success)
            {
                printLog($self->{LOG}, $self->vblevel(), LOG_ERROR, sprintf(__("Cannot rename directory '%s'"), $job->fullLocalRepoPath()."/.repodata"));
                $self->{STATISTIC}->{ERROR} += 1;
            }
            else
            {
                # Now store the repodata jobs into the database. We know, that they are now at the
                # correct/final place and all modification happens
                foreach my $key (keys %{$self->{REPODATAJOBS}})
                {
                    my $rjob = $self->{REPODATAJOBS}->{$key};
                    # change .repodata => repodata
                    $rjob->localFileLocation( $rjob->remoteFileLocation() );
                    $rjob->checksum( $rjob->realchecksum($rjob->checksum_type()) );
                    $rjob->updateDB();
                }
            }
        }
    }

    if( !$dryrun && $self->{STATISTIC}->{ERROR} == 0 )
    {
        if($self->parsePatchData())
        {
            $self->{STATISTIC}->{ERROR} += 1;
        }
    }

    if( $dryrun )
    {
        rmtree( $metatempdir, 0, 0 );

        printLog($self->{LOG}, $self->vblevel(), LOG_INFO1, sprintf(__("=> Finished dryrun '%s'"), $saveuri)) if(!$isYum);
        printLog($self->{LOG}, $self->vblevel(), LOG_INFO1, sprintf(__("=> Files to download           : %s"), $self->{STATISTIC}->{DOWNLOAD})) if(!$isYum);
    }
    else
    {
        printLog($self->{LOG}, $self->vblevel(), LOG_INFO1, sprintf(__("=> Finished mirroring '%s'"), $saveuri)) if(!$isYum);
        printLog($self->{LOG}, $self->vblevel(), LOG_INFO1, sprintf(__("=> Total files                 : %s"), $self->{STATISTIC}->{TOTALFILES})) if(!$isYum);
        printLog($self->{LOG}, $self->vblevel(), LOG_INFO1, sprintf(__("=> Total transferred files     : %s"), $self->{STATISTIC}->{DOWNLOAD})) if(!$isYum);
        printLog($self->{LOG}, $self->vblevel(), LOG_INFO1, sprintf(__("=> Total transferred file size : %s bytes (%s)"),
                                                                    $self->{STATISTIC}->{DOWNLOAD_SIZE}, SMT::Utils::byteFormat($self->{STATISTIC}->{DOWNLOAD_SIZE}))) if(!$isYum);
        printLog($self->{LOG}, $self->vblevel(), LOG_INFO1, sprintf(__("=> Total linked files          : %s"), $self->{STATISTIC}->{LINK})) if(!$isYum);
        printLog($self->{LOG}, $self->vblevel(), LOG_INFO1, sprintf(__("=> Total copied files          : %s"), $self->{STATISTIC}->{COPY})) if(!$isYum);
        printLog($self->{LOG}, $self->vblevel(), LOG_INFO1, sprintf(__("=> Files up to date            : %s"), $self->{STATISTIC}->{UPTODATE})) if(!$isYum);
    }

    printLog($self->{LOG}, $self->vblevel(), LOG_INFO1, sprintf(__("=> Errors                      : %s"), $self->{STATISTIC}->{ERROR})) if(!$isYum);
    printLog($self->{LOG}, $self->vblevel(), LOG_INFO1, sprintf(__("=> Mirror Time                 : %s"), SMT::Utils::timeFormat(tv_interval($t0)))) if(!$isYum);

    printLog($self->{LOG}, $self->vblevel(), LOG_INFO1, sprintf(__("=> New security updates        : %s"), $self->{STATISTIC}->{NEWSECPATCHES})) if(!$isYum);
    foreach my $title (@{$self->{STATISTIC}->{NEWSECTITLES}})
    {
        printLog($self->{LOG}, $self->vblevel(), LOG_INFO1, sprintf(__("   * %s"), $title )) if(!$isYum);
    }
    printLog($self->{LOG}, $self->vblevel(), LOG_INFO1, sprintf(__("=> New recommended updates     : %s"), $self->{STATISTIC}->{NEWRECPATCHES})) if(!$isYum);
    foreach my $title (@{$self->{STATISTIC}->{NEWRECTITLES}})
    {
        printLog($self->{LOG}, $self->vblevel(), LOG_INFO1, sprintf(__("   * %s"), $title )) if(!$isYum);
    }

    printLog($self->{LOG}, $self->vblevel(), LOG_INFO1, "", 1, 0) if(!$isYum);

    return $self->{STATISTIC}->{ERROR};
}


=item clean()

Deletes all files not referenced in the rpmmd resource chain

=cut
sub clean()
{
    my $self = shift;
    my $isYum = (ref($self) eq "SMT::Mirror::Yum");

    my $t0 = [gettimeofday] ;

    if ( ! -d $self->fullLocalRepoPath() )
    {
        printLog($self->{LOG}, $self->vblevel(), LOG_ERROR, sprintf(__("Destination '%s' does not exist"), $self->fullLocalRepoPath() ));
        return;
    }

    printLog($self->{LOG}, $self->vblevel(), LOG_INFO1, sprintf(__("Cleaning:         %s"), $self->fullLocalRepoPath() ) ) if(!$isYum);

    # algorithm

    find ( { wanted =>
             sub
             {
                 if ( $File::Find::dir !~ /\/headers/ && -f $File::Find::name )
                 {
                     my $name = SMT::Utils::cleanPath($File::Find::name);

                     $self->{CLEANLIST}->{$name} = 1;
                 }
             }
             , no_chdir => 1 }, $self->fullLocalRepoPath() );

    my $parser = SMT::Parser::RpmMdLocation->new(log => $self->{LOG}, vblevel => $self->vblevel() );
    $parser->resource($self->fullLocalRepoPath());
    $parser->parse("/repodata/repomd.xml", sub { clean_handler($self, @_)});

    my $path = SMT::Utils::cleanPath($self->fullLocalRepoPath(), "/repodata/repomd.xml");

    delete $self->{CLEANLIST}->{$path} if (exists $self->{CLEANLIST}->{$path});
    delete $self->{CLEANLIST}->{$path.".asc"} if (exists $self->{CLEANLIST}->{$path.".asc"});;
    delete $self->{CLEANLIST}->{$path.".key"} if (exists $self->{CLEANLIST}->{$path.".key"});;

    my $cnt = 0;
    foreach my $file ( keys %{$self->{CLEANLIST}} )
    {
        printLog($self->{LOG}, $self->vblevel(), LOG_DEBUG, "Delete: $file");
        $cnt += unlink $file;

        $self->{DBH}->do(sprintf("DELETE from RepositoryContentData where localpath = %s", $self->{DBH}->quote($file) ) );
    }

    printLog($self->{LOG}, $self->vblevel(), LOG_INFO1, sprintf(__("Finished cleaning: '%s'"), $self->fullLocalRepoPath() )) if(!$isYum);
    printLog($self->{LOG}, $self->vblevel(), LOG_INFO1, sprintf(__("=> Removed files : %s"), $cnt)) if(!$isYum);
    printLog($self->{LOG}, $self->vblevel(), LOG_INFO1, sprintf(__("=> Clean Time    : %s"), SMT::Utils::timeFormat(tv_interval($t0)))) if(!$isYum);
    printLog($self->{LOG}, $self->vblevel(), LOG_INFO1, "", 1, 0) if(!$isYum);
}


=item verify([%params])

 $mirror->verify();

 Returns 1 (true), if the repo is valid, otherwise 0 (false).

=over 4

=item removeinvalid

If set to 1, invalid files are removed from the local harddisk.

=item quiet

If set to 1, no reports are printed.

=back

=cut

sub verify()
{
    my $self = shift;
    my %options = @_;

    my $t0 = [gettimeofday] ;

    # if path was not defined, we can use last
    # mirror destination dir
    if ( ! -d $self->fullLocalRepoPath() )
    {
        printLog($self->{LOG}, $self->vblevel(), LOG_ERROR, sprintf(__("Destination '%s' does not exist"), $self->fullLocalRepoPath() ));
        $self->{STATISTIC}->{ERROR} += 1;
        return ($self->{STATISTIC}->{ERROR} == 0);
    }

    # remove invalid packages?
    my $removeinvalid = 0;
    $removeinvalid = 1 if ( exists $options{removeinvalid} && $options{removeinvalid} );

    my $quiet = 0;
    $quiet = 1 if( exists $options{quiet} && defined $options{quiet} && $options{quiet} );

    printLog($self->{LOG}, $self->vblevel(), LOG_INFO1, sprintf(__("Verifying: %s"), $self->fullLocalRepoPath() )) if(!$quiet);

    $self->{STATISTIC}->{ERROR} = 0;

    # parse it and find more resources
    my $parser = SMT::Parser::RpmMdLocation->new(log => $self->{LOG}, vblevel => $self->vblevel() );
    $parser->resource( $self->fullLocalRepoPath() );
    $parser->parse("repodata/repomd.xml", sub { verify_handler($self, @_)});

    my $job;
    my $cnt = 0;
    foreach (sort keys %{$self->{VERIFYJOBS}} )
    {
        $job = $self->{VERIFYJOBS}->{$_};

        my $ok = ( (-e $job->fullLocalPath()) && $job->verify());
        $cnt++;
        if ($ok || ($job->localFileLocation() =~ /repomd\.xml$/ ) )
        {
            printLog($self->{LOG}, $self->vblevel(), LOG_DEBUG, "Verify: ". $job->fullLocalPath() . ": OK");
        }
        else
        {
            if(!-e $job->fullLocalPath())
            {
                printLog($self->{LOG}, $self->vblevel(), LOG_ERROR, "Verify: ". $job->fullLocalPath() . ": FAILED ( file not found )");
            }
            else
            {
                printLog($self->{LOG}, $self->vblevel(), LOG_ERROR, "Verify: ". $job->fullLocalPath() .
                         ": ".sprintf("FAILED ( %s vs %s )", $job->checksum(), $job->realchecksum($job->checksum_type())));
                if ($removeinvalid)
                {
                    printLog($self->{LOG}, $self->vblevel(), LOG_DEBUG, sprintf(__("Deleting %s"), $job->fullLocalPath()));
                    unlink($job->fullLocalPath());
                }
            }

            if (defined $self->{DBH})
            {
                $self->{DBH}->do(sprintf("DELETE from RepositoryContentData where localpath = %s", $self->{DBH}->quote($job->fullLocalPath() ) ) );
            }

            $self->{STATISTIC}->{ERROR} += 1;
        }
    }

    if( !$quiet )
    {
        printLog($self->{LOG}, $self->vblevel(), LOG_INFO1, sprintf(__("=> Finished verifying: %s"), $self->fullLocalRepoPath() ));
        printLog($self->{LOG}, $self->vblevel(), LOG_INFO1, sprintf(__("=> Files             : %s"), $cnt ));
        printLog($self->{LOG}, $self->vblevel(), LOG_INFO1, sprintf(__("=> Errors            : %s"), $self->{STATISTIC}->{ERROR} ));
        printLog($self->{LOG}, $self->vblevel(), LOG_INFO1, sprintf(__("=> Verify Time       : %s"), SMT::Utils::timeFormat(tv_interval($t0)) ));
        printLog($self->{LOG}, $self->vblevel(), LOG_INFO1, "\n");
    }

    return ($self->{STATISTIC}->{ERROR} == 0);
}


sub clean_handler
{
    my $self = shift;
    my $data = shift;

    if(exists $data->{LOCATION} && defined $data->{LOCATION} &&
       $data->{LOCATION} ne "" )
    {
        # get the repository index
        my $resource = SMT::Utils::cleanPath($self->fullLocalRepoPath(), $data->{LOCATION});

        # if this path is in the CLEANLIST, delete it
        delete $self->{CLEANLIST}->{$resource} if (exists $self->{CLEANLIST}->{$resource});
    }
}


sub download_handler
{
    my $self   = shift;
    my $dryrun = shift;
    my $data   = shift;

    my $invalidFile = 0;

    if(exists $data->{LOCATION} && defined $data->{LOCATION} &&
       $data->{LOCATION} ne "" && !exists $self->{JOBS}->{$data->{LOCATION}})
    {
        if(!$self->{MIRRORSRC} && exists $data->{ARCH} && defined $data->{ARCH} && lc($data->{ARCH}) eq "src")
        {
            # we do not want source rpms - skip
            printLog($self->{LOG}, $self->vblevel(), LOG_DEBUG, "Skip source RPM: ".$data->{LOCATION});

            return;
        }

        # save locations of metadata files found in repomd.xml's <data> elements
        if ($data->{MAINELEMENT} eq 'data')
        {
            my $locationKey = $data->{LOCATION};
            $locationKey =~ s/^(repodata\/)[0-9a-f]*-(.+)$/$1$2/;
            $self->{MDFILES}->{$locationKey} = undef;
        }

        # get the repository index
        my $job = SMT::Mirror::Job->new(vblevel => $self->vblevel(), useragent => $self->{USERAGENT}, log => $self->{LOG},
                                        dbh => $self->{DBH}, nohardlink => $self->{NOHARDLINK}, dryrun => $dryrun );
        $job->uri( $self->{URI} );
        $job->localBasePath( $self->localBasePath() );
        $job->localRepoPath( $self->localRepoPath() );
        $job->localFileLocation( $data->{LOCATION} );
        $job->checksum( $data->{CHECKSUM} );
        $job->checksum_type( $data->{CHECKSUM_TYPE} );

        if( exists $self->{EXISTS}->{$job->fullLocalPath()} &&
            $self->{EXISTS}->{$job->fullLocalPath()}->{checksum} eq $data->{CHECKSUM} &&
            $self->{EXISTS}->{$job->fullLocalPath()}->{checksum_type} eq $data->{CHECKSUM_TYPE} &&
            -e $job->fullLocalPath() )
        {
            # file exists and is up-to-date.
            # with deepverify call a verify
            if( $self->deepverify() && !$job->verify() )
            {
                #printLog($self->{LOG}, $self->vblevel(), LOG_DEBUG, "deepverify: verify failed");
                unlink ( $job->fullLocalPath() ) if( !$dryrun );
            }
            else
            {
                printLog($self->{LOG}, $self->vblevel(), LOG_DEBUG, sprintf("U %s", $job->fullLocalPath() ));
                $self->{STATISTIC}->{UPTODATE} += 1;
                return;
            }
        }
        elsif( ! exists $self->{EXISTS}->{$job->fullLocalPath()} && -e $job->fullLocalPath() )
        {
            # file exists but is not in the database. Check if it is valid.
            if( $job->verify() )
            {
                # File is ok, so update the database and go to the next file
                $job->updateDB();
                printLog($self->{LOG}, $self->vblevel(), LOG_DEBUG, sprintf("U %s", $job->fullLocalPath() ));
                $self->{STATISTIC}->{UPTODATE} += 1;
                return;
            }
            else
            {
                # hmmm, invalid. Remove it if we are not in dryrun mode
		$invalidFile = 1 if( !$dryrun );
            }
        }
        elsif( -e $job->fullLocalPath() )
        {
            # wrong checksum. Can happen in the repodata case. Same filename with new checksum.
            $invalidFile = 1 if( !$dryrun );
        }

        # if it is an xml file we have to download it now and
        # process it
        # any fine in repodata needs to be donloaded here
        if (  $job->localFileLocation() =~ /(.+)\.xml(.*)/ || $data->{LOCATION} =~ /^\/?repodata\// )
        {
            # metadata! change the download area

            my $localres = $data->{LOCATION};

            $localres =~ s/repodata/.repodata/;
            $job->remoteFileLocation( $data->{LOCATION} );
            $job->localFileLocation( $localres );

	    if( $invalidFile )
	    {
                unlink ( $job->fullLocalPath() );
	    }

            # mirror it first, so we can parse it
            my $mres = $job->mirror();
            if( $mres == 2 && $self->deepverify() && !$job->verify() ) # up-to-date
            {
                # remove broken file and download it again
                unlink($job->fullLocalPath());
                $mres = $job->mirror();
            }
            $self->job2statistic($job);
            $self->{REPODATAJOBS}->{$data->{LOCATION}} = $job;
            if ($data->{MAINELEMENT} eq 'data' && lc($data->{DATATYPE}) eq "license")
            {
                $self->updateLicenseDir($job->fullLocalPath());
            }
        }
        else
        {
            # download it later
            if ( $job->localFileLocation() )
            {
                if( $invalidFile )
                {
                    unlink ( $job->fullLocalPath() );
                }
                if(!exists $self->{JOBS}->{$data->{LOCATION}})
                {
                    $self->{JOBS}->{$data->{LOCATION}} = $job;
                }
            }
            else
            {
                printLog($self->{LOG}, $self->vblevel(), LOG_ERROR, "no file location set on ".$job->fullLocalPath());
            }
        }
    }
}

sub verify_handler
{
    my $self = shift;
    my $data = shift;

    if(!$self->{MIRRORSRC} && exists $data->{ARCH} && defined $data->{ARCH} && lc($data->{ARCH}) eq "src")
    {
        # we do not want source rpms - skip
        printLog($self->{LOG}, $self->vblevel(), LOG_DEBUG, "Skip source RPM: ".$data->{LOCATION});

        return;
    }

    if(exists $data->{LOCATION} && defined $data->{LOCATION} &&
       $data->{LOCATION} ne "")
    {
        # if LOCATION has the string "repodata" we want to verify them
        # this matches also for "/.repodata/"
        # all other files (rpms) are verified only if deepverify is requested.
        if($self->deepverify() || $data->{LOCATION} =~ /repodata/)
        {
            my $job = SMT::Mirror::Job->new(vblevel => $self->vblevel(), useragent => $self->{USERAGENT}, log => $self->{LOG},
                                            dbh => $self->{DBH}, nohardlink => $self->{NOHARDLINK} );
            $job->localBasePath( $self->localBasePath() );
            $job->localRepoPath( $self->localRepoPath() );
            $job->localFileLocation( $data->{LOCATION} );
            $job->checksum( $data->{CHECKSUM} );
            $job->checksum_type( $data->{CHECKSUM_TYPE} );

            if(!exists $self->{VERIFYJOBS}->{$job->fullLocalPath()})
            {
                $self->{VERIFYJOBS}->{$job->fullLocalPath()} = $job;
            }
        }
    }
}

=item signrepo($repodatadir, [$keyid, $passphrase])

Signs the repository index file, repomd.xml using the key specified by $keyid
argument and specified $passphrase. If $keyid is not specified, the function
removes any previous signature and public key (repomd.xml.asc and
repomd.xml.key).

The function works on the repodata located at $repodatadir.

=cut
sub signrepo
{
    my ($self, $repodatadir, $keyid, $passphrase) = @_;

    if (not defined $repodatadir || not -d $repodatadir)
    {
        printLog($self->{LOG}, $self->vblevel(), LOG_ERROR,
            "Invalid repodata directory specified: $repodatadir.");
        $self->{STATISTIC}->{ERROR}++;
        return 0;
    }

    $repodatadir .= '/' if (not $repodatadir =~ /\/$/);
    my $repomdfile = $repodatadir."repomd.xml";

    if (-e "$repomdfile.asc")
    {
        unlink "$repomdfile.asc";
    }
    if (-e "$repomdfile.key")
    {
        unlink "$repomdfile.key";
    }

    if (not defined $keyid)
    {
        printLog($self->{LOG}, $self->vblevel(), LOG_INFO1,
            "No key ID given, the repository will not be signed.");
        return 1;
    }

    # sign the repomd.xml

    system('gpg', '-sab', '--batch',
        '-u', $keyid, '--passphrase', $passphrase,
        '-o', "$repomdfile.asc", $repomdfile);
    if ($? == -1)
    {
        printLog($self->{LOG}, $self->vblevel(), LOG_ERROR,
            "Failed to sign the repository: $!.");
        $self->{STATISTIC}->{ERROR}++;
        return 0;
    }
    elsif ($? >> 8 != 0 || not -e "$repomdfile.asc")
    {
        printLog($self->{LOG}, $self->vblevel(), LOG_ERROR,
            "Failed to sign the repository, gpg returned ".($? >> 8).".");
        $self->{STATISTIC}->{ERROR}++;
        return 0;
    }

    printLog($self->{LOG}, $self->vblevel(), LOG_INFO1,
        "$repomdfile has been signed.");

    # export the public signing key

    system('gpg', '--batch', '--export', '-a', '-o', "$repomdfile.key", $keyid);
    if ($? == -1 || ($? >> 8) != 0 || not -e "$repomdfile.key")
    {
        printLog($self->{LOG}, $self->vblevel(), LOG_ERROR,
            "Failed to export the repo signing key.");
        $self->{STATISTIC}->{ERROR}++;
        return 0;
    }

    printLog($self->{LOG}, $self->vblevel(), LOG_INFO1,
        "$repomdfile.key successfully generated.");

    return 1;
}


=item removePackages($pkgstoremove, $mdfiles)

Removes packages given in $pkgstoremove from primary.xml and several other
metadata files which contain additional package information like other.xml.gz,
filelists.xml.gz, and susedata.xml.gz, and from the filesystem.

Packages are not removed from the filesystem until successfully removed from
the metadata.

$pkgstoremove is a list of hashes with package data as returned
by SMT::Parser::RpmMdPatches::filteredpkgs()

$mdfiles is a hash with information about metadata files found in repository's
repomd.xml file, their changed status, etc. This method uses this info to
check whether the repository contains the metadata it is interested in and
to add information about any changed metadata files to it.

Example of input data:

 $pkgstoremove = {
     {name => 'logwatch', epo => undef, ver => '7.3.6', rel => '60.6.1', arch => 'noarch'},
    {name => 'audacity', epo => 0, ver => '1.3.5', rel => '49.12.1', arch => 'i586'}
 };

 # repository metadata info
 #
 # exists $mdfiles->{'repodata/susedata.xml.gz'} means the repository contains
 # susedata.xml.gz file
 #
 # exists $mdfiles->{'repodata/susedata.xml.gz'}->{changedorig} means
 # the susedata file has been changed, and the value is the location
 # of the original file. $mdfiles->{'repodata/susedata.xml.gz'}->{changednew}
 # then contains the path to new metadata file, non-gzipped.
 #
 $mdfiles = {
    'repodata/primary.xml.gz' => undef,
    'repodata/other.xml.gz' => undef,
    'repodata/filelists.xml.gz' => undef,
    'repodata/updateinfo.xml.gz' => {
                  'changedorig' => '/path/to/repo/.repodata/updateinfo.xml.gz',
                  'changednew' => '/tmp/yakHpx8kvP/updateinfo.xml'
                  },
    'repodata/susedata.xml.gz' => undef,
    'repodata/deltainfo.xml.gz' => undef
    };

=cut

sub removePackages($$$)
{
    my ($self, $pkgstoremove, $mdfiles) = @_;

    printLog($self->{LOG}, $self->vblevel(), LOG_DEBUG,
        'Going to remove ' . (scalar @$pkgstoremove) . ' filtered packages.');

    return 1 if (!@$pkgstoremove);

    my $errc = 0;
    my $tgtrepopath = $self->fullLocalRepoPath();

    my $p = SMT::Parser::RpmMdRepomd->new(log => $self->{LOG},
                                          vblevel => $self->vblevel());
    $p->resource($tgtrepopath);
    my $repomd = $p->parse(".repodata/repomd.xml");

    # first, remove the unwanted packages from primary.xml.gz

    # file to write the new primary.xml
    my $primarynew = SMT::Utils::cleanPath($self->{TMPDIR}, '/primary.xml');
    my $primaryfh = new IO::File();
    $primaryfh->open('>' . $primarynew);

    # update primary
    my $parser = SMT::Parser::RpmMdPrimaryFilter->new(log => $self->{LOG},
                                                      vblevel => $self->vblevel(),
                                                      out => $primaryfh);
    $parser->resource($tgtrepopath);
    $parser->specialmdlocation(1);
    $errc = $parser->parse($pkgstoremove);
    $primaryfh->close;

    if ($errc)
    {
        printLog($self->{LOG}, $self->vblevel(), LOG_ERROR,
            'Failed to remove unwanted packages from primary.xml.gz.');
        $self->{ERRORS}++;
        return 0;
    }
    else
    {
        $mdfiles->{'repodata/primary.xml.gz'}->{changednew} = "$primarynew";
        $mdfiles->{'repodata/primary.xml.gz'}->{changedorig} = $tgtrepopath."/.".$repomd->{data}->{primary}->{location}->{href};
        printLog($self->{LOG}, $self->vblevel(), LOG_DEBUG,
            'Packages successfully removed from primary.xml.gz.');
    }

    # these are packages that were actually found in primary.xml
    my $pkgsfound = $parser->found();


    # now remove corresponding package data from the following metadata files

    my %mdtoupdate = (
        'repodata/other.xml.gz' => {
            'new' => 'other.xml',
            'orig' => (exists $repomd->{data}->{other}->{location}->{href}?".".$repomd->{data}->{other}->{location}->{href}:'.repodata/other.xml.gz') },
        # this takes too long and is not used in SUSE tools (bnc #510300),
        # so we'll ignore it. Should we need it in the future, we'll need to
        # optimize.
        #
        #'repodata/filelists.xml.gz' => {
        #   'new' => 'filelists.xml',
        #   'orig' => (exists $repomd->{data}->{filelists}->{location}->{href}?".".$repomd->{data}->{filelists}->{location}->{href}:'.repodata/filelists.xml.gz') },
        'repodata/susedata.xml.gz' => {
            'new' => 'susedata.xml',
            'orig' => (exists $repomd->{data}->{susedata}->{location}->{href}?".".$repomd->{data}->{susedata}->{location}->{href}: '.repodata/susedata.xml.gz')}
        );

    foreach my $mdfile (keys %mdtoupdate)
    {
        # skip the ones which do not exist in the repo
        next if not exists $mdfiles->{$mdfile};

        # file to write the new *.xml files
        my $mdnew = SMT::Utils::cleanPath(
            $self->{TMPDIR}, $mdtoupdate{$mdfile}->{'new'});
        my $mdfh = new IO::File();
        $mdfh->open('>' . $mdnew);

        # update the *.xml
        my $parser = SMT::Parser::RpmMdOtherFilter->new(log => $self->{LOG},
                                                        vblevel => $self->{VBLEVEL});
        $parser->resource($tgtrepopath);
        $errc = $parser->parse($mdtoupdate{$mdfile}->{'orig'}, $pkgsfound, out => $mdfh);
        $mdfh->close;

        if ($errc)
        {
            printLog($self->{LOG}, $self->vblevel(), LOG_ERROR,
                sprintf (__('Failed to remove unwanted packages from \'%s\'.'), $mdfile));
            $self->{ERRORS}++;
            return 0;
        }
        else
        {
            $mdfiles->{$mdfile}->{changednew} = "$mdnew";
            $mdfiles->{$mdfile}->{changedorig} =
                SMT::Utils::cleanPath($tgtrepopath, $mdtoupdate{$mdfile}->{'orig'});
            printLog($self->{LOG}, $self->vblevel(), LOG_DEBUG,
                'Packages successfully removed from ' . $mdfile);
        }
    }

    # metadata are updated, now remove the packages from the download queue
    # and filesystem

    $tgtrepopath = $tgtrepopath . '/' if ($tgtrepopath !~ /\/$/);
    foreach my $pkg (values %$pkgsfound)
    {
        # remove from filesystem
        if (-e $tgtrepopath . $pkg->{loc})
        {
            if (not unlink $tgtrepopath . $pkg->{loc})
            {
                # No need to fail because of this; the important thing is the
                # packages were removed from the metadata. Just warn here.
                printLog($self->{LOG}, $self->vblevel(), LOG_WARN,
                    "unlink($tgtrepopath$pkg->{loc}) failed: $!");
            }
            else
            {
                $self->{DBH}->do(sprintf("DELETE from RepositoryContentData where localpath = %s",
                                          $self->{DBH}->quote($tgtrepopath.$pkg->{loc}) ) );
                printLog($self->{LOG}, $self->vblevel(), LOG_INFO2,
                    "Deleted $tgtrepopath$pkg->{loc}");
            }
        }

        #remove from download queue
        if (defined $self->{JOBS}->{$pkg->{loc}})
        {
            delete $self->{JOBS}->{$pkg->{loc}};
            printLog($self->{LOG}, $self->vblevel(), LOG_DEBUG,
                "Removing download job $pkg->{loc}");
        }
    }

    printLog($self->{LOG}, $self->vblevel(), LOG_INFO2,
        "All filtered packages successfully removed.");

    return 1;
}


=item metadataChanged($mdfiles)

Whether the $mdfiles hash indicates that some of the metadata files have been
changend.

See updateRepomd() for details on the $mdfiles structure.
=cut

sub metadataChanged()
{
    my ($self, $mdfiles) = @_;
    for (values %$mdfiles)
    {
        return 1 if (defined $_->{changednew});
    }
    return 0;
}


=item updateRepomd($mdfiles, $repodatadir)

Updates repository with changed metadata files described in $mdfiles.
The method uses modifyrepo utility to update repomd.xml and put gzipped metadata
files into the repository's metadata directory pointed to by $repodatadir.

Example of input data:

 # repository metadata info
 #
 # exists $mdfiles->{'repodata/susedata.xml.gz'} means the repository contains
 # susedata.xml.gz file
 #
 # exists $mdfiles->{'repodata/susedata.xml.gz'}->{changedorig} means
 # the susedata file has been changed, and the value is the location
 # of the original file. $mdfiles->{'repodata/susedata.xml.gz'}->{changednew}
 # then contains the path to new metadata file, non-gzipped.
 #
 $mdfiles = {
    'repodata/primary.xml.gz' => {
                  'changedorig' => '/path/to/repo/.repodata/primary.xml.gz',
                  'changednew'  => '/tmp/yakHpx8kvP/primary.xml'
                  },
    'repodata/other.xml.gz' => undef,
    'repodata/filelists.xml.gz' => undef,
    'repodata/updateinfo.xml.gz' => {
                  'changedorig' => '/path/to/repo/.repodata/updateinfo.xml.gz',
                  'changednew' => '/tmp/yakHpx8kvP/updateinfo.xml'
                  },
    'repodata/susedata.xml.gz' => undef,
    'repodata/deltainfo.xml.gz' => undef
    };

 $repodatadir = '/path/to/repo/.repodata/';


NOTE: Another alternative would be to use createrepo (see below) to update
primary/other/filelists, but that would be slow, and we'd still need to
parse primary.xml and deal with susedata.xml. So removing the package data
from the files by ourselves seems to be better approach.

# write output to tmpdir, then copy to .repodata
# createrepo --update <repobase> --outputdir $tmpdir $self->fullLocalRepoPath()
=cut

sub updateRepomd($$$)
{
    my ($self, $mdfiles, $repodatadir) = @_;

    my $modifyrepopath = '/usr/bin/modifyrepo';
    # my $createrepopath = '/usr/bin/createrepo';

    # unlink the original repomd.xml first to avoid modifying the original
    # repomd.xml on the source URI if hardlinked from elsewhere
    my $repomdpath = SMT::Utils::cleanPath($repodatadir, 'repomd.xml');
    copy($repomdpath, "$repomdpath.tmp");
    unlink ($repomdpath);
    rename("$repomdpath.tmp", $repomdpath);

    my $errc = 0;

    # update changed metadata files in repomd.xml
    foreach my $key (keys %$mdfiles)
    {
	my $mdfile = $mdfiles->{$key};
        # skip unchanged files
        next if not exists $mdfile->{changednew};

        # unlink the original file first - we do not want to modify all the
        # aliases with modifyrepo
        unlink ($mdfile->{changedorig});
        unlink (SMT::Utils::cleanPath($repodatadir, basename($key)));

        # note: modifyrepo needs unzipped unpdateinfo.xml
        my @args = ($mdfile->{changednew}, $repodatadir);
        my ($exitcode, $out, $err) =
            SMT::Utils::executeCommand(
                {log => $self->{LOG}, vblevel => $self->vblevel()},
                $modifyrepopath, @args);

        $errc++ if ($exitcode || $exitcode == -1);

        if( ! exists $self->{REPODATAJOBS}->{$key} )
        {
            # create a repodata job to update the checksum in DB
            my $job = SMT::Mirror::Job->new(vblevel => $self->vblevel(), useragent => $self->{USERAGENT}, log => $self->{LOG},
                                            dbh => $self->{DBH}, nohardlink => $self->{NOHARDLINK} );
            $job->uri( $self->{URI} );
            $job->localBasePath( $self->localBasePath() );
            $job->localRepoPath( $self->localRepoPath() );
            $job->localFileLocation( $key );
            $job->checksum_type( 'sha1' );
            $job->checksum( $job->realchecksum() );
            $self->{REPODATAJOBS}->{$key} = $job;
        }
    }

    return 0 if ($errc);
    return 1;
}

=item parsePatchData()

Parse and save Patch Data

=cut

sub parsePatchData
{
    my $self = shift;

    # We do not say, that this is an error, because DB is not
    # available in db replacemant file case
    return 0 if(!$self->{DBH} || !$self->{CFG} || !$self->{REPOID});

    eval
    {
        printLog ($self->{LOG}, $self->vblevel(), LOG_DEBUG,
                  "Checking for patches in this repository...", 0, 1);

        my $parser = SMT::Parser::RpmMdPatches->new(
            log => $self->{LOG}, vblevel => $self->vblevel());
        $parser->resource($self->fullLocalRepoPath());

        my $patches = $parser->parse(
            "repodata/updateinfo.xml.gz", "repodata/patches.xml");
        # fetch old patch data for this repo from DB
        my $oldpatches = SMT::Patch::findByRepoId($self->{DBH}, $self->{REPOID});

        if (keys %$patches)
        {
            printLog ($self->{LOG}, $self->vblevel(), LOG_INFO1,
                      "Updating patch data in the database (" . (keys %$patches) . " patches)", 0, 1);
        }
        else
        {
            printLog ($self->{LOG}, $self->vblevel(), LOG_DEBUG,
                      "No patches found. Will remove any patches from this repo from the database..", 0, 1);
        }

        foreach my $pdata (values %$patches)
        {
            # set package location from patch package data

            # the full locations could be computed in the Package
            # module itself had the Repositories module been
            # redesigned into a Repository module with appropriate
            # class and object methods which would allow create
            # instances with or without database.
            # That way the Repository instance could be passed to
            # the patch bellow and/or loaded from DB as needed and
            # the instance would have knowledge about EXTURL, local
            # smt URL, mirroring/staging paths, etc.

            # without it, computing the paths here and storing them
            # in the DB seems to be the cleanest approach, even at
            # the cost of creating a lot of reduncancy in the DB
            foreach my $pkg (@{$pdata->{pkgs}})
            {
                my $rpmname = $pkg->{name} . '-' . $pkg->{ver} . '-'
                    . $pkg->{rel} . '.' . $pkg->{arch} . '.rpm';

                # location of the rpm on the SMT sever
                $pkg->{loc} = $self->{CFG}->val('LOCAL', 'url')
                    .SMT::Utils::cleanPath('repo', $self->localRepoPath(),
                                           'rpm', $pkg->{arch}, $rpmname);

                # location of the rpm in the original repo
                $pkg->{extloc} = SMT::Utils::getSaveUri($self->{URI})
                                . SMT::Utils::cleanPath(
                                    'rpm',
                                    $pkg->{arch},
                                    $rpmname);
            }

            my $patchid = $pdata->{name} . ':' . $pdata->{version};
            my $patch = $oldpatches->{$patchid};
            $patch = SMT::Patch::new() if (not $patch);
            $patch->setFromHash($pdata);
            $patch->repoId($self->{REPOID});
            $patch->save($self->{DBH});
            # delete old patch found in newly parsed patches to
            # remove the rest after the loop
            delete $oldpatches->{$patchid};
        }
        # Remove old patches not found in repo anymore. This should
        # not happen given incremental updates, but just in case.
        foreach my $patch (values %$oldpatches)
        {
            $patch->delete($self->{DBH});
        }
    };
    if ($@)
    {
        printLog ($self->{LOG}, $self->vblevel(), LOG_ERROR,
                  "Error getting patch data from repository: $@", 0, 1);
        return 1;
    }
    return 0;
}


=back

=head1 AUTHOR

dmacvicar@suse.de, mc@suse.de, jkupec@suse.cz

=head1 COPYRIGHT

Copyright 2007-2012 SUSE LINUX Products GmbH, Nuernberg, Germany.

=cut


1;  # so the require or use succeeds

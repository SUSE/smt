package SMT::Mirror::RpmMd;
use strict;

use LWP::UserAgent;
use URI;
use File::Path;
use File::Find;
use Crypt::SSLeay;
use IO::Zlib;
use Time::HiRes qw(gettimeofday tv_interval);
use Digest::SHA1  qw(sha1 sha1_hex);

use SMT::Mirror::Job;
use SMT::Parser::RpmMd;
use SMT::Utils;


# constructor
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


    $self->{JOBS}   = {};
    $self->{VERIFYJOBS}   = {};
    $self->{CLEANLIST} = {};

    $self->{STATISTIC}->{DOWNLOAD} = 0;
    $self->{STATISTIC}->{UPTODATE} = 0;
    $self->{STATISTIC}->{ERROR}    = 0;
    $self->{STATISTIC}->{DOWNLOAD_SIZE} = 0;

    $self->{DEBUG} = 0;
    $self->{LOG}   = undef;
    $self->{MIRRORSRC} = 1;
    $self->{DEEPVERIFY}   = 0;
    $self->{DBH} = undef;
    
    
    # Do _NOT_ set env_proxy for LWP::UserAgent, this would break https proxy support
    $self->{USERAGENT}  = SMT::Utils::createUserAgent(keep_alive => 1);

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

sub localBasePath
{
    my $self = shift;
    if (@_) { $self->{LOCALBASEPATH} = shift }
    return $self->{LOCALBASEPATH};
}

sub localRepoPath
{
    my $self = shift;
    if (@_) { $self->{LOCALREPOPATH} = shift }
    return $self->{LOCALREPOPATH};
}

sub fullLocalRepoPath
{
    my $self = shift;
    
    return SMT::Utils::cleanPath($self->localBasePath(), $self->localRepoPath());
}


sub deepverify
{
    my $self = shift;
    if (@_) { $self->{DEEPVERIFY} = shift }
    return $self->{DEEPVERIFY};
}

# database handle
sub dbh
{
    my $self = shift;
    if (@_) { $self->{DBH} = shift }
    
    return $self->{DBH};
}

sub statistic
{
    my $self = shift;
    return $self->{STATISTIC};
}

sub debug
{
    my $self = shift;
    if (@_) { $self->{DEBUG} = shift }
    
    return $self->{DEBUG};
}


# mirrors the repository to destination
sub mirrorTo()
{
    my $self = shift;
    my %options = @_;
    my $dryrun  = 0;
    $dryrun = 1 if(exists $options{dryrun} && defined $options{dryrun} && $options{dryrun});
    
    my $dest = $self->fullLocalRepoPath();
   
    if ( ! -d $dest )
    { 
        die $dest . " does not exist"; 
    }
    if ( !defined $self->uri() || $self->uri() !~ /^http/ )
    {
        die "Invalid URL: ".$self->uri();
    }
    
    my $t0 = [gettimeofday] ;
    
    # reset the counter
    $self->{STATISTIC}->{ERROR}         = 0;
    $self->{STATISTIC}->{UPTODATE}      = 0;
    $self->{STATISTIC}->{DOWNLOAD}      = 0;
    $self->{STATISTIC}->{DOWNLOAD_SIZE} = 0;

    # extract the url components to create
    # the destination directory
    # so we save the repo to:
    # $destdir/hostname.com/path
    my $saveuri = URI->new($self->{URI});
    $saveuri->userinfo(undef);
    
    printLog($self->{LOG}, "info", sprintf(__("Mirroring: %s"), $saveuri->as_string ));
    printLog($self->{LOG}, "info", sprintf(__("Target:    %s"), $self->fullLocalRepoPath() ));

    # get the repository index
    my $job = SMT::Mirror::Job->new(debug => $self->{DEBUG}, UserAgent => $self->{USERAGENT}, log => $self->{LOG}, dbh => $self->{DBH} );
    $job->uri( $self->uri() );
    $job->localdir( $self->fullLocalRepoPath() );
    $job->resource( "repodata/repomd.xml" );

    # We expect the data are ok. If repomd.xml does not exist we downlaod everything new
    # which is like deepverify
    my $verifySuccess = 1;
    
    if ( $self->deepverify() && -e $job->local() )
    {
        # a deep verify check is requested 

        my $removeinvalid = 1;
        $removeinvalid = 0 if( $dryrun );

        $verifySuccess = $self->verify( removeinvalid => $removeinvalid, quiet => $self->debug() );
        
        $self->{STATISTIC}->{ERROR}    = 0;
        $self->{STATISTIC}->{UPTODATE} = 0;
        $self->{STATISTIC}->{DOWNLOAD} = 0;
        $self->{STATISTIC}->{DOWNLOAD_SIZE} = 0;
        
        if ( ! $dryrun )
        {
            # reset deepverify. It was done so we do not need it during mirror again.
            $self->deepverify(0);
        }
    }

    if ( !$job->outdated() && $verifySuccess )
    {
        printLog($self->{LOG}, "info", sprintf(__("=> Finished mirroring '%s' All files are up-to-date."), $saveuri->as_string));
        return 0;
    }
    # else $outdated or verify failed; we must download repomd.xml

    # copy repodata to .repodata 
    # we do not want to damage the repodata until we
    # have them all

    my $metatempdir = SMT::Utils::cleanPath( $job->localdir(), ".repodata" );

    if( -d "$metatempdir" )
    {
        rmtree($metatempdir, 0, 0);
    }

    &File::Path::mkpath( $metatempdir );

    if( -d $job->localdir()."/repodata" )
    {
        opendir(DIR, $job->localdir()."/repodata") or return 1;
        foreach my $entry (readdir(DIR))
        {
            next if ($entry =~ /^\./);
            
            my $fullpath = $job->localdir()."/repodata/$entry";
            if( -f $fullpath )
            {
                my $r = link( $fullpath, $metatempdir."/$entry");
                printLog($self->{LOG}, "debug", "link $fullpath, $metatempdir/$entry  result:$r") if($self->{DEBUG});
                if(!$r)
                {
                    printLog($self->{LOG}, "Linking $entry failed: $!");
                }
            }
        }
    }
    my $resource = $job->resource();
    $job->remoteresource($resource);
    $resource =~ s/repodata/.repodata/;
    $job->resource($resource);
    
    my $result = $job->mirror();
    $self->{STATISTIC}->{DOWNLOAD_SIZE} += int($job->downloadSize());
    if( $result == 1 )
    {
        $self->{STATISTIC}->{ERROR} += 1;
    }
    elsif( $result == 2 )
    {
        $self->{STATISTIC}->{UPTODATE} += 1;
    }
    else
    {
        if( $dryrun )
        {
            printLog($self->{LOG}, "info",  sprintf("New File [%s]", $job->remoteresource()));
        }
        $self->{STATISTIC}->{DOWNLOAD} += 1;
    }

    $job->remoteresource("repodata/repomd.xml.asc");
    $job->resource( ".repodata/repomd.xml.asc" );

    # if modified return undef, the file might not exist on the server
    # This is ok, signed repodata are not mandatory. So we do not try
    # to mirror it
    if( defined $job->modified(1) )
    {
        $self->{JOBS}->{".repodata/repomd.xml.asc"} = $job;
    }

    $job->remoteresource("repodata/repomd.xml.key");
    $job->resource( ".repodata/repomd.xml.key" );

    # if modified return undef, the file might not exist on the server
    # This is ok, signed repodata are not mandatory. So we do not try
    # to mirror it
    if( defined $job->modified(1) )
    {
        $self->{JOBS}->{".repodata/repomd.xml.key"} = $job;
    }

    # create a hash with filename => checksum
    my $statement = sprintf("SELECT localpath, checksum from RepositoryContentData where localpath like %s",
                            $self->{DBH}->quote($self->fullLocalRepoPath()."%"));
    $self->{EXISTS} = $self->{DBH}->selectall_hashref($statement, 'localpath');
    #printLog($self->{LOG}, "debug", "STATEMENT: $statement \n DUMP: ".Data::Dumper->Dump([$self->{EXISTS}]));
    

    # parse it and find more resources
    my $parser = SMT::Parser::RpmMd->new(log => $self->{LOG});
    $parser->resource($self->fullLocalRepoPath());
    $parser->specialmdlocation(1);
    $parser->parse(".repodata/repomd.xml", sub { download_handler($self, $dryrun, @_)});

    $self->{EXISTS} = undef;

    foreach my $r ( sort keys %{$self->{JOBS}})
    {
        if( $dryrun )
        {
            #
            # we have here only outdated files, so dryrun can display them all as "New File"
            #
            printLog($self->{LOG}, "info",  sprintf("New File [%s]", $r));
            $self->{STATISTIC}->{DOWNLOAD} += 1;
            
            next;
        }
        
        my $mres = $self->{JOBS}->{$r}->mirror();
        $self->{STATISTIC}->{DOWNLOAD_SIZE} += int($self->{JOBS}->{$r}->downloadSize());
        if( $mres == 1 )
        {
            $self->{STATISTIC}->{ERROR} += 1;
        }
        elsif( $mres == 2 ) # up-to-date should never happen
        {
            $self->{STATISTIC}->{UPTODATE} += 1;
        }
        else
        {
            $self->{STATISTIC}->{DOWNLOAD} += 1;
        }
    }
    
    # if no error happens copy .repodata to repodata
    if(!$dryrun && $self->{STATISTIC}->{ERROR} == 0 && -d $job->localdir()."/.repodata")
    {
        if( -d $job->localdir()."/.old.repodata")
        {
            rmtree($job->localdir()."/.old.repodata", 0, 0);
        }
        my $success = 1;
        if( -d $job->localdir()."/repodata" )
        {
            $success = rename( $job->localdir()."/repodata", $job->localdir()."/.old.repodata");
            if(!$success)
            {
                printLog($self->{LOG}, "error", sprintf(__("Cannot rename directory '%s'"), $job->localdir()."/repodata"));
                $self->{STATISTIC}->{ERROR} += 1;
            }
        }
        if($success)
        {
            $success = rename( $job->localdir()."/.repodata", $job->localdir()."/repodata");
            if(!$success)
            {
                printLog($self->{LOG}, "error", sprintf(__("Cannot rename directory '%s'"), $job->localdir()."/.repodata"));
                $self->{STATISTIC}->{ERROR} += 1;
            }
        }
    }
    
    if( $dryrun )
    {
        rmtree( $metatempdir, 0, 0 );
        
        printLog($self->{LOG}, "info", sprintf(__("=> Finished dryrun '%s'"), $saveuri->as_string));
        printLog($self->{LOG}, "info", sprintf(__("=> Files to download           : %s"), $self->{STATISTIC}->{DOWNLOAD}));
    }
    else
    {
        printLog($self->{LOG}, "info", sprintf(__("=> Finished mirroring '%s'"), $saveuri->as_string));
        printLog($self->{LOG}, "info", sprintf(__("=> Total transferred files     : %s"), $self->{STATISTIC}->{DOWNLOAD}));
        printLog($self->{LOG}, "info", sprintf(__("=> Total transferred file size : %s bytes (%s)"), 
                                               $self->{STATISTIC}->{DOWNLOAD_SIZE}, SMT::Utils::byteFormat($self->{STATISTIC}->{DOWNLOAD_SIZE})));
    }
    
    if( int ($self->{STATISTIC}->{UPTODATE}) > 0)
    {
        printLog($self->{LOG}, "info", sprintf(__("=> Files up to date            : %s"), $self->{STATISTIC}->{UPTODATE}));
    }
    printLog($self->{LOG}, "info", sprintf(__("=> Errors                      : %s"), $self->{STATISTIC}->{ERROR}));
    printLog($self->{LOG}, "info", sprintf(__("=> Mirror Time                 : %s"), SMT::Utils::timeFormat(tv_interval($t0))));
    print "\n";

    return $self->{STATISTIC}->{ERROR};
}

# deletes all files not referenced in
# the rpmmd resource chain
sub clean()
{
    my $self = shift;
    
    my $t0 = [gettimeofday] ;

    if ( ! -d $self->fullLocalRepoPath() )
    { 
        printLog($self->{LOG}, "error", sprintf(__("Destination '%s' does not exist"), $self->fullLocalRepoPath() ));
        exit 1;
    }

    printLog($self->{LOG}, "info", sprintf(__("Cleaning:         %s"), $self->fullLocalRepoPath() ) );

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

    my $parser = SMT::Parser::RpmMd->new(log => $self->{LOG});
    $parser->resource($self->fullLocalRepoPath());
    $parser->parse("/repodata/repomd.xml", sub { clean_handler($self, @_)});
    
    my $path = SMT::Utils::cleanPath($self->fullLocalRepoPath(), "/repodata/repomd.xml");
    
    delete $self->{CLEANLIST}->{$path} if (exists $self->{CLEANLIST}->{$path});
    delete $self->{CLEANLIST}->{$path.".asc"} if (exists $self->{CLEANLIST}->{$path.".asc"});;
    delete $self->{CLEANLIST}->{$path.".key"} if (exists $self->{CLEANLIST}->{$path.".key"});;

    my $cnt = 0;
    foreach my $file ( keys %{$self->{CLEANLIST}} )
    {
        printLog($self->{LOG}, "debug", "Delete: $file") if ($self->{DEBUG});
        $cnt += unlink $file;
        
        $self->{DBH}->do(sprintf("DELETE from RepositoryContentData where localpath = %s", $self->{DBH}->quote($file) ) );
    }

    printLog($self->{LOG}, "info", sprintf(__("Finished cleaning: '%s'"), $self->fullLocalRepoPath() ));
    printLog($self->{LOG}, "info", sprintf(__("=> Removed files : %s"), $cnt));
    printLog($self->{LOG}, "info", sprintf(__("=> Clean Time    : %s"), SMT::Utils::timeFormat(tv_interval($t0))));
    print "\n";
}

# verifies the repository on path
sub verify()
{
    my $self = shift;
    my %options = @_;

    my $t0 = [gettimeofday] ;

    # if path was not defined, we can use last
    # mirror destination dir
    if ( ! -d $self->fullLocalRepoPath() )
    {
        printLog($self->{LOG}, "error", sprintf(__("Destination '%s' does not exist"), $self->fullLocalRepoPath() ));
        return 1;
    }

    # remove invalid packages?
    my $removeinvalid = 0;
    $removeinvalid = 1 if ( exists $options{removeinvalid} && $options{removeinvalid} );

    my $quiet = 0;
    $quiet = 1 if( exists $options{quiet} && defined $options{quiet} && $options{quiet} );

    printLog($self->{LOG}, "info", sprintf(__("Verifying: %s"), $self->fullLocalRepoPath() )) if(!$quiet);

    $self->{STATISTIC}->{ERROR} = 0;
    
    # parse it and find more resources
    my $parser = SMT::Parser::RpmMd->new(log => $self->{LOG});
    $parser->resource( $self->fullLocalRepoPath() );
    $parser->parse("repodata/repomd.xml", sub { verify_handler($self, @_)});

    my $job;
    my $cnt = 0;
    foreach (sort keys %{$self->{VERIFYJOBS}} )
    {
        $job = $self->{VERIFYJOBS}->{$_};
        
        my $ok = ( (-e $job->local()) && $job->verify());
        $cnt++;
        if ($ok || ($job->resource =~ /repomd\.xml$/ ) )
        {
            printLog($self->{LOG}, "debug", "Verify: ". $job->resource . ": OK") if ($self->{DEBUG});
        }
        else
        {
            if(!-e $job->local())
            {
                printLog($self->{LOG}, "error", "Verify: ". $job->resource . ": FAILED ( file not found )");
            }
            else
            {
                printLog($self->{LOG}, "error", "Verify: ". $job->resource . ": ".sprintf("FAILED ( %s vs %s )", $job->checksum, $job->realchecksum));
                if ($removeinvalid)
                {
                    printLog($self->{LOG}, "debug", sprintf(__("Deleting %s"), $job->resource)) if ($self->{DEBUG});
                    unlink($job->local);
                }
            }
            $self->{DBH}->do(sprintf("DELETE from RepositoryContentData where localpath = %s", $self->{DBH}->quote($job->local() ) ) );
            
            $self->{STATISTIC}->{ERROR} += 1;
        }
    }

    if( !$quiet )
    {
        printLog($self->{LOG}, "info", sprintf(__("=> Finished verifying: %s"), $self->fullLocalRepoPath() ));
        printLog($self->{LOG}, "info", sprintf(__("=> Files             : %s"), $cnt ));
        printLog($self->{LOG}, "info", sprintf(__("=> Errors            : %s"), $self->{STATISTIC}->{ERROR} ));
        printLog($self->{LOG}, "info", sprintf(__("=> Verify Time       : %s"), SMT::Utils::timeFormat(tv_interval($t0)) ));
        print "\n";
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
    if(exists $data->{PKGFILES} && ref($data->{PKGFILES}) eq "ARRAY")
    {
        foreach my $file (@{$data->{PKGFILES}})
        {
            if(exists $file->{LOCATION} && defined $file->{LOCATION} &&
               $file->{LOCATION} ne "" )
            {
                # get the repository index
                my $resource = SMT::Utils::cleanPath( $self->fullLocalRepoPath(), $file->{LOCATION} );
                
                # if this path is in the CLEANLIST, delete it
                delete $self->{CLEANLIST}->{$resource} if (exists $self->{CLEANLIST}->{$resource});
            }
        }
    }
}


sub download_handler
{
    my $self   = shift;
    my $dryrun = shift;
    my $data   = shift;

    
    if(exists $data->{LOCATION} && defined $data->{LOCATION} &&
       $data->{LOCATION} ne "" && !exists $self->{JOBS}->{$data->{LOCATION}})
    {
        if(!$self->{MIRRORSRC} && exists $data->{ARCH} && defined $data->{ARCH} && lc($data->{ARCH}) eq "src")
        {
            # we do not want source rpms - skip
            printLog($self->{LOG}, "debug", "Skip source RPM: ".$data->{LOCATION}) if($self->{DEBUG});
            
            return;
        }

        # get the repository index
        my $job = SMT::Mirror::Job->new(debug => $self->{DEBUG}, UserAgent => $self->{USERAGENT}, log => $self->{LOG}, dbh => $self->{DBH} );
        $job->resource( $data->{LOCATION} );
        $job->checksum( $data->{CHECKSUM} );
        $job->localdir( $self->fullLocalRepoPath() );
        $job->uri( $self->{URI} );
        
        my $fullpath = "";

        if($data->{LOCATION} =~ /^repodata/)
        {
            $fullpath = SMT::Utils::cleanPath( $self->fullLocalRepoPath(), ".".$data->{LOCATION} );
        }
        else
        {
            $fullpath = SMT::Utils::cleanPath( $self->fullLocalRepoPath(), $data->{LOCATION} );
        }
        
        if( exists $self->{EXISTS}->{$fullpath} && 
            $self->{EXISTS}->{$fullpath}->{checksum} eq $data->{CHECKSUM} && 
            -e "$fullpath" )
        {
            # file exists and is up-to-date. 
            # with deepverify call a verify 
            if( $self->deepverify() && !$job->verify() )
            {
                #printLog($self->{LOG}, "debug", "deepverify: verify failed") if($self->{DEBUG});
                unlink ( $job->local() ) if( !$dryrun );
            }
            else
            {
                printLog($self->{LOG}, "debug", sprintf("U %s", $job->resource() )) if($self->{DEBUG});
                $self->{STATISTIC}->{UPTODATE} += 1;
                return;
            }
        }
        
        # if it is an xml file we have to download it now and
        # process it
        if (  $job->resource =~ /(.+)\.xml(.*)/ )
        {
            # metadata! change the download area

            my $localres = $data->{LOCATION};
            
            $localres =~ s/repodata/.repodata/;
            $job->remoteresource( $data->{LOCATION} );
            $job->resource( $localres );

            # mirror it first, so we can parse it
            my $mres = $job->mirror();
            $self->{DOWNLOAD_SIZE} += int($job->downloadSize());
            if( $mres == 1 )
            {
                $self->{STATISTIC}->{ERROR} += 1;
            }
            elsif( $mres == 2 ) # up-to-date
            {
                if($self->deepverify() && !$job->verify())
                {
                    # remove broken file and download it again
                    unlink($job->local());
                    $mres = $job->mirror();
                    if($mres = 0)
                    {
                        $self->{STATISTIC}->{DOWNLOAD} += 1;
                    }
                    else
                    {
                        # error
                        $self->{STATISTIC}->{ERROR} += 1;
                    }
                }
                else
                {
                    $self->{STATISTIC}->{UPTODATE} += 1;
                }
            }
            else
            {
                $self->{STATISTIC}->{DOWNLOAD} += 1;
            }
        }
        else
        {
            # download it later
            if ( $job->resource )
            {
                if(!exists $self->{JOBS}->{$data->{LOCATION}})
                {
                    $self->{JOBS}->{$data->{LOCATION}} = $job;
                }
            }
            else
            {
                printLog($self->{LOG}, "error", "no resource on $job->local");
            }
        }
    }
    if(exists $data->{PKGFILES} && ref($data->{PKGFILES}) eq "ARRAY")
    {
        foreach my $file (@{$data->{PKGFILES}})
        {
            if(exists $file->{LOCATION} && defined $file->{LOCATION} &&
               $file->{LOCATION} ne "" && !exists $self->{JOBS}->{$file->{LOCATION}})
            {
                my $job = SMT::Mirror::Job->new(debug => $self->{DEBUG}, UserAgent => $self->{USERAGENT}, log => $self->{LOG}, dbh => $self->{DBH} );
                $job->resource( $file->{LOCATION} );
                $job->checksum( $file->{CHECKSUM} );
                $job->localdir( $self->fullLocalRepoPath() );
                $job->uri( $self->{URI} );
                
                my $fullpath = SMT::Utils::cleanPath( $self->fullLocalRepoPath(), $file->{LOCATION} );
        
                if( exists $self->{EXISTS}->{$fullpath} && 
                    $self->{EXISTS}->{$fullpath}->{checksum} eq $file->{CHECKSUM} && 
                    -e "$fullpath" )
                {
                    # file exists and is up-to-date. 
                    # with deepverify call a verify 
                    if( $self->deepverify() && $job->verify() )
                    {
                        $self->{STATISTIC}->{UPTODATE} += 1;
                        next;
                    }
                    else
                    {
                        unlink ( $job->local() ) if( !$dryrun );
                    }
                }
                
                $self->{JOBS}->{$file->{LOCATION}} = $job;
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
        printLog($self->{LOG}, "debug", "Skip source RPM: ".$data->{LOCATION}) if($self->{DEBUG});
        
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
            my $job = SMT::Mirror::Job->new(debug => $self->{DEBUG}, UserAgent => $self->{USERAGENT}, log => $self->{LOG}, dbh => $self->{DBH});
            $job->resource( $data->{LOCATION} );
            $job->checksum( $data->{CHECKSUM} );
            $job->localdir( $self->fullLocalRepoPath() );
            
            if(!exists $self->{VERIFYJOBS}->{$job->local()})
            {
                $self->{VERIFYJOBS}->{$job->local()} = $job;
            }
        }
    }
    if($self->deepverify() && exists $data->{PKGFILES} && ref($data->{PKGFILES}) eq "ARRAY")
    {
        foreach my $file (@{$data->{PKGFILES}})
        {
            if(exists $file->{LOCATION} && defined $file->{LOCATION} &&
               $file->{LOCATION} ne "" && !exists $self->{JOBS}->{$file->{LOCATION}})
            {
                my $job = SMT::Mirror::Job->new(debug => $self->{DEBUG}, UserAgent => $self->{USERAGENT}, log => $self->{LOG}, dbh => $self->{DBH} );
                $job->resource( $file->{LOCATION} );
                $job->checksum( $file->{CHECKSUM} );
                $job->localdir( $self->fullLocalRepoPath() );
                
                $self->{VERIFYJOBS}->{$job->local()} = $job;
            }
        }
    }
}


=head1 NAME

SMT::Mirror::RpmMd - mirroring of a rpm metadata repository

=head1 SYNOPSIS

  use SMT::Mirror::RpmMd;

  $mirror = SMT::Mirror::RpmMd->new();
  $mirror->uri( "http://repo.com/10.3" );

  $mirror->mirrorTo( "/somedir", { urltree => 1 });
  $mirror->verify("/somedir/www.foo.com/repo");

  $mirror->mirrorTo( "/somedir", { urltree => 0 });
  $mirror->verify("/somedir");

=head1 DESCRIPTION

Mirroring of a rpm metadata repository.

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

 $mirror->uri( "http://repo.com/10.3" );

 Specify the RpmMd source where to mirror from.

=item mirrorTo()

 $mirror->mirrorTo( "/somedir", { urltree => 1 });

 Sepecify the target directory where to place the mirrored files.
 Returns the count of errors.

=over 4

=item urltree

The option urltree of the mirror method controls 
how the repo is mirrored. If urltree is true, then subdirectories
with the hostname and path of the repo url are created inside the
target directory.
If urltree is false, then the repo is mirrored right below the target
directory.

=back

=item verify()

 $mirror->verify();

 Returns true, if the repo is valid, otherwise false

=back

=head1 AUTHOR

dmacvicar@suse.de

=head1 COPYRIGHT

Copyright 2007, 2008 SUSE LINUX Products GmbH, Nuernberg, Germany.


=cut


1;  # so the require or use succeeds

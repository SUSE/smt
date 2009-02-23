package SMT::Mirror::Yum;
use strict;

use URI;
use File::Path;
use File::Find;

use SMT::Utils;
use SMT::Mirror::Job;

use base 'SMT::Mirror::RpmMd'; # sets @SMT::Mirror::Yum::ISA = ('SMT::Mirror::RpmMd')


# constructor
sub new
{
    my $pkgname = shift;
    my %opt   = @_;
    
    my $self  = {};

    # FIXME: is this really necessary to do this twice?
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
    $self->SUPER::new(@_);
    
    return $self;
}


# mirrors the repository to destination
sub mirrorTo()
{
    my $self = shift;
    my %options = @_;
    my $dryrun  = 0;
    $dryrun = 1 if(exists $options{dryrun} && defined $options{dryrun} && $options{dryrun});

    my $errors = $self->SUPER::mirrorTo(%options);

    return $errors if( $errors );
    
    # find out if we have old style yum repo with headers directoy

    my $job = SMT::Mirror::Job->new(debug => $self->debug(), UserAgent => $self->{USERAGENT}, log => $self->{LOG}, dbh => $self->{DBH} );
    $job->uri( $self->uri() );
    $job->localBasePath( $self->localBasePath() );
    $job->localRepoPath( $self->localRepoPath() );
    $job->localFileLocation( "headers/header.info" );

    my $result = $job->modified(1);
    if( ! defined $result )
    {
        return $errors;
    }
    
    my $mres = $job->mirror();
    $self->{STATISTIC}->{DOWNLOAD_SIZE} += int($job->downloadSize());
    if( $mres == 1 )
    {
        $self->{STATISTIC}->{ERROR} += 1;
        return $self->{STATISTIC}->{ERROR};
    }
    elsif( $mres == 2 )
    {
        $self->{STATISTIC}->{UPTODATE} += 1;
        return $self->{STATISTIC}->{ERROR};
    }
    else
    {
        $self->{STATISTIC}->{DOWNLOAD} += 1;
    }

    if( -e $job->fullLocalPath() )
    {
        open(HDR, "< ".$job->fullLocalPath()) and do
        {
            while(<HDR>)
            {
                if($_ =~ /^(\d+):([^=]+)/)
                {
                    my $epoch = $1;
                    my $file  = $2;
                    
                    if($file =~ /^(.+)-([^-]+)-([^-]+)\.([a-zA-Z0-9_]+)$/)
                    {
                        my $name = $1;
                        my $version = $2;
                        my $release = $3;
                        my $arch = $4;
                        
                        my $hdrLocation = "headers/".$name."-".$epoch."-".$version."-".$release.".".$arch.".hdr";
                        
                        my $hjob = SMT::Mirror::Job->new(debug => $self->{DEBUG}, UserAgent => $self->{USERAGENT}, log => $self->{LOG}, dbh => $self->{DBH} );
                        $hjob->uri( $self->uri() );
                        $hjob->localBasePath( $self->localBasePath() );
                        $hjob->localRepoPath( $self->localRepoPath() );
                        $hjob->localFileLocation( $hdrLocation );
                        $hjob->noChecksumCheck(1);

                        if( $dryrun )
                        {
                            if( $hjob->outdated() )
                            {
                                printLog($self->{LOG}, "info",  sprintf("New File [%s]", $hjob->fullLocalPath() ));
                                $self->{STATISTIC}->{DOWNLOAD} += 1;
                            }
                            else
                            {
                                printLog($self->{LOG}, "debug", sprintf("U '%s'", $hjob->fullLocalPath() )) if($self->debug());
                                $self->{STATISTIC}->{UPTODATE} += 1;
                            }
                            next;
                        }
        
                        $mres = $hjob->mirror();
                        $self->{STATISTIC}->{DOWNLOAD_SIZE} += int($hjob->downloadSize());
                        if( $mres == 1 )
                        {
                            $self->{STATISTIC}->{ERROR} += 1;
                        }
                        elsif( $mres == 2 )
                        {
                            $self->{STATISTIC}->{UPTODATE} += 1;
                        }
                        else
                        {
                            $self->{STATISTIC}->{DOWNLOAD} += 1;
                        }
                    }
                }
            }
            close HDR;
        };

        if( $dryrun )
        {
            printLog($self->{LOG}, "info", sprintf(__("=> Finished dryrun ")));
            printLog($self->{LOG}, "info", sprintf(__("=> Files to download           : %s"), $self->{STATISTIC}->{DOWNLOAD}));
        }
        else
        {
            printLog($self->{LOG}, "info", sprintf(__("=> Finished mirroring ")));
            printLog($self->{LOG}, "info", sprintf(__("=> Total transferred files     : %s"), $self->{STATISTIC}->{DOWNLOAD}));
            printLog($self->{LOG}, "info", sprintf(__("=> Total transferred file size : %s bytes (%s)"), 
                                                   $self->{STATISTIC}->{DOWNLOAD_SIZE}, SMT::Utils::byteFormat($self->{STATISTIC}->{DOWNLOAD_SIZE})));
        }
    
        if( int ($self->{STATISTIC}->{UPTODATE}) > 0)
        {
            printLog($self->{LOG}, "info", sprintf(__("=> Files up to date            : %s"), $self->{STATISTIC}->{UPTODATE}));
        }
        printLog($self->{LOG}, "info", sprintf(__("=> Errors                      : %s"), $self->{STATISTIC}->{ERROR}));
        #printLog($self->{LOG}, "info", sprintf(__("=> Mirror Time                 : %s"), SMT::Utils::timeFormat(tv_interval($t0))));
        print "\n";

    }
    return $self->{STATISTIC}->{ERROR};
}

sub clean
{
    my $self = shift;

    $self->SUPER::clean();

    my $headerFile = SMT::Utils::cleanPath($self->localBasePath(), $self->localRepoPath(), "headers/header.info");
    
    if( -e $headerFile )
    {
        $self->{CLEANLIST} = {};
        
        find ( { wanted =>
                 sub
                 {
                     if ( $File::Find::dir =~ /\/headers/ && -f $File::Find::name )
                     { 
                         my $name = SMT::Utils::cleanPath($File::Find::name);
                         
                         $self->{CLEANLIST}->{$name} = 1;
                     }
                 }
                 , no_chdir => 1 }, $self->fullLocalRepoPath() );
        
        open(HDR, "< $headerFile") and do
        {
            while(<HDR>)
            {
                if($_ =~ /^(\d+):([^=]+)/)
                {
                    my $epoch = $1;
                    my $file  = $2;
                    
                    if($file =~ /^(.+)-([^-]+)-([^-]+)\.([a-zA-Z0-9_]+)$/)
                    {
                        my $name = $1;
                        my $version = $2;
                        my $release = $3;
                        my $arch = $4;
                        
                        my $hdrLocation = SMT::Utils::cleanPath($self->fullLocalRepoPath(), "headers/".$name."-".$epoch."-".$version."-".$release.".".$arch.".hdr");
                        
                        # if this path is in the CLEANLIST, delete it
                        delete $self->{CLEANLIST}->{$hdrLocation} if (exists $self->{CLEANLIST}->{$hdrLocation});
                    }
                }
            }
        };
        
        my $cnt = 0;
        foreach my $file ( keys %{$self->{CLEANLIST}} )
        {
            printLog($self->{LOG}, "debug", "Delete: $file") if ($self->debug());
            $cnt += unlink $file;
        
            # header do not have a checksum, so they are not in the DB
            #$self->{DBH}->do(sprintf("DELETE from RepositoryContentData where localpath = %s", $self->{DBH}->quote($file) ) );
        }
        
        printLog($self->{LOG}, "info", sprintf(__("Finished cleaning: '%s'"), $self->fullLocalRepoPath()."/headers/" ));
        printLog($self->{LOG}, "info", sprintf(__("=> Removed files : %s"), $cnt));
        #printLog($self->{LOG}, "info", sprintf(__("=> Clean Time    : %s"), SMT::Utils::timeFormat(tv_interval($t0))));
        print "\n";
    }
}


1;


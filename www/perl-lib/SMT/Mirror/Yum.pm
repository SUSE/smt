package SMT::Mirror::Yum;

use strict;

use URI;
use File::Path;
use File::Find;
use Time::HiRes qw(gettimeofday tv_interval);
use RPMMD::Tools::MirrorJob;
use Log::Log4perl qw(get_logger :levels);

use SMT::Utils;

use base 'RPMMD::Tools::Mirror'; # sets @SMT::Mirror::Yum::ISA = ('RPMMD::Tools::Mirror')

# TODO: replace the old logger with log4perl

=head1 NAME

SMT::Mirror::Yum - mirroring of a old-style REHL4 yum metadata repository

=head1 SYNOPSIS

  use SMT::Mirror::Yum;

  $mirror = SMT::Mirror::Yum->new();
  $mirror->uri( "http://repo.com/yum" );
  $mirror->localBaseDir("/srv/www/htdocs/repo/");
  $mirror->localRepoDir("RPMMD/yum/");

  $mirror->mirror();

  $mirror->clean();

=head1 DESCRIPTION

Mirroring of a yum metadata repository.
All functions and options are the same as in RPMMD::Tools::Mirror.

=cut
# constructor
sub new
{
    my $pkgname = shift;
    my $self  = {};

    bless($self);
    $self = $self->SUPER::new(@_);
    bless($self);
    
    return $self;
}


# mirrors the repository to destination
sub mirror()
{
    my $self = shift;
    my %options = @_;
    my $dryrun  = 0;
    my $t0 = [gettimeofday] ;
    $dryrun = 1 if(exists $options{dryrun} && defined $options{dryrun} && $options{dryrun});
    my $log = get_logger();
    my $out = get_logger('userlogger');

    # extract the url components to create
    # the destination directory
    # so we save the repo to:
    # $destdir/hostname.com/path
    my $saveuri = SMT::Utils::getSaveUri($self->{URI});

    $log->info("Mirroring: $saveuri");
    $log->info("Target:    " . $self->fullLocalRepoPath());
    $out->info(sprintf(__("Mirroring: %s"), $saveuri ));
    $out->info(sprintf(__("Target:    %s"), $self->fullLocalRepoPath() ));

    my $errors = $self->SUPER::mirror(%options);

    return $errors if( $errors );

    # find out if we have old style yum repo with headers directoy

    my $job = RPMMD::Tools::MirrorJob->new(UserAgent => $self->{USERAGENT}, dbh => $self->{DBH}, dryrun => $dryrun );
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
    $self->job2statistic($job);
    if( $mres == 2 && $self->statistic()->{DOWNLOAD} == 0 && 
        $self->statistic()->{LINK} == 0 && $self->statistic()->{COPY} == 0 )
    {
        $log->info("Done with $saveuri, all up to date.");
        $out->info(sprintf(__("=> Finished mirroring '%s' All files are up-to-date."), $saveuri));
        $out->info(' ');
        return 0;
    }
    elsif( $mres == 0 && -e $job->fullLocalPath() )
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
                        
                        my $hjob = RPMMD::Tools::MirrorJob->new(UserAgent => $self->{USERAGENT}, dbh => $self->{DBH}, dryrun => $dryrun );
                        $hjob->uri( $self->uri() );
                        $hjob->localBasePath( $self->localBasePath() );
                        $hjob->localRepoPath( $self->localRepoPath() );
                        $hjob->localFileLocation( $hdrLocation );
                        $hjob->noChecksumCheck(1);
                        
                        if( $dryrun )
                        {
                            if( $hjob->outdated() )
                            {
                                my $msg = sprintf("N %s", $hjob->fullLocalPath());
                                $log->info($msg);
                                $out->debug($msg);
                                $self->{STATISTIC}->{DOWNLOAD} += 1;
                            }
                            else
                            {
                                my $msg = sprintf("U '%s'", $hjob->fullLocalPath());
                                $log->debug($msg);
                                $out->debug($msg);
                                $self->{STATISTIC}->{UPTODATE} += 1;
                            }
                            next;
                        }
                        
                        $mres = $hjob->mirror();
                        $self->job2statistic($hjob);
                    }
                }
            }
            close HDR;
        };
    }    
    
    if( $dryrun )
    {
        $log->info('Finished dry run. Files to download: ' . $self->{STATISTIC}->{DOWNLOAD});
        $out->info(sprintf(__("=> Finished dryrun ")));
        $out->info(sprintf(__("=> Files to download           : %s"), $self->{STATISTIC}->{DOWNLOAD}));
    }
    else
    {
        $out->info(sprintf(__("=> Finished mirroring ")));
        $out->info(sprintf(__("=> Total transferred files     : %s"), $self->{STATISTIC}->{DOWNLOAD}));
        $out->info(sprintf(__("=> Total transferred file size : %s bytes (%s)"), 
                                               $self->{STATISTIC}->{DOWNLOAD_SIZE}, SMT::Utils::byteFormat($self->{STATISTIC}->{DOWNLOAD_SIZE})));
        $out->info(sprintf(__("=> Total linked files          : %s"), $self->{STATISTIC}->{LINK}));
        $out->info(sprintf(__("=> Total copied files          : %s"), $self->{STATISTIC}->{COPY}));
        $out->info(sprintf(__("=> Files up to date            : %s"), $self->{STATISTIC}->{UPTODATE}));
        
        $log->info(sprintf("=> Finished mirroring "));
        $log->info(sprintf("=> Total transferred files     : %s", $self->{STATISTIC}->{DOWNLOAD}));
        $log->info(sprintf("=> Total transferred file size : %s bytes (%s)", 
                                               $self->{STATISTIC}->{DOWNLOAD_SIZE}, SMT::Utils::byteFormat($self->{STATISTIC}->{DOWNLOAD_SIZE})));
        $log->info(sprintf("=> Total linked files          : %s", $self->{STATISTIC}->{LINK}));
        $log->info(sprintf("=> Total copied files          : %s", $self->{STATISTIC}->{COPY}));
        $log->info(sprintf("=> Files up to date            : %s", $self->{STATISTIC}->{UPTODATE}));
    }

    #
    # I think YUM repositories do not have patches
    #
    # $out->info(sprintf(__("=> New Security Updates        : %s"), $self->{STATISTIC}->{NEWSECPATCHES}));
    # $out->info(sprintf(__("=> New Recommended Updates     : %s"), $self->{STATISTIC}->{NEWRECPATCHES}));
    $out->info(sprintf(__("=> Errors                      : %s"), $self->{STATISTIC}->{ERROR}));
    $out->info(sprintf(__("=> Mirror Time                 : %s"), SMT::Utils::timeFormat(tv_interval($t0))));
    $out->info(' ');

    $log->info(sprintf("=> Errors                      : %s", $self->{STATISTIC}->{ERROR}));
    $log->info(sprintf("=> Mirror Time                 : %s", SMT::Utils::timeFormat(tv_interval($t0))));

    return $self->{STATISTIC}->{ERROR};
}

sub clean
{
    my $self = shift;
    my $t0 = [gettimeofday];
    my $log = get_logger();
    my $out = get_logger('userlogger');

    $log->info('Cleaning: ' . $self->fullLocalRepoPath());
    $out->info(sprintf(__("Cleaning:         %s"), $self->fullLocalRepoPath()));

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

        # remove headers/header.info first
        my $hdrLocation = SMT::Utils::cleanPath($self->fullLocalRepoPath(), "headers/header.info");
        delete $self->{CLEANLIST}->{$hdrLocation} if (exists $self->{CLEANLIST}->{$hdrLocation});
        
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
                        
                        $hdrLocation = SMT::Utils::cleanPath($self->fullLocalRepoPath(), "headers/".$name."-".$epoch."-".$version."-".$release.".".$arch.".hdr");
                        
                        # if this path is in the CLEANLIST, delete it
                        delete $self->{CLEANLIST}->{$hdrLocation} if (exists $self->{CLEANLIST}->{$hdrLocation});
                    }
                }
            }
        };
        close HDR;

        my $cnt = 0;
        foreach my $file ( keys %{$self->{CLEANLIST}} )
        {
            $log->debug('Delete: '. $file);
            $cnt += unlink $file;

            # header do not have a checksum, so they are not in the DB
            #$self->{DBH}->do(sprintf("DELETE from RepositoryContentData where localpath = %s", $self->{DBH}->quote($file) ) );
        }

        $out->info(sprintf(__("Finished cleaning: '%s'"), $self->fullLocalRepoPath()."/headers/" ));
        $out->info(sprintf(__("=> Removed files : %s"), $cnt));
        $out->info(sprintf(__("=> Clean Time    : %s"), SMT::Utils::timeFormat(tv_interval($t0))));
        $out->info(' ');
        
        $log->info(sprintf("Finished cleaning: '%s'", $self->fullLocalRepoPath()."/headers/" ));
        $log->info(sprintf("=> Removed files : %s", $cnt));
        $log->info(sprintf("=> Clean Time    : %s", SMT::Utils::timeFormat(tv_interval($t0))));
    }
}

=head1 SEE ALSO

RPMMD::Tools::Mirror

=head1 AUTHOR

mc@suse.de

=head1 COPYRIGHT

Copyright 2007, 2008, 2009 SUSE LINUX Products GmbH, Nuernberg, Germany.

=cut


1;


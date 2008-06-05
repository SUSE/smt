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
    # local destination ie: /var/repo/download.suse.org/foo/10.3
    $self->{LOCALPATH}   = undef;
    $self->{JOBS}   = {};
    $self->{VERIFYJOBS}   = {};
    $self->{DEEPVERIFY}   = 0;
    $self->{STATISTIC}->{DOWNLOAD} = 0;
    $self->{STATISTIC}->{UPTODATE} = 0;
    $self->{STATISTIC}->{ERROR}    = 0;
    $self->{CLEANLIST} = {};
    $self->{DEBUG} = 0;
    $self->{LOG}   = undef;
    $self->{LASTUPTODATE} = 0;
    $self->{REMOVEINVALID} = 0;
    $self->{MIRRORSRC} = 1;

    # Do _NOT_ set env_proxy for LWP::UserAgent, this would break https proxy support
    $self->{USERAGENT}  = SMT::Utils::createUserAgent(keep_alive => 1);

    if(exists $opt{debug} && defined $opt{debug} && $opt{debug})
    {
        $self->{DEBUG} = 1;
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

# creates a path from a url
sub localUrlPath()
{
  my $self = shift;
  my $uri;
  my $repodest;

  $uri = URI->new($self->{URI});
  $repodest = join( "/", ( $uri->host, $uri->path ) );
  return $repodest;
}

sub lastUpToDate()
{
    my $self = shift;
    return $self->{LASTUPTODATE};
}

# mirrors the repository to destination
sub mirrorTo()
{
    my $self = shift;
    my $dest = shift;
    my $options = shift;
    
    my $force = 0;
    
    if ( not -e $dest )
    { die $dest . " does not exist"; }
    my $t0 = [gettimeofday] ;
    
    # reset the counter
    $self->{STATISTIC}->{ERROR}    = 0;
    $self->{STATISTIC}->{UPTODATE} = 0;
    $self->{STATISTIC}->{DOWNLOAD} = 0;

    # extract the url components to create
    # the destination directory
    # so we save the repo to:
    # $destdir/hostname.com/path
    my $saveuri = URI->new($self->{URI});
    $saveuri->userinfo(undef);
    
    if ( defined $options && exists $options->{ urltree } && $options->{ urltree } == 1 )
    {
      $self->{LOCALPATH} = join( "/", ( $dest, $self->localUrlPath() ) );
    }
    else
    {
      $self->{LOCALPATH} = $dest;
    }

    if ( defined $options && exists $options->{ force } && $options->{ force } == 1 )
    {
        $force = 1;
    }

    printLog($self->{LOG}, "info", sprintf(__("Mirroring: %s"), $saveuri->as_string));
    printLog($self->{LOG}, "info", sprintf(__("Target:    %s"), $self->{LOCALPATH}));

    my $destfile = join( "/", ( $self->{LOCALPATH}, "repodata/repomd.xml" ) );

    # get the repository index
    my $job = SMT::Mirror::Job->new(debug => $self->{DEBUG}, UserAgent => $self->{USERAGENT}, log => $self->{LOG});
    $job->uri( $self->{URI} );
    $job->localdir( $self->{LOCALPATH} );

    # get the file
    $job->resource( "/repodata/repomd.xml" );

    # check if we need to mirror first
    if (!$force &&  ! $job->outdated() )
    {
      # repomd is the same
      # check if the local repository is valid
      if ( $self->verify($self->{LOCALPATH}, {removeinvalid => 1}) )
      {
          printLog($self->{LOG}, "info", sprintf(__("=> Finished mirroring '%s' All files are up-to-date."), $saveuri->as_string));
          print "\n";
          $self->{LASTUPTODATE} = 1;
          return 0;
      }
      else
      {
          # we should continue here
          printLog($self->{LOG}, "info", __("repomd.xml is the same, but repo is not valid. Start mirroring."));

          # just in case
          $self->{LASTUPTODATE} = 0;
          # reset the counter
          $self->{STATISTIC}->{ERROR}    = 0;
          $self->{STATISTIC}->{UPTODATE} = 0;
          $self->{STATISTIC}->{DOWNLOAD} = 0;
      }
    }

    # copy repodata to .repodata 
    # we do not want to damage the repodata until we
    # have them all

    # check if $job->localdir() does not have insecure characters
    if( $job->localdir() =~ /[;&|]/)
    {
        printLog($self->{LOG}, "error", sprintf(__("Insecure characters in pathname detected.(%s)"), $job->localdir()));
        return 1;
    }

    if( -d $job->localdir()."/.repodata" )
    {
        rmtree($job->localdir()."/.repodata", 0, 0);
    }
    
    if( -d $job->localdir()."/repodata" )
    {
        my $cmd = "cp -a '".$job->localdir()."/repodata' '".$job->localdir()."/.repodata'";
        printLog($self->{LOG}, "debug", "$cmd") if($self->{DEBUG});
        my $ret = `$cmd`;
        my $resource = $job->resource();
        $job->remoteresource($resource);
        $resource =~ s/repodata/.repodata/;
        $job->resource($resource);
    }
    else
    {
        my $resource = $job->resource();
        $job->remoteresource($resource);
        $resource =~ s/repodata/.repodata/;
        $job->resource($resource);
    }
    
    my $result = $job->mirror();
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
        $self->{STATISTIC}->{DOWNLOAD} += 1;
    }
    
    $job->remoteresource("/repodata/repomd.xml.asc");
    $job->resource( "/.repodata/repomd.xml.asc" );
    $result = $job->mirror();
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
        $self->{STATISTIC}->{DOWNLOAD} += 1;
    }

    $job->remoteresource("/repodata/repomd.xml.key");
    $job->resource( "/.repodata/repomd.xml.key" );
    $result = $job->mirror();
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
        $self->{STATISTIC}->{DOWNLOAD} += 1;
    }

    # parse it and find more resources
    my $parser = SMT::Parser::RpmMd->new(log => $self->{LOG});
    $parser->resource($self->{LOCALPATH});
    $parser->specialmdlocation(1);
    $parser->parse(".repodata/repomd.xml", sub { download_handler($self, @_)});
 
    foreach my $r ( sort keys %{$self->{JOBS}})
    {
        if(exists $options->{dryrun} && defined $options->{dryrun} && $options->{dryrun})
        {
            if( $self->{JOBS}->{$r}->outdated() )
            {
                printLog($self->{LOG}, "info",  sprintf("New File [%s]", $r));
                $self->{STATISTIC}->{DOWNLOAD} += 1;
            }
            else
            {
                printLog($self->{LOG}, "debug", sprintf("-------> %s is up to date", $r)) if($self->{DEBUG});
                $self->{STATISTIC}->{UPTODATE} += 1;
            }
            
            next;
        }
        
        my $tries = 3;
        do
        {
            my $mres = $self->{JOBS}->{$r}->mirror();
            if( $mres == 1 )
            {
                $tries--;
                if($tries > 0)
                {
                    unlink($self->{JOBS}->{$r}->local());
                }
                else
                {
                    $self->{STATISTIC}->{ERROR} += 1;
                }
            }
            elsif( $mres == 2 )
            {
                $self->{STATISTIC}->{UPTODATE} += 1;
                $tries = 0;
            }
            else
            {
                if($self->{JOBS}->{$r}->verify())
                {
                    $tries = 0;
                    $self->{STATISTIC}->{DOWNLOAD} += 1;
                }
                else
                {
                    $tries--;
                    if($tries > 0)
                    {
                        unlink($self->{JOBS}->{$r}->local());
                    }
                    else
                    {
                        $self->{STATISTIC}->{ERROR} += 1;
                    }
                }
            }
        } while $tries > 0;
    }

    # dryrun - remove .repodata directory
    if(exists $options->{dryrun} && defined $options->{dryrun} && $options->{dryrun})
    {
        if( -d $job->localdir()."/.repodata")
        {
            rmtree($job->localdir()."/.repodata", 0, 0);
        }

    }  # if no error happens copy .repodata to repodata
    elsif($self->{STATISTIC}->{ERROR} == 0 && -d $job->localdir()."/.repodata")
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
    
    if(exists $options->{dryrun} && defined $options->{dryrun} && $options->{dryrun})
    {
        printLog($self->{LOG}, "info", sprintf(__("=> Finished dryrun '%s'"), $saveuri->as_string));
        printLog($self->{LOG}, "info", sprintf(__("=> Files to download: %s"), $self->{STATISTIC}->{DOWNLOAD}));
    }
    else
    {
        printLog($self->{LOG}, "info", sprintf(__("=> Finished mirroring '%s'"), $saveuri->as_string));
        printLog($self->{LOG}, "info", sprintf(__("=> Files Downloaded: %s"), $self->{STATISTIC}->{DOWNLOAD}));
    }
    
    if( int ($self->{STATISTIC}->{UPTODATE}) > 0)
    {
        printLog($self->{LOG}, "info", sprintf(__("=> Files up to date : %s"), $self->{STATISTIC}->{UPTODATE}));
    }
    printLog($self->{LOG}, "info", sprintf(__("=> Errors           : %s"), $self->{STATISTIC}->{ERROR}));
    printLog($self->{LOG}, "info", sprintf(__("=> Mirror Time      : %s"), SMT::Utils::timeFormat(tv_interval($t0))));
    print "\n";

    return $self->{STATISTIC}->{ERROR};
}

# deletes all files not referenced in
# the rpmmd resource chain
sub clean()
{
    my $self = shift;
    my $dest = shift;
    
    my $t0 = [gettimeofday] ;

    if ( not -e $dest )
    { 
        printLog($self->{LOG}, "error", sprintf(__("Destination '%s' does not exist"),$dest));
        exit 1;
    }

    $self->{LOCALPATH} = $dest;

    printLog($self->{LOG}, "info", sprintf(__("Cleaning:         %s"), $self->{LOCALPATH}));

    # algorithm
    
    find ( { wanted =>
             sub
             {
                 if ( -f $File::Find::name )
                 { 
                     my $name = $File::Find::name;
                     $name =~ s/\/\.?\//\//g;
                     $self->{CLEANLIST}->{$name} = 1; 
                 }
             }
             , no_chdir => 1 }, $self->{LOCALPATH} );

    my $parser = SMT::Parser::RpmMd->new(log => $self->{LOG});
    $parser->resource($self->{LOCALPATH});
    $parser->parse("/repodata/repomd.xml", sub { clean_handler($self, @_)});
    
    my $path = $self->{LOCALPATH}."/repodata/repomd.xml";
    # strip out /./ and //
    $path =~ s/\/\.?\//\//g;
    
    delete $self->{CLEANLIST}->{$path} if (exists $self->{CLEANLIST}->{$path});
    delete $self->{CLEANLIST}->{$path.".asc"} if (exists $self->{CLEANLIST}->{$path.".asc"});;
    delete $self->{CLEANLIST}->{$path.".key"} if (exists $self->{CLEANLIST}->{$path.".key"});;

    my $cnt = 0;
    foreach my $file ( keys %{$self->{CLEANLIST}} )
    {
        printLog($self->{LOG}, "debug", "Delete: $file") if ($self->{DEBUG});
        $cnt += unlink $file;
    }

    printLog($self->{LOG}, "info", sprintf(__("Finished cleaning: '%s'"), $self->{LOCALPATH}));
    printLog($self->{LOG}, "info", sprintf(__("=> Removed files : %s"), $cnt));
    printLog($self->{LOG}, "info", sprintf(__("=> Clean Time    : %s"), SMT::Utils::timeFormat(tv_interval($t0))));
    print "\n";
}

# verifies the repository on path
sub verify()
{
    my $self = shift;
    my $path = shift;
    my $options = shift;

    my $t0 = [gettimeofday] ;

    # if path was not defined, we can use last
    # mirror destination dir
    if ( $path )
    {
        $self->{LOCALPATH} = $path;
    }

    # remove invalid packages?
    if ( defined $options && exists $options->{removeinvalid} && $options->{removeinvalid} == 1 )
    {
        $self->{REMOVEINVALID}  = 1;
    }

    if ( not -e $self->{LOCALPATH} )
    { 
        printLog($self->{LOG}, "error", $self->{LOCALPATH} . " does not exist");
        exit 1;
    }
    
    printLog($self->{LOG}, "info", sprintf(__("Verifying: %s"), $self->{LOCALPATH}));

    my $destfile = join( "/", ( $self->{LOCALPATH}, "repodata/repomd.xml" ) );

    $self->{STATISTIC}->{ERROR} = 0;
    
    # parse it and find more resources
    my $parser = SMT::Parser::RpmMd->new(log => $self->{LOG});
    $parser->resource($self->{LOCALPATH});
    $parser->parse("repodata/repomd.xml", sub { verify_handler($self, @_)});

    my $job;
    my $cnt = 0;
    foreach (sort keys %{$self->{VERIFYJOBS}} )
    {
        $job = $self->{VERIFYJOBS}->{$_};
        
        my $ok = $job->verify();
        $cnt++;
        if ($ok || ($job->resource eq "/repodata/repomd.xml") )
        {
            printLog($self->{LOG}, "debug", "Verify: ". $job->resource . ": OK") if ($self->{DEBUG});
        }
        else
        {
            printLog($self->{LOG}, "info", "Verify: ". $job->resource . ": ".sprintf("FAILED ( %s vs %s )", $job->checksum, $job->realchecksum));
            $self->{STATISTIC}->{ERROR} += 1;
            if ($self->{REMOVEINVALID} == 1)
            {
                printLog($self->{LOG}, "info", sprintf(__("Deleting %s"), $job->resource));
                unlink($job->local);
            }
        }
    }

    printLog($self->{LOG}, "info", sprintf(__("=> Finished verifying: %s"), $self->{LOCALPATH}));
    printLog($self->{LOG}, "info", sprintf(__("=> Files             : %s"), $cnt));
    printLog($self->{LOG}, "info", sprintf(__("=> Errors            : %s"), $self->{STATISTIC}->{ERROR}));
    printLog($self->{LOG}, "info", sprintf(__("=> Verify Time       : %s"), SMT::Utils::timeFormat(tv_interval($t0))));
    print "\n";
    
    $self->{REMOVEINVALID}  = 0;
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
        my $resource = $self->{LOCALPATH}."/".$data->{LOCATION};
        # strip out /./ and //
        $resource =~ s/\/\.?\//\//g;

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
                my $resource = $self->{LOCALPATH}."/".$file->{LOCATION};
                # strip out /./ and //
                $resource =~ s/\/\.?\//\//g;
                
                # if this path is in the CLEANLIST, delete it
                delete $self->{CLEANLIST}->{$resource} if (exists $self->{CLEANLIST}->{$resource});
            }
        }
    }
}


sub download_handler
{
    my $self = shift;
    my $data = shift;

    
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
        my $job = SMT::Mirror::Job->new(debug => $self->{DEBUG}, UserAgent => $self->{USERAGENT}, log => $self->{LOG});
        $job->resource( $data->{LOCATION} );
        $job->checksum( $data->{CHECKSUM} );
        $job->localdir( $self->{LOCALPATH} );
        $job->uri( $self->{URI} );
        
        # if it is an xml file we have to download it now and
        # process it
        if (  $job->resource =~ /(.+)\.xml(.*)/ )
        {
            # metadata! change the download area

            my $localres = $data->{LOCATION};
            
            $localres =~ s/repodata/.repodata/;
            $job->remoteresource($data->{LOCATION});
            $job->resource( $localres );

            my $tries = 3;
            do 
            {
                # mirror it first, so we can parse it
                my $mres = $job->mirror();
                if( $mres == 1 )
                {
                    $tries--;
                    if($tries > 0)
                    {
                        unlink($job->local());
                    }
                    else
                    {
                        $self->{STATISTIC}->{ERROR} += 1;
                    }
                }
                elsif( $mres == 2 )
                {
                    $self->{STATISTIC}->{UPTODATE} += 1;
                    $tries = 0;
                }
                else
                {
                    if($job->verify())
                    {
                        $tries = 0;
                        $self->{STATISTIC}->{DOWNLOAD} += 1;
                    }
                    else
                    {
                        $tries--;
                        if($tries > 0)
                        {
                            unlink($job->local());
                        }
                        else
                        {
                            $self->{STATISTIC}->{ERROR} += 1;
                        }
                    }
                }
            } while $tries > 0;
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
                my $job = SMT::Mirror::Job->new(debug => $self->{DEBUG}, UserAgent => $self->{USERAGENT}, log => $self->{LOG});
                $job->resource( $file->{LOCATION} );
                $job->checksum( $file->{CHECKSUM} );
                $job->localdir( $self->{LOCALPATH} );
                $job->uri( $self->{URI} );

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
        if($self->deepverify() || $data->{LOCATION} =~ /repodata/)
        {
            my $job = SMT::Mirror::Job->new(debug => $self->{DEBUG}, UserAgent => $self->{USERAGENT}, log => $self->{LOG});
            $job->resource( $data->{LOCATION} );
            $job->checksum( $data->{CHECKSUM} );
            $job->localdir( $self->{LOCALPATH} );
            
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
                my $job = SMT::Mirror::Job->new(debug => $self->{DEBUG}, UserAgent => $self->{USERAGENT}, log => $self->{LOG});
                $job->resource( $file->{LOCATION} );
                $job->checksum( $file->{CHECKSUM} );
                $job->localdir( $self->{LOCALPATH} );
                
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

  # this is true if the last mirror call determined
  # the reposiotory was up to date.
  # if no mirror was run, then it is false
  $mirror->lastUpToDate()


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

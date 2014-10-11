package SMT::Mirror::Job;
use strict;

use File::Path;
use File::Basename;
use Date::Parse;
use Digest;
use SMT::Utils;
use File::Basename;
use File::Copy;

=head1 NAME

SMT::Mirror::Job - represents a single resource mirror job

=head1 SYNOPSIS

  $job = SMT::Mirror::Job->new(dbh => $dbh);
  $job->uri("http://foo.com/");
  $job->localBasePath("/srv/www/htdocs/repo/");
  $job->localRepoPath("$RCE/SLES11-Updates/sle-11-i586/");
  $job->localFileLocation("/repodata/repomd.xml");
  # when was it last time modified remotely
  print $job->modified()
  # is the local version outdated?
  print $job->outdated()
  $job->mirror();

=head1 DESCRIPTION

Represents a remote resource mirror job and provice
useful mehods to check if the resource exists local
or if it needs refresh and to transfer it.

=head1 METHODS

=over 4

=item new(%params)

Create a new SMT::Mirror::Job object:

  my $mirror = SMT::Mirror::Job->new(debug => 1);

Arguments are an anonymous hash array of parameters:

=over 4

=item vblevel <level>

Set the verbose level.

=item UserAgent

LWP::UserAgent object to use for this job. Usefull for keep_alive.

=item dbh

DBI database handle.

=item log

Logfile handle

=item nohardlink

Set to 1 to disable the use of hardlinks. Copy is used instead of it.

=back

=cut

sub new
{
    my $pkgname = shift;
    my %opt   = @_;

    my $self  = {};
    $self->{URI}        = undef;

    # starting with / upto  repo/
    $self->{LOCALBASEPATH} = undef;

    # catalog Path like LOCALPATH in the DB.
    # e.g. $RCE/SLES11-Updates/sle-11-i586/
    $self->{LOCALREPOPATH}   = undef;

    # Local file location in the catalog
    $self->{LOCALFILELOCATION} = undef;

    # File location on the server
    # used if this is different from LOCALFILELOCATION
    $self->{REMOTEFILELOCATION} = undef;

    $self->{CHECKSUM}   = undef;
    $self->{CHECKSUM_TYPE}   = undef;
    $self->{NO_CHECKSUM_CHECK}   = 0;

    $self->{MAX_REDIRECTS} = 5;
    $self->{VBLEVEL}       = 0;
    $self->{LOG}           = undef;

    $self->{DBH}           = undef;

    # outdated() will set this to the last modification date of the remote file
    $self->{modifiedAt} = undef;

    $self->{DOWNLOAD_SIZE} = 0;

    #
    # 0 unknown
    # 1 error
    # 2 up-to-date
    # 3 download
    # 4 link
    # 5 copy
    #
    $self->{DOWNLOAD_TYPE} = 0;

    $self->{NOHARDLINK} = 0;

    $self->{DRYRUN} = 0;

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

    if(exists $opt{nohardlink} && defined $opt{nohardlink} && $opt{nohardlink})
    {
        $self->{NOHARDLINK} = 1;
    }

    if(exists $opt{dryrun} && defined $opt{dryrun})
    {
        $self->{DRYRUN} = $opt{dryrun};
    }

    $self->{RESPONSE_CODE} = undef;

    if(defined $opt{useragent} && $opt{useragent})
    {
        $self->{USERAGENT} = $opt{useragent};
    }
    else
    {
        $self->{USERAGENT} = SMT::Utils::createUserAgent(log => $self->{LOG}, vblevel => $self->{VBLEVEL});
    }

    bless($self);
    return $self;
}

=item uri([url])

Set and get the remote repository URI.

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

=item localFileLocation([path])

Set and get the file location in the repository on the local system.
E.g. repodata/repomd.xml

=cut

sub localFileLocation
{
    my $self = shift;
    if (@_) { $self->{LOCALFILELOCATION} = shift }
    return $self->{LOCALFILELOCATION};
}

=item remoteFileLocation([path])

Set and get the file location in the repository on the remote system.
E.g. repodata/repomd.xml

If a special location is not defined B<remoteFileLocation> returns B<localFileLocation>.

=cut

sub remoteFileLocation
{
    my $self = shift;
    if (@_) { $self->{REMOTEFILELOCATION} = shift }

    # if REMOTEFILELOCATION is not available return LOCALFILELOCATION
    if(defined $self->{REMOTEFILELOCATION}  &&
       $self->{REMOTEFILELOCATION} ne "" )
    {
        return $self->{REMOTEFILELOCATION};
    }
    else
    {
        return $self->{LOCALFILELOCATION};
    }
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

=item fullLocalPath()

Return the full path to the file on the local system. It concatenate
localBasePath(), localRepoPath() and localFileLocation().

=cut

sub fullLocalPath
{
    my $self = shift;
    my $local = SMT::Utils::cleanPath( $self->localBasePath(), $self->localRepoPath(), $self->localFileLocation() );
    return $local;
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

=item fullRemoteURI()

Return the full URL of the file on the remote system. It concatenate
uri() and remoteFileLocation().

=cut

sub fullRemoteURI
{
    my $self = shift;
    return SMT::Utils::appendPathToURI($self->uri(), $self->remoteFileLocation());
}

=item fullUri2local()

Return the full local path of a source file if the URI has 'file' scheme.
The path is constructed out of fullRemoteURI().

=cut
sub fullUri2local
{
    my $self = shift;

    return undef if ($self->uri() !~ /^file\:\/\//);

    my $uri = $self->fullRemoteURI();
    $uri =~ s/^file\:\/\///;
    return $uri;
}

=item checksum([checksum])

Set and get the expected checksum for this file.

=cut

sub checksum()
{
    my $self = shift;
    if (@_) { $self->{CHECKSUM} = shift }
    return $self->{CHECKSUM};
}


=item checksum_type([type])

Set and get the checksum type

=cut

sub checksum_type()
{
    my $self = shift;
    if (@_) { $self->{CHECKSUM_TYPE} = shift }
    return $self->{CHECKSUM_TYPE};
}


=item noChecksumCheck([0|1])

Enable or disable checksum check for this job.
Returns the current state.

=cut

sub noChecksumCheck
{
    my $self = shift;
    if(@_)
    {
        $self->{NO_CHECKSUM_CHECK} = shift
    }
    return $self->{NO_CHECKSUM_CHECK};
}

=item downloadSize()

Return the download size in bytes.

=cut

sub downloadSize
{
    my $self = shift;
    return $self->{DOWNLOAD_SIZE};
}


sub wasUnknown()
{
    my $self = shift;
    return ($self->{DOWNLOAD_TYPE} == 0);
}

sub wasError()
{
    my $self = shift;
    return ($self->{DOWNLOAD_TYPE} == 1);
}

sub wasUpToDate()
{
    my $self = shift;
    return ($self->{DOWNLOAD_TYPE} == 2);
}

sub wasDownload()
{
    my $self = shift;
    return ($self->{DOWNLOAD_TYPE} == 3);
}

sub wasLink()
{
    my $self = shift;
    return ($self->{DOWNLOAD_TYPE} == 4);
}

sub wasCopy()
{
    my $self = shift;
    return ($self->{DOWNLOAD_TYPE} == 5);
}

sub wasForbidden()
{
    my $self = shift;
    return $self->{RESPONSE_CODE} == 403;
}

sub wasNotFound()
{
    my $self = shift;
    return $self->{RESPONSE_CODE} == 404;
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

=item verify()

Verify the local copy of the file with the known
checksum without accesing the network.

Returns 0 (false) if the checksums do not match.
Returns 1 (true) if the checksums match or the checksum check is disabled or no
expected checksum is available.

=cut

sub verify
{
    my $self = shift;

    return 1 if($self->{NO_CHECKSUM_CHECK} || !defined $self->checksum());

    return 0 if ( $self->checksum() ne  $self->realchecksum($self->checksum_type()) );
    return 1;
}

=item realchecksum()

Calculate the real checksum of the file and return the value.

=cut

sub realchecksum()
{
    my $self = shift;
    my $type = shift;

    my %TRANSLATION = (
        'sha'     => 'SHA-1',
        'sha1'    => 'SHA-1',
        'sha224'  => 'SHA-224',
        'sha256'  => 'SHA-256',
        'sha384'  => 'SHA-384',
        'sha512'  => 'SHA-512',
        'md5'     => 'MD5',
        'SHA'     => 'SHA-1',
        'SHA1'    => 'SHA-1',
        'SHA224'  => 'SHA-224',
        'SHA256'  => 'SHA-256',
        'SHA384'  => 'SHA-384',
        'SHA512'  => 'SHA-512',
        'MD5'     => 'MD5',
        'SHA-1'   => 'SHA-1',
        'SHA-224' => 'SHA-224',
        'SHA-256' => 'SHA-256',
        'SHA-384' => 'SHA-384',
        'SHA-512' => 'SHA-512',
    );
    if (! $type || !exists $TRANSLATION{$type})
    {
        # default to sha1
        $type = 'SHA-1';
    }
    else
    {
        $type = $TRANSLATION{$type};
    }

    my $module;
    my $digest;
    my $filename = $self->fullLocalPath();
    open(FILE, "< $filename") or do {
        printLog($self->{LOG}, $self->vblevel(), LOG_DEBUG, "Cannot open '$filename': $!") ;
        return "";
    };

    eval
    {
        $module = Digest->new("$type");
        $module->addfile(*FILE);
        $digest = $module->hexdigest();
    };
    if($@)
    {
        printLog($self->{LOG}, $self->vblevel(), LOG_ERROR, "Unable to calculate real checksum for '$filename': ".$@);
        $digest = '';
    }
    close FILE;

    return $digest;
}

=item updateDB()

Update the database with the current job informations.
(for internal use)

=cut

sub updateDB
{
    my $self = shift;

    return if( $self->localFileLocation() ne $self->remoteFileLocation() ); # we do not store .repodata/ into the DB

    return if( ! defined $self->{DBH} ); # don't try to update when running without a DB connection (e.g. --dbreplfile)

    eval
    {
        if( $self->checksum() && $self->checksum_type() )
        {
            my $statement = sprintf("SELECT checksum, checksum_type
                                       FROM RepositoryContentData
                                      WHERE localpath = %s",
                                    $self->{DBH}->quote( $self->fullLocalPath() ));
            my $existChecksum = $self->{DBH}->selectall_arrayref($statement, {Slice=>{}});


            if( !exists $existChecksum->[0] || !defined $existChecksum->[0] )
            {
                #insert
                $self->{DBH}->do(sprintf("INSERT INTO RepositoryContentData (name, checksum, checksum_type, localpath)
                                          VALUES (%s, %s, %s, %s)",
                                         $self->{DBH}->quote( basename( $self->fullLocalPath() ) ),
                                         $self->{DBH}->quote( $self->checksum() ),
                                         $self->{DBH}->quote( $self->checksum_type() ),
                                         $self->{DBH}->quote( $self->fullLocalPath() )
                                        ));
            }
            elsif( $existChecksum->[0]->{checksum} ne $self->checksum() ||
                   $existChecksum->[0]->{checksum_type} ne $self->checksum_type()
                 )
            {
                #update
                $self->{DBH}->do(sprintf("UPDATE RepositoryContentData
                                             SET name=%s, checksum=%s, checksum_type=%s
                                           WHERE localpath=%s",
                                         $self->{DBH}->quote( basename( $self->fullLocalPath() ) ),
                                         $self->{DBH}->quote( $self->checksum() ),
                                         $self->{DBH}->quote( $self->checksum_type() ),
                                         $self->{DBH}->quote( $self->fullLocalPath() )
                                        ));
            }
        }
    };
    if($@)
    {
        #ignore errors
        printLog($self->{LOG}, $self->vblevel(), LOG_DEBUG, "Updating the database failed: $@" ) ;
    }
}


=item mirror()

Mirror the file.
Returns
 0 on success,
 1 on error and
 2 if the file is up to date

=cut

sub mirror
{
    my $self = shift;

    if ( !$self->outdated() )
    {
        printLog($self->{LOG}, $self->vblevel(), LOG_DEBUG, sprintf("U %s", $self->fullLocalPath() ));
        # no need to mirror
        $self->{DOWNLOAD_TYPE} = 2;
        return 2;
    }

    # make sure the container destination exists
    &File::Path::mkpath( dirname($self->fullLocalPath()) );

    my $redirects = 0;
    my $response;
    my $remote = $self->fullRemoteURI();

    if( -e $self->fullLocalPath() )
    {
        # LWP::UserAgent modify the file, but we need to replace it
        # so we better remove it, if it exists
        unlink $self->fullLocalPath();
        #printLog($self->{LOG}, $self->vblevel(), LOG_DEBUG, "UNLINK: ".$self->fullLocalPath());
    }

    if( $self->copyFromLocalIfAvailable() )
    {
        return 0;
    }


    my $tries  = 1;

    my $errorcode = 1;
    my $errormsg  = "";
    do
    {
        my $saveuri = SMT::Utils::getSaveUri($remote);
        eval
        {
            $response = $self->{USERAGENT}->get( $remote, ':content_file' => $self->fullLocalPath() );
            $self->{DOWNLOAD_SIZE} = 0 if (! defined $self->{DOWNLOAD_SIZE});
            $self->{DOWNLOAD_SIZE} += int($response->header("Content-Length"))
                if (defined $response->header("Content-Length"));
        };
        if($@)
        {
            $errormsg = sprintf(__("E '%s'"), $saveuri);
            printLog($self->{LOG}, $self->vblevel(), LOG_ERROR, $errormsg." (Try $tries)", 0, 1);
            printLog($self->{LOG}, $self->vblevel(), LOG_ERROR, $@, 0, 1);
            $tries++;
        }
        elsif ( $response->is_redirect )
        {
            $redirects++;
            if($redirects > $self->{MAX_REDIRECTS})
            {
                $tries = 4;
                $errormsg = sprintf(__("E '%s': Too many redirects"), $saveuri);
            }
            else
            {
                my $newuri = $response->header("location");
                chomp($newuri);
                #printLog($self->{LOG}, $self->vblevel(), LOG_DEBUG, "Redirected to $newuri") ;
                $remote = $newuri;
            }
        }
        elsif( $response->is_success )
        {
            if($self->verify())
            {
                if (my $lm = $response->last_modified)
                {
                    # make sure the file has the same last modification time
                    utime $lm, $lm, $self->fullLocalPath();
                }

                if( !$self->{DRYRUN} )
                {
                    printLog($self->{LOG}, $self->vblevel(), LOG_INFO2, sprintf("D %s", $self->fullLocalPath()));
                }
                else
                {
                    printLog($self->{LOG}, $self->vblevel(), LOG_INFO2, sprintf("N %s", $self->fullLocalPath()));
                }

                $self->updateDB();

                $errorcode = 0;
                $errormsg = "";
                $tries = 4;
            }
            else
            {
                $errormsg = sprintf(__("E '%s': Checksum mismatch'"), $self->fullLocalPath() );
                $errormsg .= sprintf(" ('%s' vs '%s')", $self->checksum(), $self->realchecksum($self->checksum_type())) if($self->vblevel() & LOG_DEBUG);

                printLog($self->{LOG}, $self->vblevel(), LOG_ERROR, $errormsg." (Try $tries)", 0, 1);
                if($tries > 0)
                {
                    unlink($self->fullLocalPath());
                }
                $tries++;
            }
        }
        else
        {
            $errormsg = sprintf(__("E '%s': %s"), $saveuri, $response->status_line);
            $self->{RESPONSE_CODE} = $response->code;
            printLog($self->{LOG}, $self->vblevel(), LOG_ERROR, $errormsg." (Try $tries)" , 0, 1);
            $tries++;
        }
    } while($tries < 4);

    if($errorcode != 0)
    {
        printLog($self->{LOG}, $self->vblevel(), LOG_ERROR, $errormsg, 1, 0);
        $self->{DOWNLOAD_TYPE} = 1;
        return $errorcode;
    }

    $self->{DOWNLOAD_TYPE} = 3;
    return 0;
}

=item modified([nolog])

Return the remote modification timestamp or undef on error.

If I<nolog> is 1, logging is disabled in this function.

=cut

# remote modification timestamp
sub modified
{
    my $self = shift;
    my $doNotLog = shift || 0;

    my $redirects = 0;
    my $response;
    my $remote = $self->fullRemoteURI();
    do
    {
        my $saveuri = SMT::Utils::getSaveUri($self->fullRemoteURI());
        eval
        {
            $response = $self->{USERAGENT}->head( $remote );
        };
        if($@)
        {
            printLog($self->{LOG}, $self->vblevel(), LOG_WARN, "head request failed: $@") if(!$doNotLog);
            return undef;
        }

        if ( $response->is_redirect )
        {
            $redirects++;
            if($redirects > $self->{MAX_REDIRECTS})
            {
                printLog($self->{LOG}, $self->vblevel(), LOG_ERROR, sprintf(__("E '%s': Too many redirects", $saveuri) ));
                return undef;
            }

            my $newuri = $response->header("location");
            chomp($newuri);

            #printLog($self->{LOG}, $self->vblevel(), LOG_DEBUG, "Redirected to $newuri") ;
            $remote = $newuri;
        }
        elsif( $response->is_success )
        {
            return Date::Parse::str2time($response->header( "Last-Modified" ));
        }
        else
        {
            printLog($self->{LOG}, $self->vblevel(), LOG_ERROR, sprintf(__("E '%s': %s"),
                                                    $saveuri, $response->status_line))  if(!$doNotLog);
            return undef;
        }

    } while($response->is_redirect);
    return Date::Parse::str2time($response->header( "Last-Modified" ));
}

=item outdated()

Returns 1 (true) if a newer version is available, otherwise 0 (false).

FIXME: maybe this method should be call modified() instead (and the current
   modified() method should be called modifiedTime(); 'modified' suggests
   that it returns a bool value saying whether the resource has been modified)

=cut

sub outdated
{
    my $self = shift;

    return 1 if ( ! -e $self->fullLocalPath() );

    my $date = (stat $self->fullLocalPath())[9];
    $self->{modifiedAt} = $self->modified();

    # this was: return ... $date < $self->{modifiedAt});
    # but we want to download (mirror) even if the local timestamp is newer
    # (that is, if we or someone modifies the metadata, e.g. when filtering)
    return (!defined $self->{modifiedAt} || $date != $self->{modifiedAt});
}

=item copyFromLocalIfAvailable()

Search the DB (RepositoryContentData) if a file is available on the local
system and hardlink or copy the file (depends on the option I<nohardlink>
in new()). If the file is not found in DB, and the source URI is 'file://',
hardlink or copy it, too.

If a file was found and hardlink or copy was successfull this function
return 1 (true), otherwise 0 (false). Returns 0 also if checksum is not known.
The return value of 0 is to advise the caller to download the file (it is
not available on the local filesystem).

NOTE: the hardlinking will fail across different filesystems. The file will
be copied as a fallback.
=cut

sub copyFromLocalIfAvailable
{
    my $self = shift;

    my $name = basename( $self->localFileLocation() );
    my $checksum = $self->checksum();
    my $checksum_type = $self->checksum_type();

    return 0 if (!(defined $name && defined $checksum && defined $checksum_type && $name && $checksum && $checksum_type));

    my $otherpath = undef; # source file path

    # try to look for the same file based on the checksum in RepositoryContentData

    if (defined $self->{DBH})
    {
        my $statement = sprintf("SELECT localpath
                                   FROM RepositoryContentData
                                  WHERE name = %s
                                    AND checksum = %s
                                    AND checksum_type = %s
                                    AND localpath NOT LIKE %s",
                                $self->{DBH}->quote($name),
                                $self->{DBH}->quote($checksum),
                                $self->{DBH}->quote($checksum_type),
                                $self->{DBH}->quote($self->fullLocalRepoPath()."%") );

        my $existingpath = $self->{DBH}->selectcol_arrayref($statement);

        if(exists $existingpath->[0] && defined $existingpath->[0] && $existingpath->[0] ne "" )
        {
            $otherpath = $existingpath->[0];
        }
    }

    # try to get the file location from the full source URI (if file://)

    if (! defined $otherpath || ! $otherpath || ! -e $otherpath)
    {
        $otherpath = $self->fullUri2local();
    }

    return 0 if( !defined $otherpath || $otherpath eq "" || ! -e "$otherpath" );

    my $success = 0;

    if(!$self->{NOHARDLINK})
    {
        $success = link($otherpath, $self->fullLocalPath());
    }

    if(!$success)
    {
        File::Copy::copy($otherpath, $self->fullLocalPath()) or do
        {
            printLog($self->{LOG}, $self->vblevel(), LOG_DEBUG, "copy($otherpath, ".$self->fullLocalPath().") failed: $!") ;
            return 0;
        };

        if(defined $self->{modifiedAt})
        {
            # make sure the file has the same last modification time
            utime $self->{modifiedAt}, $self->{modifiedAt}, $self->fullLocalPath();
        }
    }

    if($self->verify())
    {
        if($success)
        {
            printLog($self->{LOG}, $self->vblevel(), LOG_INFO2, sprintf("L %s", $self->fullLocalPath()));
            $self->{DOWNLOAD_TYPE} = 4;
        }
        else
        {
            printLog($self->{LOG}, $self->vblevel(), LOG_INFO2, sprintf("C %s", $self->fullLocalPath()));
            $self->{DOWNLOAD_TYPE} = 5;
        }
        $self->updateDB();
        return 1;
    }
    else
    {
        # checksum missmatch. Remove the file and try to download it
        unlink($self->fullLocalPath());
    }
    return 0;
}

=back

=head1 AUTHOR

dmacvicar@suse.de, mc@suse.de

=head1 COPYRIGHT

Copyright 2007-2012 SUSE LINUX Products GmbH, Nuernberg, Germany.

=cut

1;  # so the require or use succeeds

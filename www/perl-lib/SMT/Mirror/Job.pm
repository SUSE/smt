package SMT::Mirror::Job;
use strict;

use LWP::UserAgent;
use File::Path;
use File::Basename;
use Date::Parse;
use Crypt::SSLeay;
use Digest::SHA1  qw(sha1 sha1_hex);
use SMT::Utils;
use File::Basename;
use File::Copy;

sub new
{
    my $pkgname = shift;
    my %opt   = @_;
    
    my $self  = {};
    $self->{URI}        = undef;
    $self->{LOCALDIR}   = undef;
    $self->{RESOURCE}   = undef;
    $self->{RESOURCEEXT}   = undef;   # if we need to set a different resource remote and local
    $self->{CHECKSUM}   = undef;
    $self->{NO_CHECKSUM_CHECK}   = 0;
    
    # Do _NOT_ set env_proxy for LWP::UserAgent, this would break https proxy support
    $self->{USERAGENT}  = (defined $opt{UserAgent} && $opt{UserAgent})?$opt{UserAgent}:SMT::Utils::createUserAgent(keep_alive => 1);

    $self->{MAX_REDIRECTS} = 2;
    $self->{DEBUG}      = 0;
    $self->{LOG}        = undef;
    #$self->{JOBTYPE}    = undef;

    $self->{DBH}        = undef;

    # outdated() will set this to the last modification date of the remote file
    $self->{modifiedAt} = undef;
    
    $self->{DOWNLOAD_SIZE} = 0;
    
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

# job type
#sub type
#{
#    my $self = shift;
#    if (@_) { $self->{JOBTYPE} = shift }
#    
#    return $self->{JOBTYPE};
#}

# database handle
sub dbh
{
    my $self = shift;
    if (@_) { $self->{DBH} = shift }
    
    return $self->{DBH};
}

# local resource container
sub localdir
{
    my $self = shift;
    if (@_) { $self->{LOCALDIR} = shift }
    return $self->{LOCALDIR};
}

sub remoteresource
{
    my $self = shift;
    
    if(@_) { $self->{RESOURCEEXT} = shift }
    return $self->{RESOURCEEXT};
}
    

# local full path
sub local
{
    my $self = shift;
    my $local = SMT::Utils::cleanPath($self->{LOCALDIR}."/".$self->{RESOURCE} );
    return $local;
}

# local full path
sub remote
{
    my $self = shift;
    if(defined $self->{RESOURCEEXT} && $self->{RESOURCEEXT} ne "")
    {
        return $self->{URI}."/".$self->{RESOURCEEXT};
    }
    else
    {
        return $self->{URI}."/".$self->{RESOURCE};
    }
}

# resource property
sub resource
{
    my $self = shift;
    if (@_) { $self->{RESOURCE} = shift }
    return $self->{RESOURCE};
}

# checksum property
sub checksum()
{
    my $self = shift;
    if (@_) { $self->{CHECKSUM} = shift }
    return $self->{CHECKSUM};
}

# no_checksum_check property
sub noChecksumCheck
{
    my $self = shift;
    if(@_) 
    {
        $self->{NO_CHECKSUM_CHECK} = shift 
    }
    return $self->{NO_CHECKSUM_CHECK};
}


sub downloadSize
{
    my $self = shift;
    return $self->{DOWNLOAD_SIZE};
}


# verify the local copy of the job with the known
# checksum without accesing the network
sub verify()
{
    my $self = shift;
    
    return 1 if($self->{NO_CHECKSUM_CHECK} || !defined $self->checksum());

    return 0 if ( $self->checksum() ne  $self->realchecksum() );
    return 1;
}

sub realchecksum()
{
    my $self = shift;
    
    my $sha1;
    my $digest;
    my $filename = $self->local;
    open(FILE, "< $filename") or do {
        printLog($self->{LOG}, "debug", "Cannot open '$filename': $!") if($self->{DEBUG});
        return "";
    };
    
    $sha1 = Digest::SHA1->new;
    $sha1->addfile(*FILE);
    $digest = $sha1->hexdigest();
    close FILE;
    return $digest;
}

# mirror the resource to the local destination
#
# Returns:
# 0 = ok
# 1 = error
# 2 = up-to-date
#
sub mirror
{
    my $self = shift;

    if ( not $self->outdated() )
    {
        printLog($self->{LOG}, "debug", sprintf("U %s", $self->{RESOURCE})) if($self->{DEBUG});
        # no need to mirror
        return 2;
    }
    
    # make sure the container destination exists
    &File::Path::mkpath( dirname($self->local()) );

    my $redirects = 0;
    my $response;
    my $remote = $self->remote();

    if( -e $self->local() )
    {
        # LWP::UserAgent modify the file, but we need to replace it
        # so we better remove it, if it exists
        unlink $self->local();
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
        eval
        {
            $response = $self->{USERAGENT}->get( $remote, ':content_file' => $self->local() );
            $self->{DOWNLOAD_SIZE} += int($response->header("Content-Length"));
        };
        if($@)
        {
            my $saveuri = URI->new($remote);
            $saveuri->userinfo(undef);
            
            $errormsg = sprintf(__("E '%s'"), $saveuri->as_string());
            printLog($self->{LOG}, "error", $errormsg." (Try $tries)", 0, 1);
            printLog($self->{LOG}, "error", $@, 0, 1);
            $tries++;
        }
        elsif ( $response->is_redirect )
        {
            $redirects++;
            if($redirects > $self->{MAX_REDIRECTS})
            {
                $tries = 4;
                $errormsg = __("Too many redirects");

                printLog($self->{LOG}, "error", $errormsg, 0, 1);
            }
            else
            {
                my $newuri = $response->header("location");
                
                #printLog($self->{LOG}, "debug", "Redirected to $newuri") if($self->{DEBUG});
                $remote = URI->new($newuri);
            }
        }
        elsif( $response->is_success )
        {
            if($self->verify())
            {
                if (my $lm = $response->last_modified)
                {
                    # make sure the file has the same last modification time
                    utime $lm, $lm, $self->local();
                }
                
                printLog($self->{LOG}, "info", sprintf("D %s", $self->local()));
                eval 
                {
                    if( defined $self->checksum() && $self->checksum() ne "")
                    {
                        my $statement = sprintf("SELECT checksum from RepositoryContentData where localpath = %s", 
                                                $self->{DBH}->quote( $self->local() ));
                        my $existChecksum = $self->{DBH}->selectcol_arrayref($statement);
                        

                        if( !exists $existChecksum->[0] || !defined $existChecksum->[0] )
                        {
                            #insert
                            $self->{DBH}->do(sprintf("INSERT INTO RepositoryContentData (name, checksum, localpath) VALUES (%s, %s, %s)",
                                                     $self->{DBH}->quote( basename( $self->local() ) ),
                                                     $self->{DBH}->quote( $self->checksum() ),
                                                     $self->{DBH}->quote( $self->local() )
                                                    ));
                        }
                        elsif( $existChecksum->[0] ne $self->checksum() )
                        {
                            #update
                            $self->{DBH}->do(sprintf("UPDATE RepositoryContentData set name=%s, checksum=%s where localpath=%s",
                                                     $self->{DBH}->quote( basename( $self->local() ) ),
                                                     $self->{DBH}->quote( $self->checksum() ),
                                                     $self->{DBH}->quote( $self->local() )
                                                    ));
                        }
                    }
                };
                if($@)
                {
                    #ignore errors
                    printLog($self->{LOG}, "debug", "Insert failed: $@" ) if($self->{DEBUG});
                }
                
                $errorcode = 0;
                $errormsg = "";
                $tries = 4;
            }
            else
            {
                $errormsg = sprintf(__("E '%s': Checksum mismatch'"), $self->resource());
                $errormsg .= sprintf(" ('%s' vs '%s')", $self->checksum(), $self->realchecksum()) if($self->{DEBUG});
                
                printLog($self->{LOG}, "error", $errormsg." (Try $tries)", 0, 1);
                if($tries > 0)
                {
                    unlink($self->local());
                }
                $tries++;
            }
        }
        else
        {
            my $saveuri = URI->new($remote);
            $saveuri->userinfo(undef);
            
            $errormsg = sprintf(__("E '%s': %s"), $saveuri->as_string(), $response->status_line);
            printLog($self->{LOG}, "error", $errormsg." (Try $tries)" , 0, 1);
            $tries++;
        }
    } while($tries < 4);

    if($errorcode != 0)
    {
        printLog($self->{LOG}, "error", $errormsg, 1, 0);
        return $errorcode;
    }
    
    return 0;
}

# remote modification timestamp
sub modified
{
    my $self = shift;
    my $doNotLog = shift || 0;
    
    my $redirects = 0;
    my $response;
    my $remote = $self->remote();
    do
    {
        eval
        {
            $response = $self->{USERAGENT}->head( $remote );
        };
        if($@)
        {
            printLog($self->{LOG}, "warn", "head request failed: $@") if(!$doNotLog);
            return undef;
        }

        if ( $response->is_redirect )
        {
            $redirects++;
            if($redirects > $self->{MAX_REDIRECTS})
            {
                printLog($self->{LOG}, "error", __("Too many redirects"));
                return undef;
            }
            
            my $newuri = $response->header("location");
            
            #printLog($self->{LOG}, "debug", "Redirected to $newuri") if($self->{DEBUG});
            $remote = URI->new($newuri);
        }
        elsif( $response->is_success )
        {
            return Date::Parse::str2time($response->header( "Last-Modified" ));
        }
        else 
        {
            my $saveuri = URI->new($self->remote());
            $saveuri->userinfo(undef);
            printLog($self->{LOG}, "error", sprintf(__("Failed to download '%s': %s"), 
                                                    $saveuri->as_string() , $response->status_line))  if(!$doNotLog);
            return undef;
        }
        
    } while($response->is_redirect);
    return Date::Parse::str2time($response->header( "Last-Modified" ));
}

# true if remote is newer than local version
# or if local does not exists
sub outdated
{
    my $self = shift;
    
    if ( not -e $self->local() )
    {
        return 1;
    }
    
    my $date = (stat $self->local())[9];
    $self->{modifiedAt} = $self->modified();
    
    return (!defined $self->{modifiedAt} || $date < $self->{modifiedAt});
}

sub copyFromLocalIfAvailable
{
    my $self = shift;

    return 0 if(!defined $self->{DBH});

    my $name = basename($self->local());
    my $checksum = $self->checksum();
    
    return 0 if(!defined $name || $name eq "" || !defined $checksum || $checksum eq "");

    my $statement = sprintf("SELECT localpath from RepositoryContentData where name = %s and checksum = %s", 
                            $self->{DBH}->quote($name), $self->{DBH}->quote($checksum));

    printLog($self->{LOG}, "debug", "$statement") if($self->{DEBUG});
    my $existingpath = $self->{DBH}->selectcol_arrayref($statement);

    if(exists $existingpath->[0] && defined $existingpath->[0] && $existingpath->[0] ne "" )
    {
        my $otherpath = $existingpath->[0];
      
        return 0 if( ! -e "$otherpath" );
  
        copy($otherpath, $self->local()) or do
        {
            printLog($self->{LOG}, "debug", "copy($otherpath, ".$self->local().") failed: $!") if($self->{DEBUG});
            return 0;
        };

        if(defined $self->{modifiedAt})
        {
            # make sure the file has the same last modification time
            utime $self->{modifiedAt}, $self->{modifiedAt}, $self->local();
        }
        
        printLog($self->{LOG}, "info", sprintf("C %s", $self->local()));
        return 1;
    }
    return 0;
}


=head1 NAME

SMT::Mirror::Job - represents a single resource mirror job

=head1 SYNOPSIS

  $job = SMT::Mirror::Job->new();
  $job->uri("http://foo.com/");
  $job->localdir("/tmp");
  $job->resource("/file.txt");
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

=item new([$params])

Create a new SMT::Mirror::Job object:

  my $mirror = SMT::Mirror::Job->new(debug => 1);

Arguments are an anonymous hash array of parameters:

=over 4

=item debug

Set to 1 to enable debug. 

=item UserAgent

LWP::UserAgent object to use for this job. Usefull for keep_alive. 

=back

=item mirror()

Returns 0 on success, 1 on error and 2 if the file is up to date

=back

=head1 AUTHOR

dmacvicar@suse.de

=head1 COPYRIGHT

Copyright 2007, 2008 SUSE LINUX Products GmbH, Nuernberg, Germany.

=cut

1;  # so the require or use succeeds

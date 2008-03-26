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
    # local destination ie: /var/repo/download.suse.org/foo/10.3
    $self->{LOCALPATH}   = undef;
    $self->{DEBUG}  = 0;
    $self->{LOG}    = 0;
    $self->{DEEPVERIFY} = 0;
    $self->{DBREPLACEMENT} = undef;
    
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

sub dbreplacement
{
    my $self = shift;
    if (@_) { $self->{DBREPLACEMENT} = shift }
    return $self->{DBREPLACEMENT};
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

# mirrors the repository to destination
sub mirrorTo()
{
    my $self = shift;
    my $dest = shift;
    my $options = shift;
  
    if ( not -e $dest )
    { 
        printLog($self->{LOG}, "error", $dest . " does not exist");
        exit 1;
    }

    # extract the url components to create
    # the destination directory
    # so we save the repo to:
    # $destdir/hostname.com/path
    my $saveuri = URI->new($self->{URI});
    $saveuri->userinfo(undef);
    
    if ( $$options{ urltree } eq 1 )
    {
      $self->{LOCALPATH} = join( "/", ( $dest, $self->localUrlPath() ) );
    }
    else
    {
      $self->{LOCALPATH} = $dest;
    }
    printLog($self->{LOG}, "info", sprintf(__("Mirroring: %s"), $saveuri->as_string));
    printLog($self->{LOG}, "info", sprintf(__("Target:    %s"), $self->{LOCALPATH}));

    my $destfile = join( "/", ( $self->{LOCALPATH}, "repo/repoindex.xml" ) );

    # get the repository index
    my $job = SMT::Mirror::Job->new(debug => $self->{DEBUG}, log => $self->{LOG});
    $job->uri( $self->{URI} );
    $job->resource( "/repo/repoindex.xml" );
    $job->localdir( $self->{LOCALPATH} );
    
    # get the file
    $job->mirror();

    my $dbh = undef;
    
    if(!defined $self->{DBREPLACEMENT} || ref($self->{DBREPLACEMENT}) ne "HASH")
    {
        $dbh = SMT::Utils::db_connect();
        if(!$dbh)
        {
            printLog($self->{LOG}, "error", __("Cannot connect to database"));
            exit 1;
        }
    }
    
    # changing the MIRRORABLE flag is done by ncc-sync, no need to do it here too
    # $dbh->do("UPDATE Catalogs SET MIRRORABLE = 'N' where CATALOGTYPE='nu'");
    
    my $parser = SMT::Parser::NU->new(log => $self->{LOG});
    $parser->parse($destfile, sub{ mirror_handler($self, $dbh, @_) });

    if($dbh)
    {
        $dbh->disconnect;
    }
}

# deletes all files not referenced in
# the rpmmd resource chain
sub clean()
{
    my $self = shift;
    my $dest = shift;

    # algorithm
    
    if ( not -e $dest )
    { 
        printLog($self->{LOG}, "error", sprintf(__("Destination '%s' does not exist"), $dest));
        exit 1;
    }

    $self->{LOCALPATH} = $dest;

    my $path = $self->{LOCALPATH}."/repo/repoindex.xml";

    my $dbh = SMT::Utils::db_connect();
    if(!$dbh)
    {
        printLog($self->{LOG}, "error", __("Cannot connect to database"));
        exit 1;
    }

    my $parser = SMT::Parser::NU->new(log => $self->{LOG});
    $parser->parse($path, sub{ clean_handler($self, $dbh, @_) });
    
    $dbh->disconnect;
}

sub mirror_handler
{
    my $self = shift;
    my $dbh  = shift;
    my $data = shift;

    my $domirror = 0;

    if(defined $dbh && $dbh)
    {
        my $res = $dbh->selectcol_arrayref( sprintf("select DOMIRROR from Catalogs where MIRRORABLE='Y' and CATALOGTYPE='nu' and NAME=%s and TARGET=%s", 
                                                    $dbh->quote($data->{NAME}), $dbh->quote($data->{DISTRO_TARGET}) ) );

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
        # get the repository index
        my $mirror = SMT::Mirror::RpmMd->new(debug => $self->{DEBUG}, log => $self->{LOG});
        
        my $catalogURI = join("/", $self->{URI}, "repo", $data->{PATH});
        my $localPath = $self->{LOCALPATH}."/repo/".$data->{PATH};
        
        &File::Path::mkpath( $localPath );
        
        $mirror->uri( $catalogURI );
        $mirror->deepverify($self->{DEEPVERIFY});
        $mirror->mirrorTo( $localPath );
    }
}


sub clean_handler
{
    my $self = shift;
    my $dbh  = shift;
    my $data = shift;

    my $res = $dbh->selectcol_arrayref( sprintf("select DOMIRROR from Catalogs where CATALOGTYPE='nu' and NAME=%s and TARGET=%s", 
                                                $dbh->quote($data->{NAME}), $dbh->quote($data->{DISTRO_TARGET}) ) );
    
    if(defined $res && exists $res->[0] &&
       defined $res->[0] && $res->[0] eq "Y")
    {
        my $rpmmd = SMT::Mirror::RpmMd->new(debug => $self->{DEBUG}, log => $self->{LOG});
        
        my $localPath = $self->{LOCALPATH}."/repo/".$data->{PATH};
        $localPath =~ s/\/\.?\//\//g;
        $rpmmd->deepverify($self->{DEEPVERIFY});
        
        $rpmmd->clean( $localPath );
    }
}

1;

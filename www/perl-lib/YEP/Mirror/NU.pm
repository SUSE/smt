package YEP::Mirror::NU;

use strict;

use URI;
use XML::Parser;
use File::Path;

use YEP::Mirror::Job;
use YEP::Mirror::RpmMd;
use YEP::Utils;

use Data::Dumper;

=head1 NAME

YEP::Mirror::NU - mirroring of a Novell Update repository

=head1 SYNOPSIS

  use YEP::Mirror::NU;

  $mirror = YEP::Mirror::NU->new();
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

Create a new YEP::Mirror::RpmMd object:

  my $mirror = YEP::Mirror::RpmMd->new(debug => 1);

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
    $self->{JOBS}   = [];
    $self->{DEBUG}  = 0;
    
    if(exists $opt{debug} && defined $opt{debug} && $opt{debug})
    {
        $self->{DEBUG} = 1;
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
    { die $dest . " does not exist"; }

    # extract the url components to create
    # the destination directory
    # so we save the repo to:
    # $destdir/hostname.com/path
    my $uri = URI->new($self->{URI});

    if ( $$options{ urltree } eq 1 )
    {
      $self->{LOCALPATH} = join( "/", ( $dest, $self->localUrlPath() ) );
    }
    else
    {
      $self->{LOCALPATH} = $dest;
    }
    print "Mirroring: ", $self->{URI}, "\n";
    print "Target:    ", $self->{LOCALPATH}, "\n";

    my $destfile = join( "/", ( $self->{LOCALPATH}, "repo/repoindex.xml" ) );

    # get the repository index
    my $job = YEP::Mirror::Job->new(debug => $self->{DEBUG});
    $job->uri( $self->{URI} );
    $job->resource( "/repo/repoindex.xml" );
    $job->localdir( $self->{LOCALPATH} );
    
    # get the file
    $job->mirror();

    # set MirrorAble of all NU Catalogs to 'N'
    my $dbh = YEP::Utils::db_connect();
    if(!$dbh)
    {
        die "cannot connect to database";
    }
    $dbh->do("UPDATE Catalogs SET Mirrorable = 'N' where CatalogType='nu'");
    $dbh->disconnect;
    

    # parse it and find more resources
    $self->_parseXmlResource( $destfile );
}

# deletes all files not referenced in
# the rpmmd resource chain
sub clean()
{
    my $self = shift;
    my $dest = shift;

    # algorithm
    
    if ( not -e $dest )
    { die "Destination '$dest' does not exist"; }

    $self->{LOCALPATH} = $dest;

    my $path = $self->{LOCALPATH}."/repo/repoindex.xml";
    $self->_parseXmlResource( $path, 1);

}

# parses a xml resource
sub _parseXmlResource()
{
    my $self     = shift;
    my $path     = shift;
    my $forClean = shift || 0;
    
    my $parser; 
    
    if(!$forClean)
    {
        $parser = XML::Parser->new( Handlers =>
                                    { Start=> sub { handle_start_tag($self, @_) },
                                      End=>\&handle_end_tag,
                                    });
    }
    else
    {
        $parser = XML::Parser->new( Handlers =>
                                    { Start=> sub { handle_start_tag_clean($self, @_) },
                                      End=>\&handle_end_tag,
                                    });
    }
    
    if ( $path =~ /(.+)\.gz/ )
    {
      use IO::Zlib;
      my $fh = IO::Zlib->new($path, "rb");
      eval {
          # using ->parse( $fh ) result in errors
          my @cont = $fh->getlines();
          $parser->parse( join("", @cont ));
      };
      if($@) {
          # ignore the errors, but print them
          chomp($@);
          print STDERR "Error: $@\n";
      }
    }
    else
    {
      eval {
          $parser->parsefile( $path );
      };
      if($@) {
          # ignore the errors, but print them
          chomp($@);
          print STDERR "Error: $@\n";
      }
    }
}

# handles XML reader start tag events
sub handle_start_tag()
{
    my $self = shift;
    my( $expat, $element, %attrs ) = @_;
    # ask the expat object about our position
    my $line = $expat->current_line;

    # we are looking for <repo .../>
    if ( $element eq "repo" )
    {
        # check if we want to mirror this repo
        my $dbh = YEP::Utils::db_connect();
        if(!$dbh)
        {
            # FIXME: Is "die" correct here ? 
            die "cannot connect to database";
        }
        
        # Set Mirrorable flag of this catalog to "Y"
        $dbh->do(sprintf("UPDATE Catalogs SET Mirrorable = 'Y' where CatalogType='nu' and Name=%s and Target=%s", 
                         $dbh->quote($attrs{"name"}), $dbh->quote($attrs{"distro_target"}) ));
        my $res = $dbh->selectall_arrayref( sprintf("select DoMirror from Catalogs where CatalogType='nu' and Name=%s and Target=%s", 
                                                    $dbh->quote($attrs{"name"}), $dbh->quote($attrs{"distro_target"}) ) );
        $dbh->disconnect;

        if($res->[0]->[0] eq "Y")
        {
            # get the repository index
            my $mirror = YEP::Mirror::RpmMd->new(debug => $self->{DEBUG});
            
            my $catalogURI = join("/", $self->{URI}, "/repo", $attrs{"path"});
            my $localPath = $self->{LOCALPATH}."/repo/".$attrs{"path"};
            
            &File::Path::mkpath( $localPath );
            
            $mirror->uri( $catalogURI );
            $mirror->mirrorTo( $localPath );
        }
    }
}

# handles XML reader start tag events for Clean
sub handle_start_tag_clean()
{
    my $self = shift;
    my( $expat, $element, %attrs ) = @_;
    # ask the expat object about our position
    my $line = $expat->current_line;

    # we are looking for <repo .../>
    if ( $element eq "repo" )
    {
        # check if we want to mirror this repo
        my $dbh = YEP::Utils::db_connect();
        if(!$dbh)
        {
            # FIXME: Is "die" correct here ? 
            die "cannot connect to database";
        }
        
        # Set Mirrorable flag of this catalog to "Y"
        $dbh->do(sprintf("UPDATE Catalogs SET Mirrorable = 'Y' where CatalogType='nu' and Name=%s and Target=%s", 
                         $dbh->quote($attrs{"name"}), $dbh->quote($attrs{"distro_target"}) ));
        my $res = $dbh->selectall_arrayref( sprintf("select DoMirror from Catalogs where CatalogType='nu' and Name=%s and Target=%s", 
                                                    $dbh->quote($attrs{"name"}), $dbh->quote($attrs{"distro_target"}) ) );
        $dbh->disconnect;

        if($res->[0]->[0] eq "Y")
        {
            my $rpmmd = YEP::Mirror::RpmMd->new(debug => $self->{DEBUG});
            
            my $localPath = $self->{LOCALPATH}."/repo/".$attrs{"path"};
            $localPath =~ s/\/\.?\//\//g;
            
            $rpmmd->clean( $localPath );
        }
    }
}

sub handle_end_tag()
{
  my( $expat, $element, %attrs ) = @_;
}

1;

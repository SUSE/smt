package YEP::CLI;
use strict;
use warnings;
use URI;
use YEP::Utils;
use Config::IniFiles;
use File::Temp;
use YEP::Parser::NU;
use YEP::Mirror::Job;

use vars qw($cfg $dbh);

#print "hello CLI2\n";


BEGIN 
{
    if ( not $dbh=YEP::Utils::db_connect() )
    {
        die "ERROR: Could not connect to the database";
    }

    #print "hello CLI\n";
    $cfg = new Config::IniFiles( -file => "/etc/yep.conf" );
    if(!defined $cfg)
    {
        die "Cannot read the YEP configuration file: ".@Config::IniFiles::errors;
    }
}

sub listProducts()
{
    my $sth = $dbh->prepare(qq{select * from Products});
    $sth->execute();
    while (my ( $PRODUCTDATAD,
                $PRODUCT,
                $VERSION,
                $RELEASE,
                $ARCH,
                $PRODUCTLOWER,
                $VERSIONLOWER,
                $RELEASELOWER,
                $ARCHLOWER,
                $FRIENDLY,
                $PARAMLIST,
                $NEEDINFO,
                $SERVICE,
                $PRODUCT_LIST ) =
                $sth->fetchrow_array())  # keep fetching until 
                                         # there's nothing left
    {
        #print "$nickname, $favorite_number\n";
        print "$PRODUCT\n";
    }
    $sth->finish();
}

sub listRegistrations()
{
    my $sth = $dbh->prepare(qq{select r.GUID,p.PRODUCT from Registration r, Products p where r.PRODUCTID=p.PRODUCTDATAID});
    $sth->execute();
     while (my @values =
                 $sth->fetchrow_array())  # keep fetching until 
                                          # there's nothing left
    {
        #print "$nickname, $favorite_number\n";
        print "[" . $values[0] . "]" . " => " . $values[1] . "\n";
    }
    $sth->finish();
}

sub resetCatalogsStatus()
{
  my $sth = $dbh->prepare(qq{UPDATE Catalogs SET Mirrorable='N' WHERE 1});
  $sth->execute();
}

sub setMirrorableCatalogs()
{
    # TODO move the url assembling code out
    my $NUUrl = $cfg->val("NU", "NUUrl");
    if(!defined $NUUrl || $NUUrl eq "")
    {
      die "Cannot read NU Url";
    }

    my $nuUser = $cfg->val("NU", "NUUser");
    my $nuPass = $cfg->val("NU", "NUPass");
    
    if(!defined $nuUser || $nuUser eq "" ||
      !defined $nuPass || $nuPass eq "")
    {
        die "Cannot read the Mirror Credentials";
    }

    my $uri = URI->new($NUUrl);
    $uri->userinfo("$nuUser:$nuPass");

    # create a tmpdir to store repoindex.xml
    my $tempdir = File::Temp::tempdir(CLEANUP => 1);

    # get the file
    my $job = YEP::Mirror::Job->new();
    $job->uri($uri);
    $job->localdir($tempdir);
    $job->resource("/repo/repoindex.xml");
    
    $job->mirror();

    my $parser = YEP::Parser::NU->new();
    $parser->parse($job->local(), sub {
                                      my $repodata = shift;
                                      print $repodata->{NAME} . " from " . $job->{URI} ."\n";
                                  }
    );
}

1;

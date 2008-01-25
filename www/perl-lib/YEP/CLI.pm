package YEP::CLI;
use strict;
use warnings;

=head1 NAME

 YEP::CLI - YEP common actions for command line programs

=head1 SYNOPSIS

  YEP::listProducts();
  YEP::listCatalogs();
  YEP::setupCustomCatalogs();

=head1 DESCRIPTION

Common actions used in command line utilities that administer the
YEP system.

=head1 METHODS

=over 4

=item listProducts

Shows products. Pass mirrorable => 1 to get only mirrorable
products. 0 for non-mirrorable products, or nothing to get all
products.

=item listRegistrations

Shows active registrations on the system.


=item setupCustomCatalogs

modify the database to setup catalogs create by the customer

=back

=back

=head1 AUTHOR

dmacvicar@suse.de

=head1 COPYRIGHT

Copyright 2007, 2008 SUSE LINUX Products GmbH, Nuernberg, Germany.

=cut


use URI;
use YEP::Utils;
use Config::IniFiles;
use File::Temp;
use YEP::Parser::NU;
use YEP::Mirror::Job;

use vars qw($cfg $dbh $nuri);

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

    $nuri = URI->new($NUUrl);
    $nuri->userinfo("$nuUser:$nuPass");
}

sub listCatalogs
{
    my %options = @_;
    my $sql = "select * from Catalogs";

    $sql = $sql . " where 1";

    if ( exists $options{ mirrorable } && defined $options{mirrorable} )
    {
          if (  $options{ mirrorable } == 1 )
          {
            $sql = $sql . " and MIRRORABLE='Y'";
          }
          else
          {
            $sql = $sql . " and MIRRORABLE='N'";
          }
    }
    
    if ( exists $options{ domirror } && defined  $options{ domirror } )
    {
          if (  $options{ domirror } == 1 )
          {
            $sql = $sql . " and DOMIRROR='Y'";
          }
          else
          {
            $sql = $sql . " and DOMIRROR='N'";
          }
    }

    my $sth = $dbh->prepare($sql);
    $sth->execute();
    while (my @values = $sth->fetchrow_array())  
    {
        print "[" . $values[1] . "] " . $values[2] . "\n";
        if ( exists $options{ verbose } && defined $options{verbose} )
        {
          print "|\\-local-path => " . $values[4] . "\n";
          print "| -url        => " . $values[5] . "\n";
          print "| -type       => " . $values[6] . "\n";
          print "| -mirrorable => " . $values[7] . "\n";
          print "| -mirror?    => " . $values[8] . "\n";
        }
    }
    $sth->finish();
}

sub listProducts
{
    my %options = @_;

    my $sth = $dbh->prepare(qq{select * from Products});
    $sth->execute();
    while (my ( $PRODUCTDATAD,
                $PRODUCT,
                $VERSION,
                $REL,
                $ARCH,
                $PRODUCTLOWER,
                $VERSIONLOWER,
                $RELLOWER,
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
        print "$PRODUCT $VERSION $ARCH\n";
        if ( exists $options{ verbose } && defined $options{verbose} )
        {
          #print "$PARAMLIST\n";
        }
    }
    $sth->finish();
}

sub listRegistrations
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

sub resetCatalogsStatus
{
  my $sth = $dbh->prepare(qq{UPDATE Catalogs SET Mirrorable='N' WHERE CATALOGTYPE='nu'});
  $sth->execute();
}

sub setMirrorableCatalogs
{
    # create a tmpdir to store repoindex.xml
    my $tempdir = File::Temp::tempdir(CLEANUP => 1);

    # get the file
    my $job = YEP::Mirror::Job->new();
    $job->uri($nuri);
    $job->localdir($tempdir);
    $job->resource("/repo/repoindex.xml");
    
    $job->mirror();

    my $parser = YEP::Parser::NU->new();
    $parser->parse($job->local(), sub {
                                      my $repodata = shift;
                                      print "* set [" . $repodata->{NAME} . "] [" . $repodata->{DISTRO_TARGET} . "] as mirrorable.\n";
                                      my $sth = $dbh->do( sprintf("UPDATE Catalogs SET Mirrorable='Y' WHERE NAME=%s AND TARGET=%s", $dbh->quote($repodata->{NAME}), $dbh->quote($repodata->{DISTRO_TARGET}) ));
                                  }
    );

    my $sql = "select CATALOGID, NAME, LOCALPATH, EXTURL, TARGET from Catalogs where CATALOGTYPE='yum'";
    #my $sth = $dbh->prepare($sql);
    #$sth->execute();
    #while (my @values = $sth->fetchrow_array())
    my $values = $dbh->selectall_arrayref($sql);
    foreach my $v (@{$values})
    { 
        my $catName = $v->[1];
        my $catLocal = $v->[2];
        my $catUrl = $v->[3];
        my $catTarget = $v->[4];
        if( $catUrl ne "" && $catLocal ne "" )
        {
            my $tempdir = File::Temp::tempdir(CLEANUP => 1);
            my $job = YEP::Mirror::Job->new();
            $job->uri($catUrl);
            $job->localdir($tempdir);
            $job->resource("/repodata/repomd.xml");
          
            # if no error
            my $ret = $job->mirror();
            
            print "* set [" . $catName . "] as " . ( ($ret == 0) ? '' : ' not ' ) . " mirrorable.\n";
            my $sth = $dbh->do( sprintf("UPDATE Catalogs SET Mirrorable=%s WHERE NAME=%s AND TARGET=%s", ( ($ret == 0) ? $dbh->quote('Y') : $dbh->quote('N') ), $dbh->quote($catName), $dbh->quote($catTarget) ) );
        }
    }

}

sub removeCustomCatalog
{
    my %options = @_;

    # delete existing catalogs with this id

    my $affected1 = $dbh->do(sprintf("DELETE from Catalogs where CATALOGID=%s", $dbh->quote($options{catalogid})));
    my $affected2 = $dbh->do(sprintf("DELETE from ProductCatalogs where CATALOGID=%s", $dbh->quote($options{catalogid})));

    return ($affected1 || $affected2);
}

sub setupCustomCatalogs
{
    my %options = @_;
    
    # delete existing catalogs with this id
    
    removeCustomCatalog(%options);
    
    # now insert it again.
    my $affected = $dbh->do(sprintf("INSERT INTO Catalogs VALUES(%s, %s, %s, %s, %s, %s, %s, %s, %s)",
                                     $dbh->quote($options{catalogid}),
                                     $dbh->quote($options{name}),
                                     $dbh->quote($options{description}),
                                     "NULL",
                                     $dbh->quote("/YUM/".$options{name}),
                                     $dbh->quote($options{exturl}),
                                     $dbh->quote("yum"),
                                     $dbh->quote("Y"),
                                     $dbh->quote("Y")));
    foreach my $pid (@{$options{productids}})
    {
        $affected += $dbh->do(sprintf("INSERT INTO ProductCatalogs VALUES(%s, %s, %s)",
                                      $pid,
                                      $dbh->quote($options{catalogid}),
                                      $dbh->quote("N")));
    }
    
    return (($affected>0)?1:0);
}


1;

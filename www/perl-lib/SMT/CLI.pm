package SMT::CLI;
use strict;
use warnings;

use URI;
use SMT::Utils;
use DBI qw(:sql_types);
use Text::ASCIITable;
use Config::IniFiles;
use File::Temp;
use IO::File;
use SMT::Parser::NU;
use SMT::Mirror::Job;
use XML::Writer;

use File::Basename;
use Digest::SHA1  qw(sha1 sha1_hex);
use Time::HiRes qw(gettimeofday tv_interval);

use LIMAL;
use LIMAL::CaMgm;

use Locale::gettext ();
use POSIX ();     # Needed for setlocale()

POSIX::setlocale(&POSIX::LC_MESSAGES, "");

sub init
{
    my $dbh;
    my $cfg;
    my $nuri;
    if ( not $dbh=SMT::Utils::db_connect() )
    {
        die __("ERROR: Could not connect to the database");
    }

    #print "hello CLI\n";
    $cfg = new Config::IniFiles( -file => "/etc/smt.conf" );
    if(!defined $cfg)
    {
        die __("Cannot read the SMT configuration file: ").@Config::IniFiles::errors;
    }

    # TODO move the url assembling code out
    my $NUUrl = $cfg->val("NU", "NUUrl");
    if(!defined $NUUrl || $NUUrl eq "")
    {
      die __("Cannot read NU Url");
    }

    my $nuUser = $cfg->val("NU", "NUUser");
    my $nuPass = $cfg->val("NU", "NUPass");
    
    if(!defined $nuUser || $nuUser eq "" ||
      !defined $nuPass || $nuPass eq "")
    {
        die __("Cannot read the Mirror Credentials");
    }

    $nuri = URI->new($NUUrl);
    $nuri->userinfo("$nuUser:$nuPass");

    return ($cfg, $dbh, $nuri);
}


#
# escapeCSVRow
#   takes an array of values and returns an escaped CSV row string
#
sub escapeCSVRow($)
{
    my $arr = shift;
    if (! defined $arr) { return ''; }
    my $str = '';

    foreach my $val (@{$arr})
    {
        $val =~ s/\"/\"\"/g;    # double all quotation marks
        $str .= '"'.$val.'",';  # delimit strings with quotation marks
    }
    $str =~ s/,$//;             # remove trailing comma
    return $str;
}



#
# renders a report table either as ASCII-Table or in CSV format
#
#   takes two parameters:
#      - a hash for the data
#      - format mode
#   Examples:
#   $data = (
#     'cols' = [ "first", "second",    ...  ],
#     'vals' = [ [a1,a2], [b1,b2],     ...  ],
#     'opts' = {'optname' => 'optval', ...  },
#     'heading' = "header string"
#   );
#   $mode = 'asciitable';
#   $mode = 'csv';
#
sub renderReport($$)
{
    my $d    = shift; 
    my $mode = shift;
    my $res = '';

    # return empty string in case needed data is missing
    if ( ! defined $d || ! defined $mode) { return ''; }

    my %data = (%{$d});
    if ( ! exists  $data{'cols'} ||
         ! exists  $data{'vals'} ||
         ! defined $data{'cols'} ||  
         ! defined $data{'vals'}    )  { return ''; }
   
    # general handling of header string 
    my $heading  = undef;
    if (exists $data{'opts'}{'headingText'}  &&  defined $data{'opts'}{'headingText'})
    { $heading = $data{'opts'}{'headingText'}; }
    if (exists $data{'heading'}  &&  defined $data{'heading'})
    { $heading = $data{'heading'}; }


    if ($mode eq 'asciitable')
    {
        my $t = new Text::ASCIITable;

        # set options
        if (exists $data{'opts'}  &&  defined $data{'opts'})
        {
            while (my ($key,$val) = each(%{$data{'opts'}}))
            {
                $t->setOptions($key,$val);
            }
        }

        # overwrite heading if defined
        if (defined $heading)
        {
            $t->setOptions('headingText', $heading);
        }

        $t->setCols(@{$data{'cols'}});
        # addRow may fail with long lists, so do it one by one
        foreach my $row (@{$data{'vals'}})
        {
            $t->addRow($row);
        }

        $res = $t->draw();
        
    }
    elsif ($mode eq 'csv') 
    {
        my @valbody  = [];

        # no header in csv file - first row must be cols

        # add title/cols row
        $res .= escapeCSVRow(\@{$data{'cols'}});
        $res .= "\n";

        foreach my $valrow (@{$data{'vals'}})
        {
            $res .= escapeCSVRow(\@{$valrow});
            $res .= "\n";
        }
    }
    else
    {
        $res = '';
    }

    return $res;
}





sub getCatalogs
{
    my %options = @_;

    my ($cfg, $dbh, $nuri) = init();
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

    if ( exists $options{ name } && defined $options{name} )
    {
          $sql = $sql . sprintf(" and NAME=%s", $dbh->quote($options{name}));
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

    my @HEAD = ();
    my @VALUES = ();

    #push( @HEAD, "ID" );
    push( @HEAD, "Name" );
    push( @HEAD, "Description" );

    push( @HEAD, "Mirrorable" );
    push( @HEAD, "Mirror?" );


    my $counter = 1;
    while (my $values = $sth->fetchrow_hashref())  
    {
        my @row;
        #push( @row, $values->{CATALOGID} );
        #push( @row, $counter );
        push( @row, $values->{NAME} );
        push( @row, $values->{DESCRIPTION} );
        push( @row, $values->{MIRRORABLE} );
        push( @row, $values->{DOMIRROR} );
        #print $values->{CATALOGID} . " => [" . $values->{NAME} . "] " . $values->{DESCRIPTION} . "\n";
        
        push( @VALUES, @row );

        if ( exists $options{ used } && defined $options{used} )
        {
          push( @VALUES, ("", $values->{EXTURL},      "", "") );
          push( @VALUES, ("", $values->{LOCALPATH},   "", "") );
          push( @VALUES, ("", $values->{CATALOGTYPE}, "", "") );
        }
        
        $counter++;
    }
    $sth->finish();
    return {'cols' => \@HEAD, 'vals' => \@VALUES };
}

#
# wrapper function to keep compatibility while changing the called function
#
sub listCatalogs
{
    print renderReport(getCatalogs(@_), 'asciitable');
}


sub getProducts
{
    my %options = @_;
    my ($cfg, $dbh, $nuri) = init();

    my $sql = "select p.*,0+(select count(r.GUID) from Products p2, Registration r where r.PRODUCTID=p2.PRODUCTDATAID and p2.PRODUCTDATAID=p.PRODUCTDATAID) AS registered_machines from Products p where 1";

    my $sth = $dbh->prepare($sql);
    $sth->execute();


    my @HEAD = ( __('Name'), __('Version'), __('Target'), __('Release'), __('Usage') );
    my @VALUES = ();

    if(exists $options{catstat} && defined $options{catstat} && $options{catstat})
    {
        push @HEAD,  __('Catalogs mirrored?');
    }
    
    while (my $value = $sth->fetchrow_hashref())  # keep fetching until 
                                                   # there's nothing left
    {
        next if ( exists($options{ used }) && defined($options{used}) && (int($value->{registered_machines}) < 1) );
     
        if(exists $options{catstat} && defined $options{catstat} && $options{catstat})
        {
            my $statement = sprintf("select distinct c.DOMIRROR from ProductCatalogs pc, Catalogs c where pc.PRODUCTDATAID=%s and pc.CATALOGID = c.CATALOGID",
                                    $dbh->quote($value->{PRODUCTDATAID}));
            my $arr = $dbh->selectall_arrayref($statement);
            my $cm = __("No");
            
            if( @{$arr} == 0 )
            {
                # no catalogs required for this product => all catalogs available
                $cm = __("Yes");
            }
            elsif( @{$arr} == 1 )
            {
                if( uc($arr->[0]->[0]) eq "Y")
                {
                    # all catalogs available
                    $cm = __("Yes");
                }
                # else default is NO
            }
            # else some are available, some not => not all catalogs available
            
            
            push @VALUES, [ $value->{PRODUCT}, 
                            $value->{VERSION} || "-", 
                            $value->{ARCH}    || "-", 
                            $value->{REL}     || "-", 
                            $value->{registered_machines}, 
                            $cm ];
        }
        else
        {
            push @VALUES, [ $value->{PRODUCT}, 
                            $value->{VERSION} || "-", 
                            $value->{ARCH}    || "-", 
                            $value->{REL}     || "-", 
                            $value->{registered_machines} ];
        }
    }
   
    # FIXME this function (and all similar) should return the hash only and the caller should decide how to render and where to print the result
    #       for now keeping the print statment here to keep it working 
    $sth->finish();
    return {'cols' => \@HEAD, 'vals' => \@VALUES };
}


#
# wrapper function to keep compatibility while changing the called function
#
sub listProducts
{
    print renderReport(getProducts(@_), 'asciitable');
}


sub getRegistrations
{
    my ($cfg, $dbh, $nuri) = init();

    my $clients = $dbh->selectall_arrayref("SELECT GUID, HOSTNAME, LASTCONTACT from Clients ORDER BY LASTCONTACT", {Slice => {}});

    my @HEAD = ( __('Unique ID'), __('Hostname'), __('Last Contact'), __('Product') );
    my @VALUES = ();
    my %OPTIONS = ('drawRowLine' => 1 );

    foreach my $clnt (@{$clients})
    {
        my $products = $dbh->selectall_arrayref(sprintf("SELECT p.PRODUCT, p.VERSION, p.REL, p.ARCH from Products p, Registration r WHERE r.GUID=%s and r.PRODUCTID=p.PRODUCTDATAID", 
                                                        $dbh->quote($clnt->{GUID})), {Slice => {}});
        
        my $prdstr = "";
        foreach my $product (@{$products})
        {
            $prdstr .= $product->{PRODUCT} if(defined $product->{PRODUCT});
            $prdstr .= " ".$product->{VERSION} if(defined $product->{VERSION});
            $prdstr .= " ".$product->{REL} if(defined $product->{REL});
            $prdstr .= " ".$product->{ARCH} if(defined $product->{ARCH});
            $prdstr .= "\n";
        }
        push @VALUES, [ $clnt->{GUID}, $clnt->{HOSTNAME}, $clnt->{LASTCONTACT}, $prdstr ];
    }
    return {'cols' => \@HEAD, 'vals' => \@VALUES, 'opts' => \%OPTIONS };
}


#
# wrapper function to keep compatibility while changing the called function
#
sub listRegistrations
{
    print renderReport(getRegistrations(@_), 'asciitable');
}


sub enableCatalogsByProduct
{
    my %opts = @_;
    
    my ($cfg, $dbh, $nuri) = init();
    
    #( verbose => $verbose, prodStr => $enableByProduct)
    
    if(! exists $opts{prodStr} || ! defined $opts{prodStr} || $opts{prodStr} eq "")
    {
        print __("Invalid product string.\n");
        return 1;
    }
    my ($product, $version, $arch, $release) = split(/\s*,\s*/, $opts{prodStr}, 4);
    
    my $st1 = sprintf("select PRODUCTDATAID from Products where PRODUCT=%s ", $dbh->quote($product));
    
    if(defined $version && $version ne "")
    {
        $st1 .= sprintf(" and VERSION=%s ", $dbh->quote($version));
    }
    if(defined $arch && $arch ne "")
    {
        $st1 .= sprintf(" and ARCH=%s ", $dbh->quote($arch));
    }
    if(defined $release && $release ne "")
    {
        $st1 .= sprintf(" and REL=%s ", $dbh->quote($release));
    }
    
    my $statement = "select distinct pc.CATALOGID, c.NAME, c.TARGET, c.MIRRORABLE from ProductCatalogs pc, Catalogs c where PRODUCTDATAID IN ($st1) and pc.CATALOGID = c.CATALOGID order by NAME,TARGET;";
    
    #print "$statement \n";

    my $arr = $dbh->selectall_arrayref($statement, {Slice => {}});
    
    foreach my $row (@{$arr})
    {
        if(uc($row->{MIRRORABLE}) ne "Y")
        {
            print sprintf(__("Catalog [%s %s] cannot be enabled. Access on the server denied.\n"), 
                          $row->{NAME}, 
                          ($row->{TARGET}) ? $row->{TARGET} : "");
        }
        else
        {
            SMT::CLI::setCatalogDoMirror(enabled => 1, name => $row->{NAME}, target => $row->{TARGET});
            print sprintf(__("Catalog [%s %s] enabled.\n"),
                          $row->{NAME}, 
                          ($row->{TARGET}) ? $row->{TARGET} : "");
        }
    }
    return 0;
}

sub resetCatalogsStatus
{
  my ($cfg, $dbh, $nuri) = init();

  my $sth = $dbh->prepare(qq{UPDATE Catalogs SET Mirrorable='N' WHERE CATALOGTYPE='nu'});
  $sth->execute();
}

sub setCatalogDoMirror
{
  my %opt = @_;
  my ($cfg, $dbh, $nuri) = init();

  if(exists $opt{enabled} && defined $opt{enabled} )
  {
    my $sql = "update Catalogs";
    $sql .= sprintf(" set Domirror=%s", $dbh->quote(  $opt{enabled} ? "Y" : "N" ) ); 

    $sql .= " where 1";

    $sql .= sprintf(" and Mirrorable=%s", $dbh->quote("Y"));

    if(exists $opt{name} && defined $opt{name} )
    {
      $sql .= sprintf(" and NAME=%s", $dbh->quote($opt{name}));
    }

    if(exists $opt{target} && defined $opt{target} )
    {
      $sql .= sprintf(" and TARGET=%s", $dbh->quote($opt{target}));
    }

    if(exists $opt{id} && defined $opt{id} )
    {
      $sql .= sprintf(" and CATALOGID=%s", $dbh->quote($opt{id}));
    }

    #print $sql . "\n";
    my $sth = $dbh->prepare($sql);
    $sth->execute();

  }
  else
  {
    die __("enabled option missing");
  }
}

sub catalogDoMirrorFlag
{
  my %options = @_;
  my ($cfg, $dbh, $nuri) = init();
  return 1;
}

sub setMirrorableCatalogs
{
    my %opt = @_;
    my ($cfg, $dbh, $nuri) = init();

    # create a tmpdir to store repoindex.xml
    my $destdir = File::Temp::tempdir(CLEANUP => 1);
    my $indexfile = "";
    if(exists $opt{todir} && defined $opt{todir} && -d $opt{todir})
    {
        $destdir = $opt{todir};
    }

    if(exists $opt{fromdir} && defined $opt{fromdir} && -d $opt{fromdir})
    {
        $indexfile = $opt{fromdir}."/repo/repoindex.xml";
    }
    else
    {
        # get the file
        my $job = SMT::Mirror::Job->new();
        $job->uri($nuri);
        $job->localdir($destdir);
        $job->resource("/repo/repoindex.xml");
    
        $job->mirror();
        $indexfile = $job->local();
    }

    if(exists $opt{todir} && defined $opt{todir} && -d $opt{todir})
    {
        # with todir we only want to mirror repoindex to todir
        return;
    }

    my $parser = SMT::Parser::NU->new();
    $parser->parse($indexfile, 
                   sub {
                       my $repodata = shift;
                       printLog($opt{log}, "info", sprintf(__("* set [%s %s] as mirrorable."), 
                                                           $repodata->{NAME}, $repodata->{DISTRO_TARGET}));
                       my $sth = $dbh->do( sprintf("UPDATE Catalogs SET Mirrorable='Y' WHERE NAME=%s AND TARGET=%s", 
                                                   $dbh->quote($repodata->{NAME}), $dbh->quote($repodata->{DISTRO_TARGET}) ));
                   }
    );

    my $sql = "select CATALOGID, NAME, LOCALPATH, EXTURL, TARGET from Catalogs where CATALOGTYPE='zypp'";
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
	    my $ret = 1;
            if(exists $opt{fromdir} && defined $opt{fromdir} && -d $opt{fromdir})
            {
		    # fromdir is used on a server without internet connection
		    # we define that the catalogs are mirrorable
		    $ret = 0;
	    }
	    else
	    {
    	        my $tempdir = File::Temp::tempdir(CLEANUP => 1);
                my $job = SMT::Mirror::Job->new();
                $job->uri($catUrl);
                $job->localdir($tempdir);
                $job->resource("/repodata/repomd.xml");
          
                # if no error
                $ret = $job->mirror();
	    }
        printLog($opt{log}, "info", sprintf(__("* set [%s] as%s mirrorable."), $catName, ( ($ret == 0) ? '' : ' not' )));
        my $sth = $dbh->do( sprintf("UPDATE Catalogs SET Mirrorable=%s WHERE NAME=%s AND TARGET=%s", 
                                    ( ($ret == 0) ? $dbh->quote('Y') : $dbh->quote('N') ), 
                                    $dbh->quote($catName), 
                                    $dbh->quote($catTarget) ) );
        }
    }

    my $mirrorAll = $cfg->val("LOCAL", "MirrorAll");
    if(defined $mirrorAll && lc($mirrorAll) eq "true")
    {
        # set DOMIRROR to Y where MIRRORABLE = Y
        $dbh->do("UPDATE Catalogs SET DOMIRROR='Y' WHERE MIRRORABLE='Y'");
    }
}

sub removeCustomCatalog
{
    my %options = @_;
    my ($cfg, $dbh, $nuri) = init();

    # delete existing catalogs with this id

    my $affected1 = $dbh->do(sprintf("DELETE from Catalogs where CATALOGID=%s", $dbh->quote($options{catalogid})));
    my $affected2 = $dbh->do(sprintf("DELETE from ProductCatalogs where CATALOGID=%s", $dbh->quote($options{catalogid})));

    return ($affected1 || $affected2);
}

sub setupCustomCatalogs
{
    my %options = @_;
    my ($cfg, $dbh, $nuri) = init();

    # delete existing catalogs with this id
    
    removeCustomCatalog(%options);
    
    # now insert it again.
    my $exthost = $options{exturl};
    $exthost =~ /^(https?:\/\/[^\/]+\/)/;
    $exthost = $1;

    my $affected = $dbh->do(sprintf("INSERT INTO Catalogs (CATALOGID, NAME, DESCRIPTION, TARGET, LOCALPATH, EXTHOST, EXTURL, CATALOGTYPE, DOMIRROR,MIRRORABLE ) VALUES(%s, %s, %s, %s, %s, %s, %s, %s, %s, %s)",
                                    $dbh->quote($options{catalogid}),
                                    $dbh->quote($options{name}),
                                    $dbh->quote($options{description}),
                                    "NULL",
                                    $dbh->quote("/RPMMD/".$options{name}),
                                    $dbh->quote($exthost),
                                    $dbh->quote($options{exturl}),
                                    $dbh->quote("zypp"),
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

sub createDBReplacementFile
{
    my $xmlfile = shift;
    my ($cfg, $dbh, $nuri) = init();

    my $dbout = $dbh->selectall_hashref("SELECT CATALOGID, NAME, DESCRIPTION, TARGET, EXTURL, LOCALPATH, CATALOGTYPE from Catalogs where DOMIRROR = 'Y'", 
                                        "CATALOGID");

    my $output = new IO::File(">$xmlfile");
    my $writer = new XML::Writer(OUTPUT => $output);

    $writer->xmlDecl("UTF-8");
    $writer->startTag("catalogs", xmlns => "http://www.novell.com/xml/center/regsvc-1_0");

    foreach my $row (keys %{$dbout})
    {
        $writer->startTag("row");
        foreach my $col (keys %{$dbout->{$row}})
        {
            $writer->startTag("col", name => $col);
            $writer->characters($dbout->{$row}->{$col});
            $writer->endTag("col");
        }
        $writer->endTag("row");
    }
    $writer->endTag("catalogs");
    $writer->end();
    $output->close();

    return ;
}

sub hardlink
{
    my %options = @_;
    my ($cfg, $dbh, $nuri) = init();
    my $t0 = [gettimeofday] ;

    my $debug = 0;
    $debug = $options{debug} if(exists $options{debug} && defined $options{debug});
    
    my $dir = "";
    if(! exists $options{basepath} || ! defined $options{basepath} || ! -d $options{basepath})
    {
        $dir = $cfg->val("LOCAL", "MirrorTo");
        if(!defined $dir || $dir eq "" || ! -d $dir)
        {
            printLog($options{log}, "error", sprintf("Wrong mirror directory: %s", $dir));
            return 1;
        }
    }
    else
    {
        $dir = $options{basepath};
    }
    
    my $cmd = "find $dir -xdev -iname '*.rpm' -type f -size +$options{size}k ";
    printLog($options{log}, "info", "$cmd") if($debug);
    
    my $filelist = `$cmd`;
    my @files = sort split(/\n/, $filelist);
    my @f2 = @files;
    
    foreach my $MM (@files)
    {
        foreach my $NN (@f2)
        {
            next if (!defined $NN);

            if( $NN ne $MM  &&  basename($MM) eq basename($NN) )
            {
                printLog($options{log}, "info", "$MM ");
                printLog($options{log}, "info", "$NN ");
                if( (stat($MM))[1] != (stat($NN))[1] )
                {
                    my $sha1MM = _sha1sum($MM);
                    my $sha1NN = _sha1sum($NN);
                    if(defined $sha1MM && defined $sha1NN && $sha1MM eq $sha1NN)
                    {
                        printLog($options{log}, "info", "Do hardlink");
                        #my $ret = link $MM, $NN;
                        #print "RET: $ret\n";
                        `ln -f '$MM' '$NN'`;
                        $NN = undef;
                    }
                    else
                    {
                        printLog($options{log}, "info", "Checksums does not match $sha1MM != $sha1NN.");
                    }
                }
                else
                {
                    printLog($options{log}, "info", "Files are hard linked. Nothing to do.");
                    $NN = undef;
                }
            }
            elsif($NN eq $MM)
            {
                $NN = undef;
            }
        }
    }
    printLog($options{log}, "info", sprintf(__("Hardlink Time      : %s seconds"), (tv_interval($t0))));
}

sub productClassReport
{
    my %options = @_;
    my ($cfg, $dbh, $nuri) = init();
    my %conf;
    
    my $debug = 0;
    $debug = $options{debug} if(exists $options{debug} && defined $options{debug});
    
    if(exists $options{conf} && defined $options{conf} && ref($options{conf}) eq "HASH")
    {
        %conf = %{$options{conf}};
    }
    else
    {
        printLog($options{log}, "error", "Invalid configuration provided.");
        return undef;
    }
   
    my @HEAD = ( __("Product Class"), __("Architecture"), __("Installed Clients") ); 
    my @VALUES = ();   
    
    my $classes = $dbh->selectcol_arrayref("SELECT DISTINCT PRODUCT_CLASS from Products where PRODUCT_CLASS is not NULL");
    
    foreach my $class (@{$classes})
    {
        my $found = 0;
        
        my $cn = $class;
        $cn = $conf{$class}->{NAME} if(exists $conf{$class}->{NAME} && defined $conf{$class}->{NAME});
        
        my %groups = %{$conf{SMT_DEFAULT}->{ARCHGROUPS}};
        %groups = %{$conf{$class}->{ARCHGROUPS}} if(exists $conf{$class}->{ARCHGROUPS} && defined $conf{$class}->{ARCHGROUPS});
        
        foreach my $archgroup (keys %groups)
        {
            my $statement = "SELECT COUNT(DISTINCT GUID) from Registration where PRODUCTID IN (";
            $statement .= sprintf("SELECT PRODUCTDATAID from Products where PRODUCT_CLASS=%s AND ", 
                                  $dbh->quote($class));
            
            if(@{$groups{$archgroup}} == 1)
            {
                if(defined @{$groups{$archgroup}}[0])
                {
                    $statement .= sprintf(" ARCHLOWER = %s", $dbh->quote(@{$groups{$archgroup}}[0]));
                }
                else
                {
                    $statement .= " ARCHLOWER IS NULL";
                }
            }
            elsif(@{$groups{$archgroup}} > 1)
            {
                $statement .= sprintf(" ARCHLOWER IN('%s')", join("','", @{$groups{$archgroup}}));
            }
            else
            {
                die "This should not happen";
            }
            
            $statement .= ")";
            
            printLog($options{log}, "debug", "STATEMENT: $statement") if($debug);
            
            my $count = $dbh->selectcol_arrayref($statement);
            
            if(exists $count->[0] && defined $count->[0] && $count->[0] > 0)
            {
                push @VALUES, [ "$cn", $archgroup, $count->[0] ];
                $found = 1;
            }
        }
        
        if(!$found)
        {
            # this select is for products which do not have an architecture set (ARCHLOWER is NULL) 
            my $statement = "SELECT COUNT(DISTINCT GUID) from Registration where PRODUCTID IN (";
            $statement .= sprintf("SELECT PRODUCTDATAID from Products where PRODUCT_CLASS=%s)", 
                                  $dbh->quote($class));
            
            printLog($options{log}, "debug", "STATEMENT: $statement") if ($debug);
            
            my $count = $dbh->selectcol_arrayref($statement);
            
            if(exists $count->[0] && defined $count->[0] && $count->[0] > 0)
            {
                push @VALUES, [ "$cn", "", $count->[0] ];
                $found = 1;
            }
        }
    }
    return {'cols' => \@HEAD, 'vals' => \@VALUES };
}

sub productSubscriptionReport
{
    my %options = @_;
    my ($cfg, $dbh, $nuri) = init();
    my %report = ();
    
    my $debug = 0;
    $debug = $options{debug} if(exists $options{debug} && defined $options{debug});

    my $statement = "";
    my $time = SMT::Utils::getDBTimestamp();
    my $calchash = {};
    my $expireSoonMachines = {};
    my $expiredMachines = {};
    my $nowP30day = SMT::Utils::getDBTimestamp((time + (30*24*60*60)));
    my $sth = undef;

    $statement = "select SUBNAME, REGCODE from Subscriptions group by SUBNAME;";

    printLog($options{log}, "debug", "STATEMENT: $statement") if ($debug);

    my $res = $dbh->selectall_hashref($statement, "REGCODE");

    foreach my $regcode (keys %{$res})
    {
        $statement = sprintf("SELECT COUNT(DISTINCT r.GUID) from Products p, Registration r where r.PRODUCTID=p.PRODUCTDATAID and p.PRODUCTDATAID IN (SELECT DISTINCT PRODUCTDATAID from ProductSubscriptions ps where ps.REGCODE = %s)", 
                             $dbh->quote($regcode));

        printLog($options{log}, "debug", "STATEMENT: $statement") if ($debug);
        
        my $count = $dbh->selectcol_arrayref($statement);
        
        if(exists $count->[0] && defined $count->[0])
        {
            $calchash->{$res->{$regcode}->{SUBNAME}}->{MACHINES} = int $count->[0];
        }
    }

    #
    # Active Subscriptions
    #
    
    $statement  = "select REGCODE, SUBNAME, SUBSTATUS, SUM(NODECOUNT) as SUM_NODECOUNT, MIN(NODECOUNT) = -1 as UNLIMITED, MIN(SUBENDDATE) as MINENDDATE ";
    $statement .= "from Subscriptions where SUBSTATUS = 'ACTIVE' and ? < SUBENDDATE ";
    $statement .= "group by SUBNAME order by SUBNAME;";
    $sth = $dbh->prepare($statement);
    $sth->bind_param(1, $nowP30day, SQL_TIMESTAMP);
    $sth->execute;
    $res = $sth->fetchall_hashref("SUBNAME");

    printLog($options{log}, "debug", "STATEMENT: ".$sth->{Statement}) if ($debug);
    
    my @AHEAD = ( __('Subscription'), __('Node Count'), __('Assigned Machines'), __('Expiring Date') ); 
    my @AVALUES = ();
    my %AOPTIONS = ( 'headingText' => __("Active Subscriptions"." ($time)" ) );

    foreach my $subname (keys %{$res})
    {
        my $assignedMachines = 0;
        my $nc = 0;
        
        if($res->{$subname}->{UNLIMITED})
        {
            $assignedMachines = int $calchash->{$subname}->{MACHINES};
            $calchash->{$subname}->{MACHINES} = 0;
            $nc = "unlimited";
        }
        else
        {
            $nc = (int $res->{$subname}->{SUM_NODECOUNT});
            if($nc >= (int $calchash->{$subname}->{MACHINES}))
            {
                $assignedMachines = $calchash->{$subname}->{MACHINES};
                $calchash->{$subname}->{MACHINES} = 0;
            }
            else
            {
                $assignedMachines = $nc;
                $calchash->{$subname}->{MACHINES} -= $nc;                
            }
        }
                
        push @AVALUES, [ $res->{$subname}->{SUBNAME},
                        $nc,
                        $assignedMachines,
                        $res->{$subname}->{MINENDDATE}
                       ];
    }
    $report{'active'} = {'cols' => \@AHEAD, 'vals' => \@AVALUES, 'opts' => \%AOPTIONS };

    #
    # Expire soon
    #
    
    $statement  = "select REGCODE, SUBNAME, SUBSTATUS, SUM(NODECOUNT) as SUM_NODECOUNT, MIN(NODECOUNT) = -1 as UNLIMITED, MIN(SUBENDDATE) as MINENDDATE ";
    $statement .= "from Subscriptions where SUBSTATUS = 'ACTIVE' and ? > SUBENDDATE ";
    $statement .= "group by SUBNAME order by SUBNAME;";
    $sth = $dbh->prepare($statement);
    $sth->bind_param(1, $nowP30day, SQL_TIMESTAMP);
    $sth->execute;
    $res = $sth->fetchall_hashref("SUBNAME");

    printLog($options{log}, "debug", "STATEMENT: ".$sth->{Statement}) if ($debug);
    
    my @SHEAD = ( __('Subscription'), __('Node Count'), __('Assigned Machines'), __('Expiring Date'));
    my @SVALUES = ();
    my %SOPTIONS = ( 'headingText' => __("Subscriptions which expired within the next 30 days")." ($time)" );

    foreach my $subname (keys %{$res})
    {
        my $assignedMachines = 0;
        my $nc = 0;
        
        if($res->{$subname}->{UNLIMITED})
        {
            $assignedMachines = $calchash->{$subname}->{MACHINES};
            $calchash->{$subname}->{MACHINES} = 0;
            $nc = "unlimited";
        }
        else
        {
            $nc = (int $res->{$subname}->{SUM_NODECOUNT});
            if($nc >= (int $calchash->{$subname}->{MACHINES}))
            {
                $assignedMachines = $calchash->{$subname}->{MACHINES};
                $calchash->{$subname}->{MACHINES} = 0;
            }
            else
            {
                $assignedMachines = $nc;
                $calchash->{$subname}->{MACHINES} -= $nc;                
            }
        }

        if($assignedMachines > 0)
        {
            $expireSoonMachines->{$subname} += int $assignedMachines;
        }
        
        push @SVALUES, [ $res->{$subname}->{SUBNAME},
                         $nc,
                         $assignedMachines,
                         $res->{$subname}->{MINENDDATE}
                      ];
    }
    $report{'soon'} = {'cols' => \@SHEAD, 'vals' => \@SVALUES, 'opts' => \%SOPTIONS };


    #
    # Expired Subscriptions
    #
    
    $statement  = "select REGCODE, SUBNAME, SUBSTATUS, SUM(NODECOUNT) as SUM_NODECOUNT, MIN(NODECOUNT) = -1 as UNLIMITED, MAX(SUBENDDATE) as MAXENDDATE ";
    $statement .= "from Subscriptions where SUBSTATUS = 'EXPIRED' ";
    $statement .= "group by SUBNAME order by SUBNAME;";
    
    printLog($options{log}, "debug", "STATEMENT: $statement") if ($debug);

    $res = $dbh->selectall_hashref($statement, "SUBNAME");

    my @EHEAD = ( __('Subscription'), __('Node Count'), __('Assigned Machines'), __('Expiring Date'));
    my @EVALUES = ();
    my %EOPTIONS = ( 'headingText' => __("Expired Subscriptions")." ($time)" );
    my $doDraw = 0;
    
    foreach my $subname (keys %{$res})
    {
        my $assignedMachines = 0;
        my $nc = 0;
        
        $assignedMachines = int $calchash->{$subname}->{MACHINES};

        if($res->{$subname}->{UNLIMITED})
        {
            $nc = "unlimited";
        }
        else
        {
            $nc = (int $res->{$subname}->{SUM_NODECOUNT});
        }

        next if($assignedMachines == 0);
        $doDraw = 1;

        $expiredMachines->{$subname} += int $assignedMachines;
        
        push @EVALUES, [ $res->{$subname}->{SUBNAME},
                         $nc,
                         $assignedMachines,
                         $res->{$subname}->{MAXENDDATE}
                       ];
    }

    $report{'expired'} = $doDraw ? {'cols' => \@EHEAD, 'vals' => \@EVALUES, 'opts' => \%EOPTIONS } : undef; 
   
    my $summary = ''; 
    $summary .= __("Summary:\n");
    $summary .=    "========\n\n";

    my $ok = 1;

    foreach my $subname (keys %{$expireSoonMachines})
    {
        if($expireSoonMachines->{$subname} > 0)
        {
            $summary .= sprintf(__("%d Machines are assigned to '%s', which expires within the next 30 Days. Please renew the subscription.\n"), 
                               $expireSoonMachines->{$subname},
                               $subname);
            $ok = 0;
        }
    }

    foreach my $subname (keys %{$expiredMachines})
    {
        if($expiredMachines->{$subname} > 0)
        {
            $summary .= sprintf(__("%d Machines are assigned to '%s', which is expired. Please renew the subscription.\n"), 
                               $expireSoonMachines->{$subname},
                               $subname);
            $ok = 0;
        }
    }

    if($ok)
    {
        $summary .= __("The Subscription status is ok.\n");
    }    

    $report{'summary'} = $summary;
    
    return \%report;
}


sub subscriptionReport
{
    my %options = @_;
    my ($cfg, $dbh, $nuri) = init();
    my %report = ();
    my $nowP30day = SMT::Utils::getDBTimestamp((time + (30*24*60*60)));
    my $sth = undef;
    
    my $debug = 0;
    $debug = $options{debug} if(exists $options{debug} && defined $options{debug});

    my $statement = "";
    my $time = SMT::Utils::getDBTimestamp();
    my $calchash = {};
    
    #
    # active subscriptions
    #

    $statement  = "select s.SUBNAME, s.REGCODE, s.NODECOUNT, s.SUBSTATUS, s.SUBENDDATE from Subscriptions s ";
    $statement .= "where s.SUBSTATUS = 'ACTIVE' and ? < s.SUBENDDATE;";
    $sth = $dbh->prepare($statement);
    $sth->bind_param(1, $nowP30day, SQL_TIMESTAMP);
    $sth->execute;
    my $res = $sth->fetchall_hashref("REGCODE");

    printLog($options{log}, "debug", "STATEMENT: ".$sth->{Statement}) if ($debug);

    $statement  = "select s.REGCODE, COUNT(c.GUID) as MACHINES from Subscriptions s, ClientSubscriptions cs, Clients c ";
    $statement .= "where s.REGCODE = cs.REGCODE and cs.GUID = c.GUID and s.SUBSTATUS = 'ACTIVE' and ";
    $statement .= "? < s.SUBENDDATE group by REGCODE order by SUBENDDATE";
    $sth = $dbh->prepare($statement);
    $sth->bind_param(1, $nowP30day, SQL_TIMESTAMP);
    $sth->execute;
    my $assigned = $sth->fetchall_hashref("REGCODE");
                         
    printLog($options{log}, "debug", "STATEMENT: ".$sth->{Statement}) if ($debug);

    foreach my $regcode (keys %{$assigned})
    {
        if(exists $res->{$regcode})
        {
            $res->{$regcode}->{MACHINES} = $assigned->{$regcode}->{MACHINES};
        }
    }

    my @AHEAD = ( __('Subscription'), __('Registration Code'), __('Node Count'), __('Assigned Machines'), __('Expiring Date') );
    my @AVALUES = ();
    my %AOPTIONS = ( 'headingText' => __("Active Subscriptions")." ($time)" );

    foreach my $regcode (keys %{$res})
    {
        if(!exists $calchash->{$res->{$regcode}->{SUBNAME}})
        {
            $calchash->{$res->{$regcode}->{SUBNAME}}->{NODECOUNT} = (int $res->{$regcode}->{NODECOUNT});
            $calchash->{$res->{$regcode}->{SUBNAME}}->{MACHINES} = (exists $res->{$regcode}->{MACHINES})?(int $res->{$regcode}->{MACHINES}):0;
        }
        else
        {
            my $nc = $calchash->{$res->{$regcode}->{SUBNAME}}->{NODECOUNT};
            # nodecount == -1 means unlimited
            if($nc != -1)
            {
                if((int $res->{$regcode}->{NODECOUNT}) == -1)
                {
                    $nc = -1;
                }
                else
                {
                    $nc += (int $res->{$regcode}->{NODECOUNT});
                }
            }
            
            my $m = $calchash->{$res->{$regcode}->{SUBNAME}}->{MACHINES};
            
            if(exists $res->{$regcode}->{MACHINES})
            {
                $m += (int $res->{$regcode}->{MACHINES});
            }
            
            $calchash->{$res->{$regcode}->{SUBNAME}}->{NODECOUNT} = $nc;
            $calchash->{$res->{$regcode}->{SUBNAME}}->{MACHINES} = $m;
        }
        
        push @AVALUES, [ $res->{$regcode}->{SUBNAME},
                         $res->{$regcode}->{REGCODE},
                         ($res->{$regcode}->{NODECOUNT} == -1)?"unlimited":$res->{$regcode}->{NODECOUNT},
                         (exists $res->{$regcode}->{MACHINES})?$res->{$regcode}->{MACHINES}:0,
                        $res->{$regcode}->{SUBENDDATE}
                       ];
    }
    $report{'active'} = {'cols' => \@AHEAD, 'vals' => \@AVALUES, 'opts' => \%AOPTIONS };

    #
    # expire soon 
    #
    $statement  = "select s.SUBNAME, s.REGCODE, COUNT(c.GUID) as MACHINES, s.NODECOUNT, s.SUBSTATUS, s.SUBENDDATE ";
    $statement .= "from Subscriptions s, ClientSubscriptions cs, Clients c ";
    $statement .= "where s.REGCODE = cs.REGCODE and cs.GUID = c.GUID and s.SUBSTATUS = 'ACTIVE' and ? > s.SUBENDDATE group by REGCODE order by SUBENDDATE;";
    $sth = $dbh->prepare($statement);
    $sth->bind_param(1, $nowP30day, SQL_TIMESTAMP);
    $sth->execute;
    $res = $sth->fetchall_hashref("REGCODE");
    
    printLog($options{log}, "debug", "STATEMENT: ".$sth->{Statement}) if ($debug);

    my @SHEAD = ( __('Subscription'), __('Registration Code'), __('Node Count'), __('Assigned Machines'), __('Expiring Date') );
    my @SVALUES = ();
    my %SOPTIONS = ( 'headingText' => __('Subscriptions which expiring within the next 30 Days')." ($time)" ); 
    
    foreach my $regcode (keys %{$res})
    {
        if(!exists $calchash->{$res->{$regcode}->{SUBNAME}})
        {
            $calchash->{$res->{$regcode}->{SUBNAME}}->{NODECOUNT} = (int $res->{$regcode}->{NODECOUNT});
            $calchash->{$res->{$regcode}->{SUBNAME}}->{MACHINES} = (exists $res->{$regcode}->{MACHINES})?(int $res->{$regcode}->{MACHINES}):0;
        }
        else
        {
            my $nc = $calchash->{$res->{$regcode}->{SUBNAME}}->{NODECOUNT};
            # nodecount == -1 means unlimited
            if($nc != -1)
            {
                if((int $res->{$regcode}->{NODECOUNT}) == -1)
                {
                    $nc = -1;
                }
                else
                {
                    $nc += (int $res->{$regcode}->{NODECOUNT});
                }
            }

            my $m = $calchash->{$res->{$regcode}->{SUBNAME}}->{MACHINES};
            if(exists $res->{$regcode}->{MACHINES})
            {
                $m += (int $res->{$regcode}->{MACHINES});
            }
            
            $calchash->{$res->{$regcode}->{SUBNAME}}->{NODECOUNT} = $nc;
            $calchash->{$res->{$regcode}->{SUBNAME}}->{MACHINES} = $m;
        }

        push @SVALUES, [ $res->{$regcode}->{SUBNAME},
                         $res->{$regcode}->{REGCODE},
                         ($res->{$regcode}->{NODECOUNT} == -1)?"unlimited":$res->{$regcode}->{NODECOUNT},
                         (exists $res->{$regcode}->{MACHINES})?$res->{$regcode}->{MACHINES}:0,
                         $res->{$regcode}->{SUBENDDATE}
                       ];
    }
    $report{'soon'} = {'cols' => \@SHEAD, 'vals' => \@SVALUES, 'opts' => \%SOPTIONS };


    #
    # expired subscriptions
    #

    $statement  = "select s.SUBNAME, s.REGCODE, COUNT(c.GUID) as MACHINES, s.NODECOUNT, s.SUBSTATUS, s.SUBENDDATE ";
    $statement .= "from Subscriptions s, ClientSubscriptions cs, Clients c ";
    $statement .= "where s.REGCODE = cs.REGCODE and cs.GUID = c.GUID and s.SUBSTATUS = 'EXPIRED' group by REGCODE order by SUBENDDATE;";
    
    printLog($options{log}, "debug", "STATEMENT: $statement") if ($debug);

    $res = $dbh->selectall_hashref($statement, "REGCODE");

    my @EHEAD = ( __('Subscription'), __('Registration Code'), __('Node Count'), __('Assigned Machines'), __('Expiring Date'));
    my @EVALUES = ();
    my %EOPTIONS = ( 'headingText' => __('Expired Subscriptions')." ($time)" );

    foreach my $regcode (keys %{$res})
    {

        if(!exists $calchash->{$res->{$regcode}->{SUBNAME}})
        {
            $calchash->{$res->{$regcode}->{SUBNAME}}->{NODECOUNT} = 0;
            $calchash->{$res->{$regcode}->{SUBNAME}}->{MACHINES} = (exists $res->{$regcode}->{MACHINES})?(int $res->{$regcode}->{MACHINES}):0;
        }
        else
        {
            my $m = $calchash->{$res->{$regcode}->{SUBNAME}}->{MACHINES};
            if(exists $res->{$regcode}->{MACHINES})
            {
                $m += (int $res->{$regcode}->{MACHINES});
            }
            
            $calchash->{$res->{$regcode}->{SUBNAME}}->{MACHINES} = $m;
        }

        push @EVALUES, [ $res->{$regcode}->{SUBNAME},
                         $res->{$regcode}->{REGCODE},
                         ($res->{$regcode}->{NODECOUNT} == -1)?"unlimited":$res->{$regcode}->{NODECOUNT},
                         (exists $res->{$regcode}->{MACHINES})?$res->{$regcode}->{MACHINES}:0,
                         $res->{$regcode}->{SUBENDDATE}
                       ];
    }
    $report{'expire'} = {'cols' => \@EHEAD, 'vals' => \@EVALUES, 'opts' => \%EOPTIONS };


    my $summary .= __("Summary:\n");
    $summary .=    "========\n\n";

    my $ok = 1;
    
    foreach my $sn (keys %{$calchash})
    {
        if($calchash->{$sn}->{NODECOUNT} != -1 && $calchash->{$sn}->{NODECOUNT} < $calchash->{$sn}->{MACHINES})
        {
            $summary .= sprintf(__("Not enough '%s' entitlements. Active entilements: %d  Assigned machines: %d "),
                               $sn,
                               $calchash->{$sn}->{NODECOUNT},
                               $calchash->{$sn}->{MACHINES});
            $ok = 0;
        }
    }

    if($ok)
    {
        $summary .= __("The Subscription status is ok.\n");
    }    

    $report{'summary'} = $summary;

    return \%report;
}


sub certificateExpireCheck
{
    #log => $LOG, debug => $debug);
    my %options = @_;

    my $apacheVhostConf = "/etc/apache2/vhosts.d/vhost-ssl.conf";
    my $certfile = undef;
    
    open(VHOST, "< $apacheVhostConf") or return undef;
    
    while(<VHOST>)
    {
        my $line = $_;
        if($line =~ /^\s*SSLCertificateFile\s+(\S+)/ && defined $1 && -e $1)
        {
            $certfile = $1;
            last;
        }
    }
    close VHOST;
    
    return undef if(! defined $certfile);
    
    my $certData = LIMAL::CaMgm::LocalManagement::getCertificate($certfile, $LIMAL::CaMgm::E_PEM);

    my $endtime = $certData->getEndDate();
    my $currentTime = time();
   
    my $days = int( ($endtime-$currentTime) / ( 60*60*24) );

    printLog($options{log}, "debug", "Check $certfile: Valid for $days days") if($options{debug});
    
    return $days;
}


sub _sha1sum
{
  my $file = shift;

  return undef if(! -e $file);

  open(FILE, "< $file") or do {
        return undef;
  };

  my $sha1 = Digest::SHA1->new;
  eval
  {
      $sha1->addfile(*FILE);
  };
  if($@)
  {
      return undef;
  }
  my $digest = $sha1->hexdigest();
  return $digest;
}


1;

=head1 NAME

 SMT::CLI - SMT common actions for command line programs

=head1 SYNOPSIS

  SMT::listProducts();
  SMT::listCatalogs();
  SMT::setupCustomCatalogs();

=head1 DESCRIPTION

Common actions used in command line utilities that administer the
SMT system.

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

=item setCatalogDoMirror

set the catalog mirror flag to enabled or disabled

Pass id => foo to select the catalog.
Pass enabled => 1 or enabled => 0
disabled => 1 or disabled => 0 are supported as well

=item catalogDoMirrorFlag

Pass id => foo to select the catalog.
true if the catalog is ser to be mirrored, false otherwise

=back

=back

=head1 AUTHOR

dmacvicar@suse.de

=head1 COPYRIGHT

Copyright 2007, 2008 SUSE LINUX Products GmbH, Nuernberg, Germany.

=cut


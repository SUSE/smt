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
use Data::Dumper;

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
    my $dbh = undef;
    my $cfg = undef;

    $cfg = SMT::Utils::getSMTConfig();
    
    if ( not $dbh=SMT::Utils::db_connect($cfg) )
    {
        die __("ERROR: Could not connect to the database");
    }
    
    return ($cfg, $dbh);
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
#   $data = {
#     'cols' => [ "first", "second",    ...  ],
#     'vals' => [ [a1,a2], [b1,b2],     ...  ],
#     'opts' => {'optname' => 'optval', ...  },
#     'heading' => "header string"
#   };
#
#   or
#
#   $data = {
#     'cols' => [ {name => "first", align => "left"}, {name => "second", align => "auto"},  ...  ],
#     'vals' => [ [a1,a2], [b1,b2],     ...  ],
#     'opts' => {'optname' => 'optval', ...  },
#     'heading' => "header string"
#   };
#   $mode = 'asciitable';
#   $mode = 'csv';
#   $mode = 'html';
#
sub renderReport($$$)
{
    my $d     = shift; 
    my $mode  = shift;
    my $repid = shift;
    my $res = '';
    my $headingFmt = '';

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
                # do not set headingText in ASCIITable, it makes rendering veeeeeery slow  (bnc#396702)
                if ($key ne 'headingText')
                {
                    $t->setOptions($key,$val);
                }
            }
        }

        # setting heading in ASCIITable is deactivated because of (bnc#396702)
        ##if (defined $heading)
        ##{
        ##     $t->setOptions('headingText', $heading);
        ##}

        if(ref($data{'cols'}->[0]) ne "HASH")
        {
            $t->setCols(@{$data{'cols'}});
        }
        else
        {
            my @cols = ();
            foreach my $col (@{$data{'cols'}})
            {
                push @cols, $col->{name};
            }

            $t->setCols(@cols);
            foreach my $col (@{$data{'cols'}})
            {
                $t->alignCol($col->{name}, $col->{align});
            }
        }


        # addRow may fail with long lists, so do it one by one
        foreach my $row (@{$data{'vals'}})
        {
            $t->addRow($row);
        }

        # draw the table now, because we need to work with it
        $res = $t->draw();
        
        # manually add the heading (bnc#396702)
        if (defined $heading)
        {
            my $hstrlen = length($heading);
            if ($hstrlen > 0 )
            {
                my $hoff = 0;
                my $tlen = length(substr($res, 0, index($res, "\n")));
                $hoff = int(($tlen - $hstrlen)/2);
                if ($hoff < 0 ) { $hoff = 0 }
                
                $headingFmt = "\n " . ' ' x $hoff . $heading . "\n";
                
                $res = $headingFmt.$res;
            }
        }
    }
    elsif ($mode eq 'csv') 
    {
        my @valbody  = [];

        # no header in csv file - first row must be cols

        # add title/cols row
        if(ref($data{'cols'}->[0]) ne "HASH")
        {
            $res .= escapeCSVRow(\@{$data{'cols'}});
            $res .= "\n";
        }
        else
        {
            my @cols = ();
            foreach my $col (@{$data{'cols'}})
            {
                push @cols, $col->{name};
            }
            $res .= escapeCSVRow(\@cols);
            $res .= "\n";
        }
        
        foreach my $valrow (@{$data{'vals'}})
        {
            $res .= escapeCSVRow(\@{$valrow});
            $res .= "\n";
        }
    }
    elsif ($mode eq 'html')
    {
        if(defined $heading && $heading ne "")
        {
            $res .= "<h2>$heading</h2>";
        }
        $res .= '<table border="1"><tr>';
        
        if(ref($data{'cols'}->[0]) ne "HASH")
        {
            foreach my $val (@{$data{'cols'}})
            {
                $res .= "<th>$val</th>";
            }
        }
        else
        {
            foreach my $col (@{$data{'cols'}})
            {
                $res .= "<th>".$col->{name}."</th>";
            }
        }
        $res .= "</tr><tr>";

        foreach my $row (@{$data{'vals'}})
        {
            foreach my $value (@{$row})
            {
                $value = '' if (! defined $value);
                $value =~ s/\n/<br>/g;
                $res .= "<td>$value</td>";
            }
            $res .= "</tr><tr>";
        }
        $res .= "</tr></table>";
    }
    elsif ($mode eq 'xml')
    {
        my $writer = new XML::Writer(OUTPUT => \$res);
        my $haveID = 0;
        my %tattr = (title => "$heading", id => "$repid");
        
        if($heading =~ /\((.+)\)/ && defined $1 && $1 ne "")
        {
            $tattr{date} = $1;
        }
        
        $writer->startTag("table", %tattr);
        my @cols = ();
        
        if(ref($data{'cols'}->[0]) ne "HASH")
        {
            foreach my $val (@{$data{'cols'}})
            {
                my $name = $val;
                $name =~ s/\n/ /g;
                push @cols, "$name";
            }
        }
        else
        {
            $haveID = 1 if( exists $data{'cols'}->[0]->{id} );
            
            foreach my $col (@{$data{'cols'}})
            {
                my $name = "";
                if( $haveID )
                {
                    $name = $col->{id};
                }
                else
                {
                    $name = $col->{name};
                }
                
                $name =~ s/\n/ /g;
                push @cols, $name;
            }
        }

        foreach my $row (@{$data{'vals'}})
        {
            $writer->startTag("row");
            for(my $i = 0; $i < @cols; $i++)
            {
                my $value = '';
                if (defined $row->[$i])
                {
                    $value = $row->[$i];
                }
                foreach my $sv (split(/\n/, $value))
                {
                    my %attr = ();
                    if( $haveID )
                    {
                        $attr{id} = $cols[$i];
                    }
                    else
                    {
                        $attr{name} = $cols[$i];
                    }
                    if($sv eq "never")
                    {
                        $writer->emptyTag("col", %attr);
                    }
                    else
                    {
                        $writer->startTag("col", %attr);
                        $sv = -1 if($sv eq "unlimited");
                        $writer->characters($sv);
                        $writer->endTag("col");
                    }
                }
            }
            $writer->endTag("row");
        }
        $writer->endTag("table");
    }
    elsif ($mode eq 'docbook')
    {
        my $writer = new XML::Writer(OUTPUT => \$res);
        
        $writer->startTag("section");
        $writer->startTag("title");
        $writer->characters($heading);
        $writer->endTag("title");
        $writer->startTag("table", frame => "all");
        $writer->startTag("title");
        $writer->characters($heading);
        $writer->endTag("title");
        my @cols = ();
        
        if(ref($data{'cols'}->[0]) ne "HASH")
        {
            foreach my $val (@{$data{'cols'}})
            {
                my $name = $val;
                $name =~ s/\n/ /g;
                push @cols, "$name";
            }
        }
        else
        {
            foreach my $col (@{$data{'cols'}})
            {
                my $name = "";
                $name = $col->{name};
                $name =~ s/\n/ /g;
                push @cols, $name;
            }
        }
        $writer->startTag("tgroup", cols => ($#cols+1), align => "center");
        $writer->startTag("thead");
        $writer->startTag("row");
        foreach my $entry (@cols)
        {
            $writer->startTag("entry");
            $writer->characters($entry);
            $writer->endTag("entry");
        }
        $writer->endTag("row");
        $writer->endTag("thead");
        $writer->startTag("tbody");
        
        foreach my $row (@{$data{'vals'}})
        {
            $writer->startTag("row");
            for(my $i = 0; $i < @cols; $i++)
            {
                my $value = '';
                if (defined $row->[$i])
                {
                    $value = $row->[$i];
                }
                
                $writer->startTag("entry");
                $writer->characters($value);
                $writer->endTag("entry");
            }
            $writer->endTag("row");
        }
        $writer->endTag("tbody");
        $writer->endTag("tgroup");
        $writer->endTag("table");
        $writer->endTag("section");
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

    my ($cfg, $dbh) = init();
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
    print renderReport(getCatalogs(@_), 'asciitable', '');
}


sub getProducts
{
    my %options = @_;
    my ($cfg, $dbh) = init();

    my $sql = "select p.*,0+(select count(r.GUID) from Products p2, Registration r where r.PRODUCTID=p2.PRODUCTDATAID and p2.PRODUCTDATAID=p.PRODUCTDATAID) AS registered_machines from Products p where 1 order by PRODUCT,VERSION,REL,ARCH";

    my $sth = $dbh->prepare($sql);
    $sth->execute();


    my @HEAD = ( __('ID'), __('Name'), __('Version'), __('Architecture'), __('Release'), __('Usage') );
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
            
            
            push @VALUES, [ $value->{PRODUCTDATAID}, 
                            $value->{PRODUCT}, 
                            $value->{VERSION} || "-", 
                            $value->{ARCH}    || "-", 
                            $value->{REL}     || "-", 
                            $value->{registered_machines}, 
                            $cm ];
        }
        else
        {
            push @VALUES, [ $value->{PRODUCTDATAID}, 
                            $value->{PRODUCT}, 
                            $value->{VERSION} || "-", 
                            $value->{ARCH}    || "-", 
                            $value->{REL}     || "-", 
                            $value->{registered_machines} ];
        }
    }
   
    $sth->finish();
    return {'cols' => \@HEAD, 'vals' => \@VALUES };
}


#
# wrapper function to keep compatibility while changing the called function
#
sub listProducts
{
    print renderReport(getProducts(@_), 'asciitable', '');
}


sub getRegistrations
{
    my ($cfg, $dbh) = init();

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
    my %options = @_;
    
    if(exists $options{verbose} && defined $options{verbose} && $options{verbose})
    {
        my ($cfg, $dbh) = init();

        my $clients = $dbh->selectall_arrayref("SELECT GUID, HOSTNAME, LASTCONTACT from Clients ORDER BY LASTCONTACT", {Slice => {}});

        foreach my $clnt (@{$clients})
        {
            my $products = $dbh->selectall_arrayref(sprintf("SELECT p.PRODUCT, p.VERSION, p.REL, p.ARCH, r.REGDATE, r.NCCREGDATE, r.NCCREGERROR from Products p, Registration r WHERE r.GUID=%s and r.PRODUCTID=p.PRODUCTDATAID", 
                                                            $dbh->quote($clnt->{GUID})), {Slice => {}});
        
            print __('Unique ID')." : $clnt->{GUID}\n";
            print __('Hostname')." : $clnt->{HOSTNAME}\n";
            print __('Last Contact')." : $clnt->{LASTCONTACT}\n";

            my $prdstr = "";
            foreach my $product (@{$products})
            {
                $prdstr .= $product->{PRODUCT} if(defined $product->{PRODUCT});
                $prdstr .= " ".$product->{VERSION} if(defined $product->{VERSION});
                $prdstr .= " ".$product->{REL} if(defined $product->{REL});
                $prdstr .= " ".$product->{ARCH} if(defined $product->{ARCH});

                print __('Product')." : $prdstr\n" if($prdstr ne "");
                $prdstr = "";


                print "        ".__('Local Registration Date')." : $product->{REGDATE}\n";
                print "        ".__('NCC Registration Date')." : ".((defined $product->{NCCREGDATE})?$product->{NCCREGDATE}:"")."\n";
                if (defined $product->{NCCREGERROR} && $product->{NCCREGERROR})
                {
                    print "        ".__('NCC Registration Errors')." : YES\n";
                }
            }
            
            my $subscr = $dbh->selectall_arrayref(sprintf("select s.SUBNAME , s.REGCODE, s.SUBSTATUS, s.SUBENDDATE, s.NODECOUNT, s.CONSUMED, s.SERVERCLASS  from ClientSubscriptions cs, Subscriptions s where cs.GUID = %s and cs.SUBID = s.SUBID order by SERVERCLASS DESC;", 
                                                          $dbh->quote($clnt->{GUID})), {Slice => {}});
            
            foreach my $sub (@{$subscr})
            {
                print  __("Subscription")." : ".$sub->{SUBNAME}."\n";
                print  "        ".__("Activation Code")." : ".$sub->{REGCODE}."\n";
                print  "        ".__("Status")." : ".$sub->{SUBSTATUS}."\n";
                print  "        ".__("Expiration Date")." : ".((defined $sub->{SUBENDDATE})?"$sub->{SUBENDDATE}":"")."\n";
                print  "        ".__("Purchase Count/Used")." : ".$sub->{NODECOUNT}."/".$sub->{CONSUMED}."\n";
            }
            print "-----------------------------------------------------------------------\n";
        }
    }
    else
    {
        print renderReport(getRegistrations(), 'asciitable', '');
    }
}


sub setCatalogsByProduct
{
    my %opts = @_;
    
    my ($cfg, $dbh) = init();
    my $enable = 0;
    
    #( verbose => $verbose, prodStr => $enableByProduct, enable => [1,0])
    
    if(! exists $opts{prodStr} || ! defined $opts{prodStr} || $opts{prodStr} eq "")
    {
        print __("Invalid product string.\n");
        return 1;
    }
    if(exists $opts{enable} && defined $opts{enable})
    {
        $enable = $opts{enable};
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

    my $arr = $dbh->selectall_arrayref($st1, {Slice => {}});
    if(@{$arr} == 0)
    {
        print sprintf(__("Error: Product (%s) not found.\n"),$opts{prodStr});
        return 1;
    }
        
    my $statement = "select distinct pc.CATALOGID, c.NAME, c.TARGET, c.MIRRORABLE, c.DOMIRROR from ProductCatalogs pc, Catalogs c where PRODUCTDATAID IN ($st1) and pc.CATALOGID = c.CATALOGID order by NAME,TARGET;";
    
    #print "$statement \n";

    $arr = $dbh->selectall_arrayref($statement, {Slice => {}});
    
    foreach my $row (@{$arr})
    {
        next if($enable && uc($row->{DOMIRROR}) eq "Y");
        next if(!$enable && uc($row->{DOMIRROR}) eq "N");
        
        if($enable && uc($row->{MIRRORABLE}) ne "Y")
        {
            print sprintf(__("Catalog [%s %s] cannot be enabled. Access on the server denied.\n"), 
                          $row->{NAME}, 
                          ($row->{TARGET}) ? $row->{TARGET} : "");
        }
        else
        {
            SMT::CLI::setCatalogDoMirror(enabled => $enable, name => $row->{NAME}, target => $row->{TARGET});
            print sprintf(__("Catalog [%s %s] %s.\n"),
                          $row->{NAME}, 
                          ($row->{TARGET}) ? $row->{TARGET} : "",
                          ($enable?__("enabled"):__("disabled")));
        }
    }
    return 0;
}

sub resetCatalogsStatus
{
  my ($cfg, $dbh) = init();

  my $sth = $dbh->prepare(qq{UPDATE Catalogs SET Mirrorable='N' WHERE CATALOGTYPE='nu'});
  $sth->execute();
}

sub setCatalogDoMirror
{
    my %opt = @_;
    my ($cfg, $dbh) = init();
    
    if(exists $opt{enabled} && defined $opt{enabled} )
    {
        my $sql = "update Catalogs";
        $sql .= sprintf(" set Domirror=%s", $dbh->quote(  $opt{enabled} ? "Y" : "N" ) ); 
        
        $sql .= " where 1";
        
        $sql .= sprintf(" and Mirrorable=%s", $dbh->quote("Y"));
        
        if(exists $opt{name} && defined $opt{name} && $opt{name} ne "")
        {
            $sql .= sprintf(" and NAME=%s", $dbh->quote($opt{name}));
        }
        
        if(exists $opt{target} && defined $opt{target} && $opt{target} ne "")
        {
            $sql .= sprintf(" and TARGET=%s", $dbh->quote($opt{target}));
        }
        
        if(exists $opt{id} && defined $opt{id} )
        {
            $sql .= sprintf(" and CATALOGID=%s", $dbh->quote($opt{id}));
        }
        
        #print $sql . "\n";
        my $rows = $dbh->do($sql);
        $rows = 0 if(!defined $rows || $rows < 0);
        return $rows;
    }
    else
    {
        die __("enabled option missing");
    }
    return 0;
}

sub setCatalogStaging
{
    my %opt = @_;
    my ($cfg, $dbh) = init();
    
    if(exists $opt{enabled} && defined $opt{enabled} )
    {
        my $sql = "update Catalogs";
        $sql .= sprintf(" set Staging=%s", $dbh->quote(  $opt{enabled} ? "Y" : "N" ) ); 
        
        $sql .= " where 1";
        
        $sql .= sprintf(" and Mirrorable=%s", $dbh->quote("Y"));
        
        if(exists $opt{name} && defined $opt{name} && $opt{name} ne "")
        {
            $sql .= sprintf(" and NAME=%s", $dbh->quote($opt{name}));
        }
        
        if(exists $opt{target} && defined $opt{target} && $opt{target} ne "")
        {
            $sql .= sprintf(" and TARGET=%s", $dbh->quote($opt{target}));
        }
        
        if(exists $opt{id} && defined $opt{id} )
        {
            $sql .= sprintf(" and CATALOGID=%s", $dbh->quote($opt{id}));
        }
        
        #print $sql . "\n";
        my $rows = $dbh->do($sql);
        $rows = 0 if(!defined $rows || $rows < 0);
        return $rows;
    }
    else
    {
        die __("enabled option missing");
    }
    return 0;
}

sub catalogDoMirrorFlag
{
  my %options = @_;
  my ($cfg, $dbh) = init();
  return 1;
}

sub setMirrorableCatalogs
{
    my %opt = @_;
    my ($cfg, $dbh) = ();
    my $nuri = undef;
    
    if(defined $opt{todir} && $opt{todir} ne "")
    {
        $cfg = SMT::Utils::getSMTConfig();
        
        my $NUUrl = $cfg->val("NU", "NUUrl");
        if(!defined $NUUrl || $NUUrl eq "")
        {
            die __("Cannot read NU Url");
        }
        $nuri = URI->new($NUUrl);
    }
    else
    {
        ($cfg, $dbh) = init();
        #
        # TODO: what, if we have more then one NU server?
        my $array = $dbh->selectall_arrayref("select distinct EXTHOST from Catalogs where CATALOGTYPE = 'nu'", {Slice =>{}});
        if(exists $array->[0] && exists $array->[0]->{EXTHOST} && 
           defined $array->[0]->{EXTHOST} && $array->[0]->{EXTHOST} =~ /^http/)
        {
            $nuri = URI->new( $array->[0]->{EXTHOST} );
        }
        else
        {
            # should not happen...
            my $NUUrl = $cfg->val("NU", "NUUrl");
            if(!defined $NUUrl || $NUUrl eq "")
            {
                die __("Cannot read NU Url");
            }
            $nuri = URI->new($NUUrl);
        }
    }
    my $nuUser = $cfg->val("NU", "NUUser");
    my $nuPass = $cfg->val("NU", "NUPass");

    if(!defined $nuUser || $nuUser eq "" ||
      !defined $nuPass || $nuPass eq "")
    {
        die __("Cannot read the Mirror Credentials");
    }
    $nuri->userinfo("$nuUser:$nuPass");


    # create a tmpdir to store repoindex.xml
    my $destdir = File::Temp::tempdir("smt-XXXXXXXX", CLEANUP => 1, TMPDIR => 1);
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
        my $job = SMT::Mirror::Job->new(vblevel => $opt{vblevel}, log => $opt{log});
        $job->uri($nuri);
        $job->localBasePath( "/" );
        $job->localRepoPath( $destdir );
        $job->localFileLocation("/repo/repoindex.xml");
        
        $job->mirror();
        $indexfile = $job->fullLocalPath();
    }

    if(exists $opt{todir} && defined $opt{todir} && -d $opt{todir})
    {
        # with todir we only want to mirror repoindex to todir
        return;
    }

    my $parser = SMT::Parser::NU->new(vblevel => $opt{vblevel}, log => $opt{log});
    $parser->parse($indexfile, 
                   sub {
                       my $repodata = shift;
                       printLog($opt{log}, $opt{vblevel}, LOG_DEBUG, 
                                sprintf(__("* set [%s %s] as mirrorable."), $repodata->{NAME}, $repodata->{DISTRO_TARGET}));
                       my $sth = $dbh->do( sprintf("UPDATE Catalogs SET Mirrorable='Y' WHERE NAME=%s AND TARGET=%s", 
                                                   $dbh->quote($repodata->{NAME}), $dbh->quote($repodata->{DISTRO_TARGET}) ));
                   }
    );

    my $useragent = SMT::Utils::createUserAgent(keep_alive => 1);
    my $sql = "select CATALOGID, NAME, LOCALPATH, EXTURL, TARGET from Catalogs where CATALOGTYPE='zypp'";
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
                # on nu.novell.com we need to authenticate, so put the
                # userinfo into this url
                my $url = URI->new($catUrl);
                if($url->host eq "nu.novell.com")
                {
                    my $uuri = URL->new($nuri);
                    my $userinfo = $uuri->userinfo;
                    $url->userinfo($userinfo);
                }

    	        my $tempdir = File::Temp::tempdir("smt-XXXXXXXX", CLEANUP => 1, TMPDIR => 1);
                my $remote = $url->as_string()."/repodata/repomd.xml";
                my $local = $tempdir."/repodata/repomd.xml";
                # make sure the container destination exists
                &File::Path::mkpath( dirname($local) );
                
                my $redirects = 0;
                my $response;
                
                do
                {
                    eval
                    {
                        $response = $useragent->get( $remote, ':content_file' => $local );
                    };
                    if($@)
                    {
                        printLog($opt{log}, $opt{vblevel}, LOG_DEBUG, $@);
                        $ret = 1;
                        last;
                    }
                    
                    if ( $response->is_redirect )
                    {
                        $redirects++;
                        if($redirects > 2)
                        {
                            $ret = 1;
                            last
                        }
                        
                        my $newuri = $response->header("location");
                        
                        #printLog($opt{log}, $opt{vblevel}, LOG_DEBUG, "Redirected to $newuri");
                        $remote = URI->new($newuri);
                    }
                    elsif($response->is_success)
                    {
                        $ret = 0;
                    }
                } while($response->is_redirect);
            }
            printLog($opt{log}, $opt{vblevel}, LOG_DEBUG, sprintf(__("* set [%s] as%s mirrorable."), $catName, ( ($ret == 0) ? '' : ' not' )));
            my $statement = sprintf("UPDATE Catalogs SET Mirrorable=%s WHERE NAME=%s ",
                                    ( ($ret == 0) ? $dbh->quote('Y') : $dbh->quote('N') ), 
                                    $dbh->quote($catName)); 
            if(defined $catTarget && $catTarget ne "")
            {
                $statement .= sprintf("AND TARGET=%s", $dbh->quote($catTarget) );
            }        
            
            my $sth = $dbh->do( $statement );
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
    my ($cfg, $dbh) = init();

    # delete existing catalogs with this id

    my $affected1 = $dbh->do(sprintf("DELETE from Catalogs where CATALOGID=%s", $dbh->quote($options{catalogid})));
    my $affected2 = $dbh->do(sprintf("DELETE from ProductCatalogs where CATALOGID=%s", $dbh->quote($options{catalogid})));

    $affected1=0 if($affected1 != 1);

    return $affected1;
}

sub setupCustomCatalogs
{
    my %options = @_;
    my ($cfg, $dbh) = init();

    # delete existing catalogs with this id
    
    removeCustomCatalog(%options);
    
    # now insert it again.
    my $exthost = $options{exturl};
    $exthost =~ /^(https?:\/\/[^\/]+\/)/;
    $exthost = $1;

    my $affected = $dbh->do(sprintf("INSERT INTO Catalogs (CATALOGID, NAME, DESCRIPTION, TARGET, LOCALPATH, EXTHOST, EXTURL, CATALOGTYPE, DOMIRROR,MIRRORABLE,SRC ) VALUES(%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, 'C')",
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
        $affected += $dbh->do(sprintf("INSERT INTO ProductCatalogs (PRODUCTDATAID, CATALOGID, OPTIONAL, SRC)VALUES(%s, %s, %s, 'C')",
                                      $pid,
                                      $dbh->quote($options{catalogid}),
                                      $dbh->quote("N")));
    }
    
    return (($affected>0)?1:0);
}

sub createDBReplacementFile
{
    my $xmlfile = shift;
    my ($cfg, $dbh) = init();

    if(!defined $xmlfile || $xmlfile eq "")
    {
        die "No filename given.";
    }
    
    my $dbout = $dbh->selectall_arrayref("SELECT CATALOGID, NAME, DESCRIPTION, TARGET, EXTURL, LOCALPATH, CATALOGTYPE, STAGING from Catalogs where DOMIRROR = 'Y' order by CATALOGTYPE, NAME", 
                                        { Slice => {} });

    my $output = new IO::File("> $xmlfile");
    if(!defined $output)
    {
        die "Cannot open file '$xmlfile':$!";
    }
    
    my $writer = new XML::Writer(OUTPUT => $output);

    $writer->xmlDecl("UTF-8");
    $writer->startTag("catalogs", xmlns => "http://www.novell.com/xml/center/regsvc-1_0");

    foreach my $row (@{$dbout})
    {
        $writer->startTag("row");
        foreach my $col (keys %{$row})
        {
            $writer->startTag("col", name => $col);
            $writer->characters($row->{$col});
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
    my ($cfg, $dbh) = init();
    my $t0 = [gettimeofday] ;

    my $vblevel = 0;
    if(exists $options{debug} && defined $options{debug})
    {
        $vblevel = $options{vblevel};
    }
    
    my $dir = "";
    if(! exists $options{basepath} || ! defined $options{basepath} || ! -d $options{basepath})
    {
        $dir = $cfg->val("LOCAL", "MirrorTo");
        if(!defined $dir || $dir eq "" || ! -d $dir)
        {
            printLog($options{log}, $vblevel, LOG_ERROR, sprintf("Wrong mirror directory: %s", $dir));
            return 1;
        }
    }
    else
    {
        $dir = $options{basepath};
    }
    
    my $cmd = "find $dir -xdev -iname '*.rpm' -type f -size +$options{size}k ";
    printLog($options{log}, $vblevel, LOG_DEBUG, "$cmd");
    
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
                printLog($options{log}, $vblevel, LOG_INFO1, "$MM ");
                printLog($options{log}, $vblevel, LOG_INFO1, "$NN ");
                if( (stat($MM))[1] != (stat($NN))[1] )
                {
                    my $sha1MM = _sha1sum($MM);
                    my $sha1NN = _sha1sum($NN);
                    if(defined $sha1MM && defined $sha1NN && $sha1MM eq $sha1NN)
                    {
                        printLog($options{log}, $vblevel, LOG_INFO2, "Hardlink $NN");
                        #my $ret = link $MM, $NN;
                        #print "RET: $ret\n";
                        link( $MM, $NN );
                        $NN = undef;
                    }
                    else
                    {
                        printLog($options{log}, $vblevel, LOG_DEBUG, "Checksums does not match $sha1MM != $sha1NN.");
                    }
                }
                else
                {
                    printLog($options{log}, $vblevel, LOG_DEBUG, "Files are hard linked. Nothing to do.");
                    $NN = undef;
                }
            }
            elsif($NN eq $MM)
            {
                $NN = undef;
            }
        }
    }
    printLog($options{log}, $vblevel, LOG_INFO1, sprintf(__("Hardlink Time      : %s"), SMT::Utils::timeFormat(tv_interval($t0))));
}

sub productClassReport
{
    my %options = @_;
    my ($cfg, $dbh) = init();
    my %conf;
    
    my $vblevel = 0;
    if(exists $options{vblevel} && defined $options{vblevel})
    {
        $vblevel = $options{vblevel};
    }    
    
    if(exists $options{conf} && defined $options{conf} && ref($options{conf}) eq "HASH")
    {
        %conf = %{$options{conf}};
    }
    else
    {
        printLog($options{log}, $vblevel, LOG_ERROR, "Invalid configuration provided.");
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
            
            printLog($options{log}, $vblevel, LOG_DEBUG, "STATEMENT: $statement");
            
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
            
            printLog($options{log}, $vblevel, LOG_DEBUG, "STATEMENT: $statement");
            
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

#
# based on a local calculation
#
sub productSubscriptionReport
{
    my %options = @_;
    my ($cfg, $dbh) = init();
    my %report = ();
    
    my $vblevel = 0;
    if(exists $options{vblevel} && defined $options{vblevel})
    {
        $vblevel = $options{vblevel};
    }
    
    my $statement = "";
    my $time = SMT::Utils::getDBTimestamp();
    my $calchash = {};
    my $expireSoonMachines = {};
    my $expiredMachines = {};
    my $nowP30day = SMT::Utils::getDBTimestamp((time + (30*24*60*60)));
    my $now = SMT::Utils::getDBTimestamp();
    my $sth = undef;
    my $subnamesByProductClass = {};
    
    $statement = "select distinct PRODUCT_CLASS, SUBNAME from Subscriptions;";

    printLog($options{log}, $vblevel, LOG_DEBUG, "STATEMENT: $statement");

    my $res = $dbh->selectall_arrayref($statement, {Slice=>{}});
    
    foreach my $node (@{$res})
    {
        my $subname = $node->{SUBNAME};
        my $product_class = $node->{PRODUCT_CLASS};
        
        if(exists $subnamesByProductClass->{$product_class} && defined $subnamesByProductClass->{$product_class})
        {
            $subnamesByProductClass->{$product_class} .= "\n".$subname;
        }
        else
        {
            $subnamesByProductClass->{$product_class} = "$subname";
        }

        $calchash->{$product_class}->{MACHINES}       = 0;
        $calchash->{$product_class}->{MACHINESVIRT}   = 0;
        $calchash->{$product_class}->{TOTMACHINES}    = 0;
        $calchash->{$product_class}->{TOTMACHINESVIRT}= 0;
        $calchash->{$product_class}->{SUM_ACTIVE_SUB} = 0;
        $calchash->{$product_class}->{SUM_ESOON_SUB}  = 0;
    }
    
    $statement = "SELECT PRODUCT_CLASS, r.GUID from Products p, Registration r where r.PRODUCTID=p.PRODUCTDATAID";

    printLog($options{log}, $vblevel, LOG_DEBUG, "STATEMENT: $statement");

    $res = $dbh->selectall_arrayref($statement, {Slice => {}});
    my $dhash = {};

    #
    # You need one subscription for every physical machine per product_class.
    # So we need to filter out virtual machines which running on the same hardware 
    # We should not count them multiple times.
    #
    foreach my $set (@{$res})
    {
        my $key = $set->{PRODUCT_CLASS}." ".$set->{GUID};
        
        #
        # we have this combination already => skip it.
        #
        next if(exists $dhash->{$key});
        
        $statement = sprintf("select VALUE from MachineData where GUID='%s' and KEYNAME='host';", $set->{GUID});
        my $arr = $dbh->selectcol_arrayref($statement);
        
        if( exists $arr->[0] && defined $arr->[0] && $arr->[0] ne "")
        {
            #
            # this is a VM, count it
            #
            $calchash->{$set->{PRODUCT_CLASS}}->{MACHINESVIRT} += 1;
            $calchash->{$set->{PRODUCT_CLASS}}->{TOTMACHINESVIRT} += 1;

            #
            # currently we do not count subscriptions for VMs
            #
            next;
            
            #my $newkey =  $set->{PRODUCT_CLASS}." ".$arr->[0];
            #if(exists $dhash->{$newkey})
            #{
                #
                # This is a virtual machine and this PRODUCT_CLASS/ID combination
                # has already a subscription. Skip the rest.
                #
            #    next;
            #}
            
            #
            # this is a VM which do not have a subscription. So use the PRODUCT_CLASS/hostGUID as key
            # and add it to the dhash.
            #
            #$key = $newkey;
        }
        $dhash->{$key} = $set;
        
        #
        # count the machines which need a subscription
        #
        $calchash->{$set->{PRODUCT_CLASS}}->{MACHINES}    += 1;
        $calchash->{$set->{PRODUCT_CLASS}}->{TOTMACHINES} += 1;
    }
    
    #
    # Active Subscriptions
    #
    
    $statement  = "select PRODUCT_CLASS, SUM(NODECOUNT) as SUM_NODECOUNT, MIN(NODECOUNT) = -1 as UNLIMITED, MIN(SUBENDDATE) as MINENDDATE ";
    $statement .= "from Subscriptions where SUBSTATUS = 'ACTIVE' and (SUBENDDATE > ? or SUBENDDATE IS NULL) ";
    $statement .= "group by PRODUCT_CLASS order by PRODUCT_CLASS;";
    $sth = $dbh->prepare($statement);
    $sth->bind_param(1, $nowP30day, SQL_TIMESTAMP);
    $sth->execute;
    $res = $sth->fetchall_hashref("PRODUCT_CLASS");

    printLog($options{log}, $vblevel, LOG_DEBUG, "STATEMENT: ".$sth->{Statement});
    
    my @AHEAD = ( {
                   name  => __("Subscriptions"),
                   align => "auto",
                   id    => "sub"
                  },
                  {
                   name  => __("Total\nPurchase Count"),
                   align => "right",
                   id    => "number"
                  },
                  {
                   name  => __("Used\nLocally"),
                   align => "auto",
                   id    => "localused"
                  },
                  {
                   name  => __("Used Locally\n(Virtual)"),
                   align => "auto",
                   id    => "localusedvirt"
                  },
                  {
                   name  => __("Subscription\nExpires"),
                   align => "auto",
                   id    => "expires"
                  });
    my @AVALUES = ();
    my %AOPTIONS = ( 'headingText' => __("Active Subscriptions"." ($time)" ), drawRowLine => 1 );

    foreach my $product_class (keys %{$res})
    {
        my $assignedMachines = 0;
        my $assignedMachinesVirt = 0;
        my $nc =  (int $res->{$product_class}->{SUM_NODECOUNT});
        
        if($res->{$product_class}->{UNLIMITED})
        {
            $calchash->{$product_class}->{SUM_ACTIVE_SUB} = -1;
            $assignedMachines = $calchash->{$product_class}->{MACHINES};
            $calchash->{$product_class}->{MACHINES} = 0;
            $nc = "unlimited";
        }
        else
        {
            $calchash->{$product_class}->{SUM_ACTIVE_SUB} += $nc if($calchash->{$product_class}->{SUM_ACTIVE_SUB} != -1);

            if($nc >= (int $calchash->{$product_class}->{MACHINES}))
            {
                $assignedMachines = $calchash->{$product_class}->{MACHINES};
                $calchash->{$product_class}->{MACHINES} = 0;
            }
            else
            {
                $assignedMachines = $nc;
                $calchash->{$product_class}->{MACHINES} -= $nc;                
            }
        }
        
        # virtual machines are not really counted. If we have virtual machines
        # for this product_class assign them all to this subscription

        if( $calchash->{$product_class}->{MACHINESVIRT} > 0 )
        {
            $assignedMachinesVirt = $calchash->{$product_class}->{MACHINESVIRT};
            $calchash->{$product_class}->{MACHINESVIRT} = 0;
        }
        
        push @AVALUES, [ $subnamesByProductClass->{$product_class},
                         $nc,
                         $assignedMachines,
                         $assignedMachinesVirt,
                         (defined $res->{$product_class}->{MINENDDATE})?$res->{$product_class}->{MINENDDATE}:"never"
                       ];
    }
    $report{'active'} = {'cols' => \@AHEAD, 'vals' => \@AVALUES, 'opts' => \%AOPTIONS };

    #
    # Expire soon
    #
    
    $statement  = "select PRODUCT_CLASS, SUBSTATUS, SUM(NODECOUNT) as SUM_NODECOUNT, MIN(NODECOUNT) = -1 as UNLIMITED, MIN(SUBENDDATE) as MINENDDATE ";
    $statement .= "from Subscriptions where SUBSTATUS = 'ACTIVE' and SUBENDDATE <= ? and SUBENDDATE > ?";
    $statement .= "group by PRODUCT_CLASS order by PRODUCT_CLASS;";
    $sth = $dbh->prepare($statement);
    $sth->bind_param(1, $nowP30day, SQL_TIMESTAMP);
    $sth->bind_param(2, $now, SQL_TIMESTAMP);
    $sth->execute;
    $res = $sth->fetchall_hashref("PRODUCT_CLASS");

    printLog($options{log}, $vblevel, LOG_DEBUG, "STATEMENT: ".$sth->{Statement});
    
    my @SHEAD = ( {
                   name  => __("Subscriptions"),
                   align => "auto",
                   id    => "sub"
                  },
                  {
                   name  => __("Total\nPurchase Count"),
                   align => "right",
                   id    => "number"
                  },
                  {
                   name  => __("Used\nLocally"),
                   align => "auto",
                   id    => "localused"
                  },
                  {
                   name  => __("Used Locally\n(Virtual)"),
                   align => "auto",
                   id    => "localusedvirt"
                  },
                  {
                   name  => __("Subscription\nExpires"),
                   align => "auto",
                   id    => "expires"
                  });
    my @SVALUES = ();
    my %SOPTIONS = ( 'headingText' => __("Subscriptions which expired within the next 30 days")." ($time)", drawRowLine => 1 );

    foreach my $product_class (keys %{$res})
    {
        my $assignedMachines = 0;
        my $assignedMachinesVirt = 0;
        my $nc = (int $res->{$product_class}->{SUM_NODECOUNT});
        
        if($res->{$product_class}->{UNLIMITED})
        {
            $calchash->{$product_class}->{SUM_ESOON_SUB} = -1;
            $assignedMachines = $calchash->{$product_class}->{MACHINES};
            $calchash->{$product_class}->{MACHINES} = 0;
            $nc = "unlimited";
        }
        else
        {
            $calchash->{$product_class}->{SUM_ESOON_SUB} += $nc if($calchash->{$product_class}->{SUM_ESOON_SUB} != -1);

            if($nc >= (int $calchash->{$product_class}->{MACHINES}))
            {
                $assignedMachines = $calchash->{$product_class}->{MACHINES};
                $calchash->{$product_class}->{MACHINES} = 0;
            }
            else
            {
                $assignedMachines = $nc;
                $calchash->{$product_class}->{MACHINES} -= $nc;                
            }
        }

        # virtual machines are not really counted. If we have virtual machines
        # for this product_class assign them all to this subscription

        if( $calchash->{$product_class}->{MACHINESVIRT} > 0 )
        {
            $assignedMachinesVirt = $calchash->{$product_class}->{MACHINESVIRT};
            $calchash->{$product_class}->{MACHINESVIRT} = 0;
        }

        push @SVALUES, [ $subnamesByProductClass->{$product_class},
                         $nc,
                         $assignedMachines,
                         $assignedMachinesVirt,
                         $res->{$product_class}->{MINENDDATE}
                      ];
    }
    $report{'soon'} = (@SVALUES > 0)?{'cols' => \@SHEAD, 'vals' => \@SVALUES, 'opts' => \%SOPTIONS }:undef;


    #
    # Expired Subscriptions
    #
    
    $statement  = "select PRODUCT_CLASS, SUBSTATUS, SUM(NODECOUNT) as SUM_NODECOUNT, MIN(NODECOUNT) = -1 as UNLIMITED, MAX(SUBENDDATE) as MAXENDDATE ";
    $statement .= "from Subscriptions where (SUBSTATUS = 'EXPIRED' or (SUBENDDATE < ? and SUBENDDATE IS NOT NULL)) ";
    $statement .= "group by PRODUCT_CLASS order by PRODUCT_CLASS;";
    $sth = $dbh->prepare($statement);
    $sth->bind_param(1, $now, SQL_TIMESTAMP);
    $sth->execute;
    $res = $sth->fetchall_hashref("PRODUCT_CLASS");

    printLog($options{log}, $vblevel, LOG_DEBUG, "STATEMENT: ".$sth->{Statement});
    
    my @EHEAD = ( {
                   name  => __("Subscriptions"),
                   align => "auto",
                   id    => "sub"
                  },
                  {
                   name  => __("Total\nPurchase Count"),
                   align => "right",
                   id    => "number"
                  },
                  {
                   name  => __("Used\nLocally"),
                   align => "auto",
                   id    => "localused"
                  },
                  {
                   name  => __("Used Locally\n(Virtual)"),
                   align => "auto",
                   id    => "localusedvirt"
                  },
                  {
                   name  => __("Subscription\nExpires"),
                   align => "auto",
                   id    => "expires"
                  });
    my @EVALUES = ();
    my %EOPTIONS = ( 'headingText' => __("Expired Subscriptions")." ($time)", drawRowLine => 1 );
    
    foreach my $product_class (keys %{$res})
    {
        my $assignedMachines = int $calchash->{$product_class}->{MACHINES};
        my $assignedMachinesVirt = int $calchash->{$product_class}->{MACHINESVIRT};
        my $nc =  (int $res->{$product_class}->{SUM_NODECOUNT});

        if($res->{$product_class}->{UNLIMITED})
        {
            $nc = "unlimited";
        }
        
        push @EVALUES, [ $subnamesByProductClass->{$product_class},
                         $nc,
                         $assignedMachines,
                         $assignedMachinesVirt,
                         $res->{$product_class}->{MAXENDDATE}
                       ];
    }

    $report{'expired'} = (@EVALUES > 0) ? {'cols' => \@EHEAD, 'vals' => \@EVALUES, 'opts' => \%EOPTIONS } : undef; 

    #printLog($options{log}, $vblevel, LOG_DEBUG, "CALCHASH:".Data::Dumper->Dump([$calchash]));
   
    my $alerts = ''; 
    my $warning = ''; 

    my @SUMHEAD = ( {
                     name  => __("Subscription Type"), 
                     align => "auto",
                     id    => "subtype"
                    },
                    {
                     name  => __("Locally Registered\nSystems"),
                     align => "auto",
                     id    => "localregsystems"
                    },
                    {
                     name  => __("Locally Registered\nVirtual Systems"),
                     align => "auto",
                     id    => "localregsystemsvirt"
                    },
                    {
                     name  => __("Active\nPurchase Count"), 
                     align => "right",
                     id    => "active"
                    },
                    {
                     name  => __("Soon expiring\nPurchase Counts"), 
                     align => "right",
                     id    => "expiresoon"
                    },
                    {
                     name  => __("Over\nLimit"),
                     align => "right",
                     id    => "overlimit"
                    });

    my @SUMVALUES = ();
    my %SUMOPTIONS = ( 'headingText' => __('Summary')." ($time)", drawRowLine => 1 );


    foreach my $product_class (keys %{$calchash})
    {
        #
        # not exists means no subscription dataset from NCC available
        # this happens for "free" products like the SDK
        # skip these in the summary
        #
        next if(! exists $calchash->{$product_class}->{SUM_ACTIVE_SUB});
        
        my $missing = $calchash->{$product_class}->{TOTMACHINES} - $calchash->{$product_class}->{SUM_ACTIVE_SUB} - $calchash->{$product_class}->{SUM_ESOON_SUB};
        $missing = 0 if ($missing < 0);
        if($calchash->{$product_class}->{SUM_ACTIVE_SUB} == -1 ||
           $calchash->{$product_class}->{SUM_ESOON_SUB}  == -1)
        {
            $missing = 0;
        }
        
        push @SUMVALUES, [$subnamesByProductClass->{$product_class},
                          $calchash->{$product_class}->{TOTMACHINES},
                          $calchash->{$product_class}->{TOTMACHINESVIRT},
                          ($calchash->{$product_class}->{SUM_ACTIVE_SUB}==-1)?"unlimited":$calchash->{$product_class}->{SUM_ACTIVE_SUB},
                          ($calchash->{$product_class}->{SUM_ESOON_SUB}==-1)?"unlimited":$calchash->{$product_class}->{SUM_ESOON_SUB},
                          $missing];

        my $used_active = 0;
        my $used_esoon  = 0;
        my $used_expired = 0;
        my $dummy = $calchash->{$product_class}->{TOTMACHINES};
        
        if($calchash->{$product_class}->{SUM_ACTIVE_SUB} == -1 ||
           $dummy <= $calchash->{$product_class}->{SUM_ACTIVE_SUB})
        {
            $used_active = $dummy;
            $dummy = 0;
        }
        else
        {
            $used_active = $calchash->{$product_class}->{SUM_ACTIVE_SUB};
            $dummy -= $calchash->{$product_class}->{SUM_ACTIVE_SUB};
        }

        if($calchash->{$product_class}->{SUM_ESOON_SUB} == -1 ||
           $dummy <= $calchash->{$product_class}->{SUM_ESOON_SUB})
        {
            $used_esoon = $dummy;
            $dummy = 0;
        }
        else
        {
            $used_esoon = $calchash->{$product_class}->{SUM_ESOON_SUB};
            $dummy -= $calchash->{$product_class}->{SUM_ESOON_SUB};
        }

        $used_expired = $dummy;

        
        if($used_esoon == 1)
        {
            $warning .= sprintf(__("%d machine use a '%s' subscription, which expires within the next 30 Days. Please renew the subscription.\n"), 
                                $used_esoon, join(" / ", split(/\n/, $subnamesByProductClass->{$product_class})));
        }
        elsif($used_esoon > 1)
        {
            $warning .= sprintf(__("%d machines use a '%s' subscription, which expires within the next 30 Days. Please renew the subscription.\n"), 
                                $used_esoon, join(" / ", split(/\n/, $subnamesByProductClass->{$product_class})));
        }

        
        if($missing == 1)
        {
            $alerts .= sprintf(__("%d machine use too many '%s' subscriptions. Please log in to the Novell Customer Center (http://www.novell.com/center) and assign or purchase matching entitlements.\n"), 
                               $missing, join(" / ", split(/\n/, $subnamesByProductClass->{$product_class})));
        }
        elsif($missing > 1)
        {
            $alerts .= sprintf(__("%d machines use too many '%s' subscriptions. Please log in to the Novell Customer Center (http://www.novell.com/center) and assign or purchase matching entitlements.\n"), 
                               $missing, join(" / ", split(/\n/, $subnamesByProductClass->{$product_class})));
        }
    }

    # search for failed NCC registrations and add them to the alerts
    $statement = "SELECT COUNT(DISTINCT GUID) from Registration WHERE NCCREGERROR != 0";
    my $count = $dbh->selectcol_arrayref($statement);
    if(exists $count->[0] && defined $count->[0] && $count->[0] > 0)
    {
        $alerts .= sprintf(__("NCC registration failed for %d Machines. \n"), $count->[0]);
    }
    
    $report{'summary'} = {'cols' => \@SUMHEAD, 'vals' => \@SUMVALUES, 'opts' => \%SUMOPTIONS };
    $report{'alerts'} = "";
    if($alerts ne "")
    {
        $report{'alerts'} = __("Alerts:\n").$alerts ;
    }
    if($warning ne "")
    {
        $report{'alerts'} = "\n".__("Warnings:\n").$warning ;
    }
        
    return \%report;
}


#
# based on real NCC data
#
sub subscriptionReport
{
    my %options = @_;
    my ($cfg, $dbh) = init();
    my %report = ();
    
    my $vblevel = 0;
    if(exists $options{vblevel} && defined $options{vblevel})
    {
        $vblevel = $options{vblevel};
    }
    
    my $statement = "";
    my $time = SMT::Utils::getDBTimestamp();
    my $calchash = {};
    my $nowP30day = SMT::Utils::getDBTimestamp((time + (30*24*60*60)));
    my $now = SMT::Utils::getDBTimestamp();
    my $sth = undef;

    my $subnamesByProductClass = {};
    
    $statement = "select distinct PRODUCT_CLASS, SUBNAME from Subscriptions;";

    printLog($options{log}, $vblevel, LOG_DEBUG, "STATEMENT: $statement");

    my $res = $dbh->selectall_arrayref($statement, {Slice=>{}});
    
    foreach my $node (@{$res})
    {
        my $subname = $node->{SUBNAME};
        my $product_class = $node->{PRODUCT_CLASS};
        
        if(exists $subnamesByProductClass->{$product_class} && defined $subnamesByProductClass->{$product_class})
        {
            $subnamesByProductClass->{$product_class} .= "\n".$subname;
        }
        else
        {
            $subnamesByProductClass->{$product_class} = "$subname";
        }
    }

    $statement = "select PRODUCT_CLASS, SUM(CONSUMED) AS SUM_TOTALCONSUMED, SUM(CONSUMEDVIRT) AS SUM_TOTALCONSUMEDVIRT from Subscriptions group by PRODUCT_CLASS;";

    printLog($options{log}, $vblevel, LOG_DEBUG, "STATEMENT: $statement");

    $res = $dbh->selectall_hashref($statement, "PRODUCT_CLASS");

    foreach my $product_class (keys %{$res})
    {
        if(!exists $res->{$product_class}->{SUM_TOTALCONSUMED} || !defined $res->{$product_class}->{SUM_TOTALCONSUMED})
        {
            $res->{$product_class}->{SUM_TOTALCONSUMED} = 0;
        }
        if(!exists $res->{$product_class}->{SUM_TOTALCONSUMEDVIRT} || !defined $res->{$product_class}->{SUM_TOTALCONSUMEDVIRT})
        {
            $res->{$product_class}->{SUM_TOTALCONSUMEDVIRT} = 0;
        }
        
        $calchash->{$product_class}->{MACHINES}        = int $res->{$product_class}->{SUM_TOTALCONSUMED};
        $calchash->{$product_class}->{TOTMACHINES}     = int $calchash->{$product_class}->{MACHINES};
        $calchash->{$product_class}->{TOTMACHINESVIRT} = int $res->{$product_class}->{SUM_TOTALCONSUMEDVIRT};
        $calchash->{$product_class}->{SUM_ACTIVE_SUB}  = 0;
        $calchash->{$product_class}->{SUM_ESOON_SUB}   = 0;
    }

    #
    # Active Subscriptions
    #

    $statement  = "select SUBID, SUBNAME, PRODUCT_CLASS, REGCODE, NODECOUNT, CONSUMED, CONSUMEDVIRT, SUBSTATUS, SUBENDDATE from Subscriptions ";
    $statement .= "where SUBSTATUS = 'ACTIVE' and (SUBENDDATE > ? or SUBENDDATE IS NULL);";
    $sth = $dbh->prepare($statement);
    $sth->bind_param(1, $nowP30day, SQL_TIMESTAMP);
    $sth->execute;
    $res = $sth->fetchall_hashref("SUBID");

    printLog($options{log}, $vblevel, LOG_DEBUG, "STATEMENT: ".$sth->{Statement}." DATE: $nowP30day");

    #
    # old
    #
    #$statement  = "select s.SUBID, COUNT(c.GUID) as MACHINES from Subscriptions s, ClientSubscriptions cs, Clients c ";
    #$statement .= "where s.SUBID = cs.SUBID and cs.GUID = c.GUID and s.SUBSTATUS = 'ACTIVE' and ";
    #$statement .= "(s.SUBENDDATE > ? or s.SUBENDDATE IS NULL) group by SUBID order by SUBENDDATE";
    #$sth = $dbh->prepare($statement);
    #$sth->bind_param(1, $nowP30day, SQL_TIMESTAMP);
    #$sth->execute;
    #my $assigned = $sth->fetchall_hashref("SUBID");

    $statement  = "select s.SUBID, COUNT(cs.GUID) as MACHINES from Subscriptions s, ClientSubscriptions cs, MachineData m ";
    $statement .= "where s.SUBID = cs.SUBID and cs.GUID = m.GUID and m.KEYNAME= 'host' and m.VALUE = '' and s.SUBSTATUS = 'ACTIVE' and ";
    $statement .= "(s.SUBENDDATE > ? or s.SUBENDDATE IS NULL) group by SUBID order by SUBENDDATE";
    $sth = $dbh->prepare($statement);
    $sth->bind_param(1, $nowP30day, SQL_TIMESTAMP);
    $sth->execute;
    my $assigned = $sth->fetchall_hashref("SUBID");

    printLog($options{log}, $vblevel, LOG_DEBUG, "STATEMENT: ".$sth->{Statement}." DATE: $nowP30day");

    foreach my $subid (keys %{$assigned})
    {
        if(exists $res->{$subid})
        {
            $res->{$subid}->{ASSIGNED_MACHINES} = $assigned->{$subid}->{MACHINES};
        }
    }

    $statement  = "select s.SUBID, COUNT(cs.GUID) as MACHINES from Subscriptions s, ClientSubscriptions cs, MachineData m ";
    $statement .= "where s.SUBID = cs.SUBID and cs.GUID = m.GUID and m.KEYNAME= 'host' and m.VALUE != '' and s.SUBSTATUS = 'ACTIVE' and ";
    $statement .= "(s.SUBENDDATE > ? or s.SUBENDDATE IS NULL) group by SUBID order by SUBENDDATE";
    $sth = $dbh->prepare($statement);
    $sth->bind_param(1, $nowP30day, SQL_TIMESTAMP);
    $sth->execute;
    my $assignedVirt = $sth->fetchall_hashref("SUBID");

    printLog($options{log}, $vblevel, LOG_DEBUG, "STATEMENT: ".$sth->{Statement}." DATE: $nowP30day");

    foreach my $subid (keys %{$assignedVirt})
    {
        if(exists $res->{$subid})
        {
            $res->{$subid}->{ASSIGNED_VIRT_MACHINES} = $assignedVirt->{$subid}->{MACHINES};
        }
    }

    my @AHEAD = ( {
                   name  => __("Subscriptions"),
                   align => "auto",
                   id    => "sub"
                  },
                  {
                   name  => __("Activation Code"),
                   align => "left",
                   id    => "regcode"
                  },
                  {
                   name  => __("Total\nPurchase Count"),
                   align => "right",
                   id    => "number"
                  },
                  {
                   name  => __("Total\nUsed"),
                   align => "auto",
                   id    => "used"
                  },
                  {
                   name  => __("Total Used\n(Virtual)"),
                   align => "auto",
                   id    => "usedvirt"
                  },
                  {
                   name  => __("Used\nLocally"),
                   align => "auto",
                   id    => "localused"
                  },
                  {
                   name  => __("Used Locally\n(Virtual)"),
                   align => "auto",
                   id    => "localusedvirt"
                  },
                  {
                   name  => __("Subscription\nExpires"),
                   align => "auto",
                   id    => "expires"
                  }
                );

    my @AVALUES = ();
    my %AOPTIONS = ( 'headingText' => __("Active Subscriptions")." ($time)" );
    
    printLog($options{log}, $vblevel, LOG_DEBUG, "Assigned status: ".Data::Dumper->Dump([$res]));
    
    foreach my $subid (keys %{$res})
    {
        my $nc = (int $res->{$subid}->{NODECOUNT});
        my $subname = $res->{$subid}->{SUBNAME};
        my $product_class = $res->{$subid}->{PRODUCT_CLASS};
        
        if($nc == -1)
        {
            $calchash->{$product_class}->{SUM_ACTIVE_SUB} = -1;
            $nc = "unlimited";
        }
        else
        {
            $calchash->{$product_class}->{SUM_ACTIVE_SUB} += $nc if($calchash->{$product_class}->{SUM_ACTIVE_SUB} != -1);
        }
        
        push @AVALUES, [ $res->{$subid}->{SUBNAME},
                         $res->{$subid}->{REGCODE},
                         $nc,
                         $res->{$subid}->{CONSUMED},
                         $res->{$subid}->{CONSUMEDVIRT},
                         (exists $res->{$subid}->{ASSIGNED_MACHINES})?$res->{$subid}->{ASSIGNED_MACHINES}:0,
                         (exists $res->{$subid}->{ASSIGNED_VIRT_MACHINES})?$res->{$subid}->{ASSIGNED_VIRT_MACHINES}:0,
                         (!defined $res->{$subid}->{SUBENDDATE})?"never":$res->{$subid}->{SUBENDDATE}
                       ];
    }
    $report{'active'} = {'cols' => \@AHEAD, 'vals' => [sort {$a->[0] cmp $b->[0]} @AVALUES], 'opts' => \%AOPTIONS };

    #
    # Expire soon
    #

    $statement  = "select SUBID, SUBNAME, PRODUCT_CLASS, REGCODE, NODECOUNT, CONSUMED, CONSUMEDVIRT, SUBSTATUS, SUBENDDATE from Subscriptions ";
    $statement .= "where SUBSTATUS = 'ACTIVE' and SUBENDDATE <= ? and SUBENDDATE > ? ;";
    $sth = $dbh->prepare($statement);
    $sth->bind_param(1, $nowP30day, SQL_TIMESTAMP);
    $sth->bind_param(2, $now, SQL_TIMESTAMP);
    $sth->execute;
    $res = $sth->fetchall_hashref("SUBID");

    printLog($options{log}, $vblevel, LOG_DEBUG, "STATEMENT: ".$sth->{Statement}." DATE: $nowP30day");

    #
    # old
    #
    #$statement  = "select s.SUBID, COUNT(c.GUID) as MACHINES from Subscriptions s, ClientSubscriptions cs, Clients c ";
    #$statement .= "where s.SUBID = cs.SUBID and cs.GUID = c.GUID and s.SUBSTATUS = 'ACTIVE' and ";
    #$statement .= "s.SUBENDDATE <= ? and s.SUBENDDATE > ? group by SUBID order by SUBENDDATE";
    #$sth = $dbh->prepare($statement);
    #$sth->bind_param(1, $nowP30day, SQL_TIMESTAMP);
    #$sth->bind_param(2, $now, SQL_TIMESTAMP);
    #$sth->execute;
    #$assigned = $sth->fetchall_hashref("SUBID");

    $statement  = "select s.SUBID, COUNT(cs.GUID) as MACHINES from Subscriptions s, ClientSubscriptions cs, MachineData m ";
    $statement .= "where s.SUBID = cs.SUBID and cs.GUID = m.GUID  and m.KEYNAME= 'host' and m.VALUE = '' and s.SUBSTATUS = 'ACTIVE' and ";
    $statement .= "s.SUBENDDATE <= ? and s.SUBENDDATE > ? group by SUBID order by SUBENDDATE";
    $sth = $dbh->prepare($statement);
    $sth->bind_param(1, $nowP30day, SQL_TIMESTAMP);
    $sth->bind_param(2, $now, SQL_TIMESTAMP);
    $sth->execute;
    $assigned = $sth->fetchall_hashref("SUBID");

    printLog($options{log}, $vblevel, LOG_DEBUG, "STATEMENT: ".$sth->{Statement}." DATE: $nowP30day");

    foreach my $subid (keys %{$assigned})
    {
        if(exists $res->{$subid})
        {
            $res->{$subid}->{ASSIGNED_MACHINES} = $assigned->{$subid}->{MACHINES};
        }
    }

    $statement  = "select s.SUBID, COUNT(cs.GUID) as MACHINES from Subscriptions s, ClientSubscriptions cs, MachineData m ";
    $statement .= "where s.SUBID = cs.SUBID and cs.GUID = m.GUID  and m.KEYNAME= 'host' and m.VALUE != '' and s.SUBSTATUS = 'ACTIVE' and ";
    $statement .= "s.SUBENDDATE <= ? and s.SUBENDDATE > ? group by SUBID order by SUBENDDATE";
    $sth = $dbh->prepare($statement);
    $sth->bind_param(1, $nowP30day, SQL_TIMESTAMP);
    $sth->bind_param(2, $now, SQL_TIMESTAMP);
    $sth->execute;
    $assignedVirt = $sth->fetchall_hashref("SUBID");

    printLog($options{log}, $vblevel, LOG_DEBUG, "STATEMENT: ".$sth->{Statement}." DATE: $nowP30day");

    foreach my $subid (keys %{$assignedVirt})
    {
        if(exists $res->{$subid})
        {
            $res->{$subid}->{ASSIGNED_VIRT_MACHINES} = $assignedVirt->{$subid}->{MACHINES};
        }
    }

    my @SHEAD = ( {
                   name  => __("Subscriptions"), 
                   align => "auto",
                   id    => "sub"
                  },
                  {
                   name  => __("Activation Code"), 
                   align => "left",
                   id    => "regcode"
                  },
                  {
                   name  => __("Total\nPurchase Count"), 
                   align => "right",
                   id    => "number"
                  },
                  {
                   name  => __("Total\nUsed") ,
                   align => "auto",
                   id    => "used"
                  },
                  {
                   name  => __("Total Used\n(Virtual)") ,
                   align => "auto",
                   id    => "usedvirt"
                  },
                  {
                   name  => __("Used\nLocally"), 
                   align => "auto",
                   id    => "localused"
                  },
                  {
                   name  => __("Used Locally\n(Virtual)"),
                   align => "auto",
                   id    => "localusedvirt"
                  },
                  {
                   name  => __("Subscription\nExpires"),
                   align => "auto",
                   id    => "expires"
                  } );
    my @SVALUES = ();
    my %SOPTIONS = ( 'headingText' => __('Subscriptions which expiring within the next 30 Days')." ($time)" );

    foreach my $subid (keys %{$res})
    {
        my $nc = (int $res->{$subid}->{NODECOUNT});
        my $subname = $res->{$subid}->{SUBNAME};
        my $product_class = $res->{$subid}->{PRODUCT_CLASS};

        if($nc == -1)
        {
            $calchash->{$product_class}->{SUM_ESOON_SUB} = -1;
            $nc = "unlimited";
        }
        else
        {
            $calchash->{$product_class}->{SUM_ESOON_SUB} += $nc if($calchash->{$product_class}->{SUM_ESOON_SUB} != -1);
        }

        push @SVALUES, [ $res->{$subid}->{SUBNAME},
                         $res->{$subid}->{REGCODE},
                         $nc,
                         $res->{$subid}->{CONSUMED},
                         $res->{$subid}->{CONSUMEDVIRT},
                         (exists $res->{$subid}->{ASSIGNED_MACHINES})?$res->{$subid}->{ASSIGNED_MACHINES}:0,
                         (exists $res->{$subid}->{ASSIGNED_VIRT_MACHINES})?$res->{$subid}->{ASSIGNED_VIRT_MACHINES}:0,
                         $res->{$subid}->{SUBENDDATE}
                       ];

    }
    $report{'soon'} = (@SVALUES > 0)?{'cols' => \@SHEAD, 'vals' => [sort {$a->[0] cmp $b->[0]} @SVALUES], 'opts' => \%SOPTIONS }:undef;

    #
    # Expired Subscriptions
    #

    $statement  = "select SUBID, SUBNAME, PRODUCT_CLASS, REGCODE, NODECOUNT, CONSUMED, CONSUMEDVIRT, SUBSTATUS, SUBENDDATE from Subscriptions ";
    $statement .= "where (SUBSTATUS = 'EXPIRED' or (SUBENDDATE < ? and SUBENDDATE IS NOT NULL)) ;";
    $sth = $dbh->prepare($statement);
    $sth->bind_param(1, $now, SQL_TIMESTAMP);
    $sth->execute;
    $res = $sth->fetchall_hashref("SUBID");
    
    printLog($options{log}, $vblevel, LOG_DEBUG, "STATEMENT: ".$sth->{Statement}." DATE: $nowP30day");
    
    #
    # old
    #
    #$statement  = "select s.SUBID, COUNT(c.GUID) as MACHINES from Subscriptions s, ClientSubscriptions cs, Clients c ";
    #$statement .= "where s.SUBID = cs.SUBID and cs.GUID = c.GUID and (s.SUBSTATUS = 'EXPIRED' or ";
    #$statement .= "(s.SUBENDDATE < ? and s.SUBENDDATE IS NOT NULL)) group by SUBID order by SUBENDDATE";
    #$sth = $dbh->prepare($statement);
    #$sth->bind_param(1, $now, SQL_TIMESTAMP);
    #$sth->execute;
    #$assigned = $sth->fetchall_hashref("SUBID");

    $statement  = "select s.SUBID, COUNT(cs.GUID) as MACHINES from Subscriptions s, ClientSubscriptions cs, MachineData m ";
    $statement .= "where s.SUBID = cs.SUBID and cs.GUID = m.GUID and m.KEYNAME= 'host' and m.VALUE = '' and (s.SUBSTATUS = 'EXPIRED' or ";
    $statement .= "(s.SUBENDDATE < ? and s.SUBENDDATE IS NOT NULL)) group by SUBID order by SUBENDDATE";
    $sth = $dbh->prepare($statement);
    $sth->bind_param(1, $now, SQL_TIMESTAMP);
    $sth->execute;
    $assigned = $sth->fetchall_hashref("SUBID");
    
    printLog($options{log}, $vblevel, LOG_DEBUG, "STATEMENT: ".$sth->{Statement}." DATE: $nowP30day");
    
    foreach my $subid (keys %{$assigned})
    {
        if(exists $res->{$subid})
        {
            $res->{$subid}->{ASSIGNED_MACHINES} = $assigned->{$subid}->{MACHINES};
        }
    }

    $statement  = "select s.SUBID, COUNT(cs.GUID) as MACHINES from Subscriptions s, ClientSubscriptions cs, MachineData m ";
    $statement .= "where s.SUBID = cs.SUBID and cs.GUID = m.GUID and m.KEYNAME= 'host' and m.VALUE != '' and (s.SUBSTATUS = 'EXPIRED' or ";
    $statement .= "(s.SUBENDDATE < ? and s.SUBENDDATE IS NOT NULL)) group by SUBID order by SUBENDDATE";
    $sth = $dbh->prepare($statement);
    $sth->bind_param(1, $now, SQL_TIMESTAMP);
    $sth->execute;
    $assignedVirt = $sth->fetchall_hashref("SUBID");
    
    printLog($options{log}, $vblevel, LOG_DEBUG, "STATEMENT: ".$sth->{Statement}." DATE: $nowP30day");
    
    foreach my $subid (keys %{$assignedVirt})
    {
        if(exists $res->{$subid})
        {
            $res->{$subid}->{ASSIGNED_VIRT_MACHINES} = $assignedVirt->{$subid}->{MACHINES};
        }
    }

    my @EHEAD = ( {
                   name  => __("Subscriptions"), 
                   align => "auto",
                   id    => "sub"
                  },
                  {
                   name  => __("Activation Code"), 
                   align => "left",
                   id    => "regcode"
                  },
                  {
                   name  => __("Total\nPurchase Count"), 
                   align => "right",
                   id    => "purchasecount"
                  },
                  {
                   name  => __("Total\nUsed") ,
                   align => "auto",
                   id    => "used"
                  },
                  {
                   name  => __("Total Used\n(Virtual)") ,
                   align => "auto",
                   id    => "usedvirt"
                  },
                  {
                   name  => __("Used\nLocally"), 
                   align => "auto",
                   id    => "localused"
                  },
                  {
                   name  => __("Used Locally\n(Virtual)"),
                   align => "auto",
                   id    => "localusedvirt"
                  },
                  {
                   name  => __("Subscription\nExpires"),
                   align => "auto",
                   id    => "expires"
                  } );
    my @EVALUES = ();
    my %EOPTIONS = ( 'headingText' => __('Expired Subscriptions')." ($time)" );
    
    foreach my $subid (keys %{$res})
    {
        my $nc = (int $res->{$subid}->{NODECOUNT});
        my $subname = $res->{$subid}->{SUBNAME};

        if($nc == -1)
        {
            $nc = "unlimited";
        }
        
        push @EVALUES, [ $res->{$subid}->{SUBNAME},
                         $res->{$subid}->{REGCODE},
                         $nc,
                         $res->{$subid}->{CONSUMED},
                         $res->{$subid}->{CONSUMEDVIRT},
                         (exists $res->{$subid}->{ASSIGNED_MACHINES})?$res->{$subid}->{ASSIGNED_MACHINES}:0,
                         (exists $res->{$subid}->{ASSIGNED_VIRT_MACHINES})?$res->{$subid}->{ASSIGNED_VIRT_MACHINES}:0,
                         $res->{$subid}->{SUBENDDATE}
                       ];
    }

    $report{'expired'} = (@EVALUES > 0) ? {'cols' => \@EHEAD, 'vals' => [sort {$a->[0] cmp $b->[0]} @EVALUES], 'opts' => \%EOPTIONS } : undef; 


    #
    # SUMMARY
    #
    my $alerts = '';
    my $warning = '';
    my @SUMHEAD = ( {
                     name  => __("Subscription Type"),
                     align => "auto",
                     id    => "subtype"
                    },
                    {
                     name  => __("Total Systems\nRegistered with NCC"),
                     align => "auto",
                     id    => "regsystems"
                    },
                    {
                     name  => __("Total Virtual Systems\nRegistered with NCC"),
                     align => "auto",
                     id    => "regsystemsvirt"
                    },
                    {
                     name  => __("Active\nPurchase Count"),
                     align => "right",
                     id    => "active"
                    },
                    {
                     name  => __("Soon expiring\nPurchase Counts"), 
                     align => "right",
                     id    => "expiresoon"
                    },
                    {
                     name  => __("Over\nLimit"),
                     align => "right",
                     id    => "overlimit"
                    });
    my @SUMVALUES = ();
    my %SUMOPTIONS = ( 'headingText' => __('Summary')." ($time)", drawRowLine => 1 );

    foreach my $product_class (keys %{$calchash})
    {
        
        my $missing = $calchash->{$product_class}->{TOTMACHINES} - $calchash->{$product_class}->{SUM_ACTIVE_SUB} - $calchash->{$product_class}->{SUM_ESOON_SUB};

        if($calchash->{$product_class}->{SUM_ACTIVE_SUB} == -1 ||
           $calchash->{$product_class}->{SUM_ESOON_SUB}  == -1)
        {
            $missing = 0;
        }
        
        $missing = 0 if ($missing < 0);
        
        push @SUMVALUES, [$subnamesByProductClass->{$product_class}, 
                          $calchash->{$product_class}->{TOTMACHINES}, 
                          $calchash->{$product_class}->{TOTMACHINESVIRT}, 
                          ($calchash->{$product_class}->{SUM_ACTIVE_SUB}==-1)?"unlimited":$calchash->{$product_class}->{SUM_ACTIVE_SUB}, 
                          ($calchash->{$product_class}->{SUM_ESOON_SUB}==-1)?"unlimited":$calchash->{$product_class}->{SUM_ESOON_SUB}, 
                          $missing];
        my $used_active = 0;
        my $used_esoon  = 0;
        my $used_expired = 0;
        my $dummy = $calchash->{$product_class}->{TOTMACHINES};
        
        if($calchash->{$product_class}->{SUM_ACTIVE_SUB} == -1 || 
           $dummy <= $calchash->{$product_class}->{SUM_ACTIVE_SUB})
        {
            $used_active = $dummy;
            $dummy = 0;
        }
        else
        {
            $used_active = $calchash->{$product_class}->{SUM_ACTIVE_SUB};
            $dummy -= $calchash->{$product_class}->{SUM_ACTIVE_SUB};
        }

        if($calchash->{$product_class}->{SUM_ESOON_SUB} == -1 ||
           $dummy <= $calchash->{$product_class}->{SUM_ESOON_SUB})
        {
            $used_esoon = $dummy;
            $dummy = 0;
        }
        else
        {
            $used_esoon = $calchash->{$product_class}->{SUM_ESOON_SUB};
            $dummy -= $calchash->{$product_class}->{SUM_ESOON_SUB};
        }

        $used_expired = $dummy;

        if($used_esoon == 1)
        {
            $warning .= sprintf(__("%d machine use a '%s' subscription, which expires within the next 30 Days. Please renew the subscription.\n"), 
                                $used_esoon, join(" / ", split(/\n/, $subnamesByProductClass->{$product_class})));
        }
        elsif($used_esoon > 1)
        {
            $warning .= sprintf(__("%d machines use a '%s' subscription, which expires within the next 30 Days. Please renew the subscription.\n"), 
                                $used_esoon, join(" / ", split(/\n/, $subnamesByProductClass->{$product_class})));
        }

        if($missing == 1)
        {
            $alerts .= sprintf(__("%d machine use too many '%s' subscriptions. Please log in to the Novell Customer Center (http://www.novell.com/center) and assign or purchase matching entitlements.\n"), 
                               $missing, join(" / ", split(/\n/, $subnamesByProductClass->{$product_class})));
        }
        elsif($missing > 1)
        {
            $alerts .= sprintf(__("%d machines use too many '%s' subscriptions. Please log in to the Novell Customer Center (http://www.novell.com/center) and assign or purchase matching entitlements.\n"), 
                               $missing, join(" / ", split(/\n/, $subnamesByProductClass->{$product_class})));
        }
    }

    # search for failed NCC registrations and add them to the alerts
    $statement = "SELECT COUNT(DISTINCT GUID) from Registration WHERE NCCREGERROR != 0";
    my $count = $dbh->selectcol_arrayref($statement);
    if(exists $count->[0] && defined $count->[0] && $count->[0] > 0)
    {
        $alerts .= sprintf(__("NCC registration failed for %d Machines. \n"), $count->[0]);
    }

    $report{'summary'} = {'cols' => \@SUMHEAD, 'vals' => [sort {$a->[0] cmp $b->[0]} @SUMVALUES], 'opts' => \%SUMOPTIONS }; 
    $report{'alerts'} = "";
    if($alerts ne "")
    {
        $report{'alerts'} = __("Alerts:\n").$alerts ;
    }

    if($warning ne "")
    {
        $report{'alerts'} .= "\n".__("Warnings:\n").$warning ;
    }
    
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

    printLog($options{log}, $options{vblevel}, LOG_DEBUG, "Check $certfile: Valid for $days days");
    
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


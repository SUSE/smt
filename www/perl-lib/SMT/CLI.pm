# let's rename this module to SMT::Common (it's already used by YaST, too),
# or even split it into several (it's ~3000 lines already) e.g. SMT::Common,
# SMT::Common::Repos, SMT::Common::CLI, SMT::Command::Reports etc.  

package SMT::CLI;
use strict;
use warnings;

use URI;
use SMT::Utils;
use DBI qw(:sql_types);
use Text::ASCIITable;
use Config::IniFiles;
use File::Temp;
use File::Path;
use File::Copy;
use IO::File;

use SMT::Parser::NU;
use SMT::Mirror::Job;
#use SMT::Repositories;

use XML::Writer;
use Data::Dumper;

use File::Basename;
use Digest::SHA1  qw(sha1 sha1_hex);
use Time::HiRes qw(gettimeofday tv_interval);

use LIMAL;
use LIMAL::CaMgm;

use Locale::gettext ();
use POSIX ();     # Needed for setlocale()


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

=cut

POSIX::setlocale(&POSIX::LC_MESSAGES, "");

use constant {
    # Set to '0' to disable reinitializing
    REINIT_AFTER => 1024,
};

# caches the current configuration and DB connection
my $smt_config = {};

#
# init_internal
#  internal function that reads the configuration and initializes DB connection
#  use init()
#
sub init_internal
{
    $smt_config->{cfg} = SMT::Utils::getSMTConfig();

    if ( not $smt_config->{dbh}=SMT::Utils::db_connect($smt_config->{cfg}) )
    {
        die __("ERROR: Could not connect to the database");
    }

    $smt_config->{counter} = 0;
}

#
# init
#  returns the current smt configuration and database connection
#  both are cached
#
sub init
{
    # Flushes the cached configuration and DB after REINIT_AFTER calls
    $smt_config = {} if (defined $smt_config->{counter} && REINIT_AFTER > 0 && $smt_config->{counter} >= REINIT_AFTER);

    # Initialize the configuration and DB if not yet configured
    init_internal() if (! defined $smt_config->{counter});
    ++$smt_config->{counter};

    return ($smt_config->{cfg}, $smt_config->{dbh});
}

sub checkFormat ($)
{
    my $checkformat = lc (shift);

    if ($checkformat eq 'asciitable' || $checkformat eq 'csv') {
	return 1;
    } else {
	printf STDERR (__("Unknown format '%s'. Supported are 'asciitable' and 'csv'.\n"), $checkformat);
	return 0;
    }
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
        $val ||= '';            # (bnc#656254)
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
        push @HEAD,  __('Repos mirrored?');
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
=item listProducts

Shows products. Pass mirrorable => 1 to get only mirrorable
products. 0 for non-mirrorable products, or nothing to get all
products.

=cut

sub listProducts
{
    my %options = @_;

    $options{format} = 'asciitable' if (! defined $options{format});

    print renderReport(getProducts(%options), $options{format}, '');
}


sub getRegistrations
{
    my ($cfg, $dbh) = init();

    my $clients = $dbh->selectall_arrayref("SELECT GUID, HOSTNAME, LASTCONTACT, NAMESPACE from Clients ORDER BY LASTCONTACT", {Slice => {}});

    my @HEAD = ( __('Unique ID'), __('Hostname'), __('Last Contact'), __('Namespace'), __('Product') );
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
        push @VALUES, [ $clnt->{GUID}, $clnt->{HOSTNAME}, $clnt->{LASTCONTACT}, $clnt->{NAMESPACE}, $prdstr ];
    }
    return {'cols' => \@HEAD, 'vals' => \@VALUES, 'opts' => \%OPTIONS };
}


#
# wrapper function to keep compatibility while changing the called function
#
=item listRegistrations

Shows active registrations on the system.

=cut

sub listRegistrations
{
    my %options = @_;

    $options{format} = 'asciitable' if (! defined $options{format});

    if(exists $options{verbose} && defined $options{verbose} && $options{verbose})
    {
        my ($cfg, $dbh) = init();

        my $clients = $dbh->selectall_arrayref("SELECT GUID, HOSTNAME, LASTCONTACT, NAMESPACE from Clients ORDER BY LASTCONTACT", {Slice => {}});

        foreach my $clnt (@{$clients})
        {
            my $products = $dbh->selectall_arrayref(sprintf("SELECT p.PRODUCT, p.VERSION, p.REL, p.ARCH, r.REGDATE, r.NCCREGDATE, r.NCCREGERROR from Products p, Registration r WHERE r.GUID=%s and r.PRODUCTID=p.PRODUCTDATAID", 
                                                            $dbh->quote($clnt->{GUID})), {Slice => {}});
        
            print __('Unique ID')." : $clnt->{GUID}\n";
            print __('Hostname')." : $clnt->{HOSTNAME}\n";
            print __('Last Contact')." : $clnt->{LASTCONTACT}\n";
            print __('Namespace')." : $clnt->{NAMESPACE}\n";

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
	print renderReport(getRegistrations(), $options{format}, '');
    }

    return 1;
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
            print sprintf(__("Repository [%s %s] cannot be enabled. Access on the server denied.\n"), 
                          $row->{NAME}, 
                          ($row->{TARGET}) ? $row->{TARGET} : "");
        }
        else
        {
            SMT::CLI::setCatalogDoMirror(enabled => $enable, name => $row->{NAME}, target => $row->{TARGET});
            print sprintf(__("Repository [%s %s] %s.\n"),
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

=item setCatalogDoMirror

Set the catalog mirror flag to enabled or disabled.

Pass id => foo to select the catalog.
Pass enabled => 1 or enabled => 0;
disabled => 1 or disabled => 0 are supported as well.

Returns the number of rows changed.

 TODO: move to SMT::Common::Repos
 TODO: use SMT::Repositories::changeRepoStatus() (adjusted) to write to DB to
       avoid code duplication. (BTW, it may be in SMT::DB::Repos in the future)

=cut

sub setCatalogDoMirror
{
    my %opt = @_;
    my ($cfg, $dbh) = init();
    
    if(exists $opt{enabled} && defined $opt{enabled} )
    {
        my $sql = "update Catalogs";
        $sql .= sprintf(" set Domirror=%s", $dbh->quote(  $opt{enabled} ? "Y" : "N" ) ); 
        
        $sql .= " where 1";
        
        # allow enable mirroring only if the repository is mirrorable
        # but disabling is allowed if the repository is not mirrorable
        # See bnc#619314
        if($opt{enabled})
        {
          $sql .= sprintf(" and Mirrorable=%s", $dbh->quote("Y"));
        }
        
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

=item setCatalogStaging

Enable staging for given catalog(s).

Pass id => foo to select the catalog. Pass enabled => 1 or enabled => 0;
disabled => 1 or disabled => 0 are supported as well.

Returns the number of rows changed.

Writes to Catalogs table and moves repository directories, as follows:
 When enabling staging:
 - remove repo/full/$foo
 - move repo/$foo to repo/full/$foo
 When disabling staging:
 - remove repo/testing/$foo
 - remove repo/$foo
 - move repo/full/$foo to repo/$foo

 TODO: move to SMT::Common::Repos
 TODO: use SMT::Repositories::changeRepoStatus() (adjusted) to write to DB to
       avoid code duplication. (BTW, it may be in SMT::DB::Repos in the future)

=cut

sub setCatalogStaging
{
    my %opt = @_;

    die __("enabled option missing") if (not defined $opt{enabled});

    my ($cfg, $dbh) = init();

    # only mirrorable repos can be staged
    my $where = sprintf(' where MIRRORABLE=%s', $dbh->quote('Y'));
    
    # ignore the rows having the desired STAGING value
    $where .= sprintf(' and STAGING!=%s',
                $dbh->quote($opt{enabled} ? 'Y' : 'N' ));

    # select desired repos
    if(defined $opt{name} && $opt{name} ne "")
    {
        $where .= sprintf(' and NAME=%s', $dbh->quote($opt{name}));
    }
    if(defined $opt{target} && $opt{target} ne "")
    {
        $where .= sprintf(' and TARGET=%s', $dbh->quote($opt{target}));
    }
    if(defined $opt{id})
    {
        $where .= sprintf(' and CATALOGID=%s', $dbh->quote($opt{id}));
    }

    # get local paths from the to-be-updated repositories
    my @toupdate = ();
    eval
    {
        my $sql = 'select LOCALPATH from Catalogs' . $where;
        my $array = $dbh->selectall_arrayref($sql, { Slice => {} });
        push @toupdate, $_->{LOCALPATH} foreach (@$array);
    };
    if ($@)
    {
        die 'DBERROR: ' . $@;
    }

    my $sql = 'update Catalogs';
    $sql .= sprintf(' set STAGING=%s', $dbh->quote(  $opt{enabled} ? 'Y' : 'N' ) ); 
    $sql .= $where;
    #print $sql . "\n";
    my $rows = $dbh->do($sql);

    $rows = 0 if(!defined $rows || $rows < 0);
    if ($rows && $rows == @toupdate)
    {
        # DB successfully updated, now shuffle the repo directories
        # (bnc #509922)

        my $basepath = $cfg->val('LOCAL', 'MirrorTo');
        foreach my $repopath (@toupdate)
        {
            my $fullpath = SMT::Utils::cleanPath(
                $basepath, 'repo/full', $repopath);
            my $productionpath = SMT::Utils::cleanPath(
                $basepath, 'repo', $repopath);

            # when enabling staging:
            # - remove repo/full/$foo
            # - move repo/$foo to repo/full/$foo
            if ($opt{enabled})
            {
                rmtree($fullpath, 0, 0) if (-d $fullpath);
                mkpath($fullpath);
                move($productionpath, $fullpath) if (-d $productionpath);
            }
            # when disabling staging:
            # - remove repo/testing/$foo
            # - remove repo/$foo
            # - move repo/full/$foo to repo/$foo
            else
            {
                my $testingpath = SMT::Utils::cleanPath(
                    $basepath, 'repo/testing', $repopath);
                rmtree($testingpath, 0, 0) if (-d $testingpath);
                rmtree($productionpath, 0, 0) if (-d $productionpath);
                move($fullpath, $productionpath) if (-d $fullpath);
            }
        }

        return $rows;
    }

    return 0;
}

=item catalogDoMirrorFlag

Pass id => foo to select the catalog.
true if the catalog is set to be mirrored, false otherwise

=cut

sub catalogDoMirrorFlag
{
  my %options = @_;
  my ($cfg, $dbh) = init();
  return 1;
}

sub setDoMirrorFromXml
{
    my %opt = @_;
    my ($cfg, $dbh) = init();
    if(exists $opt{xml} && defined $opt{xml} )
    {
        my $enabledCatalogIds = {};
        my $enabledCatalogs_parser = SMT::Parser::RegData->new(vblevel => 0, log => undef);
        $enabledCatalogs_parser->parse($opt{xml}, 
            sub {
                my $data = shift;
                $enabledCatalogIds->{$data->{CATALOGID}} = 1;
            }
        );

        # Delete mirror flag from catalogs that are not present in the mirrorinfo file
        my $sql = "select CATALOGID from Catalogs where DOMIRROR = 'Y'"; 
        my $sth = $dbh->prepare($sql);
        $sth->execute();
        while (my $values = $sth->fetchrow_hashref())  
        {
            my $catalogid = $values->{CATALOGID};
            if ( exists $enabledCatalogIds->{$catalogid} && $enabledCatalogIds->{$catalogid} == 1 )
            {
                # Mirror Flag already set remove from hash
                delete  $enabledCatalogIds->{$catalogid};
            }
            else
            {
                # Catalog no longer mirrorred remove from db
                my $sth = $dbh->do( sprintf("UPDATE Catalogs SET DOMIRROR='N' WHERE CATALOGID=%s", $dbh->quote($catalogid)));
            }
        }
        # Enable the remaining catalogids for mirroring
        foreach my $id ( keys (%{$enabledCatalogIds}) )
        {
            my $sth = $dbh->do( sprintf("UPDATE Catalogs SET DOMIRROR='Y' WHERE CATALOGID=%s", $dbh->quote($id)));
        }
    }
    else
    {
        die __("xml option missing");
    }
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
            # happens on SLMS which provide no "service"
            $nuri = undef;
        }
    }

    my $indexfile = "";

    if(exists $opt{fromdir} && defined $opt{fromdir} && -d $opt{fromdir})
    {
        $indexfile = $opt{fromdir}."/repo/repoindex.xml";
    }
    elsif( defined $nuri )
    {
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
        if(exists $opt{todir} && defined $opt{todir} && -d $opt{todir})
        {
            $destdir = $opt{todir};
        }
        
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
    
    if ( -s $indexfile )
    {
        my $sqlres = $dbh->selectall_hashref("select Name, Target, Mirrorable from Catalogs where CATALOGTYPE = 'nu' or CATALOGTYPE = 'yum'", ['Name', 'Target']);
    
        my $parser = SMT::Parser::NU->new(vblevel => $opt{vblevel}, log => $opt{log});
        $parser->parse($indexfile, 
                       sub 
                       {
                           my $repodata = shift;
                           
                           if(exists $sqlres->{$repodata->{NAME}}->{$repodata->{DISTRO_TARGET}}->{Mirrorable} )
                           {
                               if( uc($sqlres->{$repodata->{NAME}}->{$repodata->{DISTRO_TARGET}}->{Mirrorable}) ne "Y")
                               {
                                   printLog($opt{log}, $opt{vblevel}, LOG_INFO1, 
                                            sprintf(__("* New mirrorable repository '%s %s' ."), $repodata->{NAME}, $repodata->{DISTRO_TARGET}));
                                   my $sth = $dbh->do( sprintf("UPDATE Catalogs SET Mirrorable='Y' WHERE NAME=%s AND TARGET=%s", 
                                                               $dbh->quote($repodata->{NAME}), $dbh->quote($repodata->{DISTRO_TARGET}) ));
                               }
                               delete $sqlres->{$repodata->{NAME}}->{$repodata->{DISTRO_TARGET}};
                           }
                       }
                      );
        
        foreach my $cname ( keys %{$sqlres})
        {
            foreach my $target ( keys %{$sqlres->{$cname}})
            {
                if( uc($sqlres->{$cname}->{$target}->{Mirrorable}) eq "Y" )
                {
                    printLog($opt{log}, $opt{vblevel}, LOG_INFO1, 
                             sprintf(__("* repository not longer mirrorable '%s %s' ."), $cname, $target ));
                    my $sth = $dbh->do( sprintf("UPDATE Catalogs SET Mirrorable='N' WHERE NAME=%s AND TARGET=%s", 
                                                $dbh->quote($cname), $dbh->quote($target) ));
                }
            }
        }
    }
    
    my $mirrorable_idx = undef;
    if(exists $opt{fromdir} && defined $opt{fromdir} && -d $opt{fromdir})
    {
        my $mirrorablefile = $opt{fromdir}."/mirrorable.xml";
        if ( -f $mirrorablefile && (stat($indexfile))[9] <= (stat($mirrorablefile))[9] )
        {
            printLog($opt{log}, $opt{vblevel}, LOG_DEBUG, "Parsing $mirrorablefile" );
            $mirrorable_idx = {};
            my $mirrorable_parser = SMT::Parser::RegData->new(vblevel => 0, log => undef);
            $mirrorable_parser->parse($mirrorablefile, 
                sub {
                    my $data = shift;
                    $mirrorable_idx->{$data->{CATALOGID}} = 1;
                }
            );
        }
    }

    my $useragent = SMT::Utils::createUserAgent(keep_alive => 1);
    my $sql = "select CATALOGID, NAME, LOCALPATH, EXTURL, TARGET from Catalogs where CATALOGTYPE='zypp'";
    my $values = $dbh->selectall_arrayref($sql);
    foreach my $v (@{$values})
    { 
        my $catId = $v->[0];
        my $catName = $v->[1];
        my $catLocal = $v->[2];
        my $catUrl = $v->[3];
        my $catTarget = $v->[4];
        if( $catUrl ne "" && $catLocal ne "" )
        {
            my $ret = 0;
            if(exists $opt{fromdir} && defined $opt{fromdir} && -d $opt{fromdir})
            {
                # fromdir is used on a server without internet connection
                # use the info from "mirrorable.xml" if it exists
                # if not, define that the catalogs are mirrorable
                if ( defined $mirrorable_idx )
                {
                    if ( defined $mirrorable_idx->{$catId} && $mirrorable_idx->{$catId} == 1 )
                    {
                        $ret = 1;
                    }
                    else
                    {
                        $ret = 0;
                    }
                }
                else 
                {
                    $ret = 1;
                }
            }
            else
            {
                $ret = isZyppMirrorable( log        => $opt{log},
                                         vblevel    => $opt{vblevel},
                                         NUUri      => $nuri,
                                         catalogurl => $catUrl,
                                         useragent  => $useragent );
            }
            printLog($opt{log}, $opt{vblevel}, LOG_DEBUG, sprintf(__("* set [%s] as%s mirrorable."), $catName, ( ($ret == 1) ? '' : ' not' )));
            my $statement = sprintf("UPDATE Catalogs SET Mirrorable=%s WHERE NAME=%s ",
                                    ( ($ret == 1) ? $dbh->quote('Y') : $dbh->quote('N') ), 
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

sub isZyppMirrorable
{
    my %opt = @_;

    # on nu.novell.com we need to authenticate, so put the
    # userinfo into this url
    my $url = URI->new( $opt{catalogurl} );
    if($url->host eq "nu.novell.com")
    {
        my $uuri = URI->new($opt{NUUri});
        my $userinfo = $uuri->userinfo;
        $url->userinfo($userinfo);
    }

    my $useragent = $opt{useragent};

    my $tempdir = File::Temp::tempdir("smt-XXXXXXXX", CLEANUP => 1, TMPDIR => 1);
    my $remote = $url->as_string()."/repodata/repomd.xml";
    my $local = $tempdir."/repodata/repomd.xml";
    # make sure the container destination exists
    &File::Path::mkpath( dirname($local) );

    my $redirects = 0;
    my $ret = 0;
    my $response;

    do
    {
        eval
        {
            $response = $useragent->get( $remote, ':content_file' => $local );
        };
        if($@)
        {
          printLog($opt{log}, $opt{vblevel}, LOG_DEBUG, "Get request aborted: ".$@);
          $ret = 0;
          return $ret;
        }
        
        if ( $response->is_redirect )
        {
            $redirects++;
            if($redirects > 5)
            {
                $ret = 0;
                printLog($opt{log}, $opt{vblevel}, LOG_ERROR, "Too many redirects.");
                return $ret;
            }
            
            my $newuri = $response->header("location");
            chomp($newuri);

            printLog($opt{log}, $opt{vblevel}, LOG_DEBUG, "Redirected to $newuri\n".$response->as_string());
            $remote = $newuri;
        }
        elsif($response->is_success)
        {
            $ret = 1;
        }
        else
        {
          my $saveuri = URI->new($remote);
          $saveuri->userinfo(undef);
          
          printLog($opt{log}, $opt{vblevel}, LOG_DEBUG, sprintf(__("Failed to download '%s': %s"),
                   $saveuri->as_string(), $response->status_line));
          printLog($opt{log}, $opt{vblevel}, LOG_DEBUG, $response->as_string());
        }
    } while( $response->is_redirect );
    return $ret;
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

=item setupCustomCatalogs

modify the database to setup catalogs create by the customer

=cut

sub setupCustomCatalogs
{
    my %options = @_;
    my ($cfg, $dbh) = init();

    # delete existing catalogs with this id
    
    removeCustomCatalog(%options);
    
    # now insert it again.
    my $exthost = $options{exturl};
    if($exthost =~ /^(https?:\/\/[^\/]+\/)/)
    {
        $exthost = $1;
    }
    elsif($exthost =~ /^file:/)
    {
        $exthost = "file://localhost";
    }
    
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

sub db2Xml
{
    my %opts = @_;
    my ($cfg, $dbh) = init();
    
    if(!defined $opts{table} || $opts{table} eq "")
    {
        die "No Table given.";
    }
    if(!defined $opts{outfile} || $opts{outfile} eq "")
    {
        die "No filename given.";
    }
    my $columstr = join ( ', ', @{$opts{columns}} ); 
    my $dbout = $dbh->selectall_arrayref("SELECT $columstr from ".$opts{table} , { Slice => {} });

    my $output = new IO::File("> ".$opts{outfile});
    if(!defined $output)
    {
        die "Cannot open file '.".$opts{outfile}."':$!";
    }
    
    my $writer = new XML::Writer(OUTPUT => $output);

    $writer->xmlDecl("UTF-8");
    $writer->startTag($opts{type}, xmlns => "http://www.novell.com/xml/center/regsvc-1_0");

    foreach my $row (@{$dbout})
    {
        if ( defined $opts{row_handler} )
        {
            &{$opts{row_handler}}($writer,$row);
        }
        else
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
    }
    $writer->endTag($opts{type});
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

    my $subhash = {};
    
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

        $subhash->{$product_class}->{NODECOUNT_ACTIVE}  = 0;
        $subhash->{$product_class}->{NODECOUNT_EXPSOON} = 0;
        $subhash->{$product_class}->{ASSIGNEDMACHINES}  = 0;
        $subhash->{$product_class}->{ASSIGNEDMACHINES_ACTIVE}  = 0;
        $subhash->{$product_class}->{ASSIGNEDMACHINES_EXPSOON}  = 0;
        $subhash->{$product_class}->{VMCOUNT_TOTAL}     = 0;
        $subhash->{$product_class}->{VMCOUNT}           = 0;
        $subhash->{$product_class}->{MACHINES_LEFT}     = 0;
    }

    $statement = "select PRODUCT_CLASS, SUM(NODECOUNT) as NODECOUNT_ACTIVE, MIN(NODECOUNT) = -1 as UNLIMITED_ACTIVE, MIN(SUBENDDATE) as MINDATE from Subscriptions where SUBSTATUS = 'ACTIVE' and (SUBENDDATE > ? or SUBENDDATE IS NULL) group by PRODUCT_CLASS;";
    $sth = $dbh->prepare($statement);
    $sth->bind_param(1, $nowP30day, SQL_TIMESTAMP);
    $sth->execute;
    $res = $sth->fetchall_arrayref({});

    printLog($options{log}, $vblevel, LOG_DEBUG, "STATEMENT: $statement");

    foreach my $node (@{$res})
    {
        $subhash->{$node->{PRODUCT_CLASS}}->{NODECOUNT_ACTIVE} = int($node->{NODECOUNT_ACTIVE});
        $subhash->{$node->{PRODUCT_CLASS}}->{MINDATE_ACTIVE} = ((defined $node->{MINDATE})?"$node->{MINDATE}":"never");
        $subhash->{$node->{PRODUCT_CLASS}}->{UNLIMITED_ACTIVE} = $node->{UNLIMITED_ACTIVE};
    }

    $statement  = "select PRODUCT_CLASS, SUM(NODECOUNT) as NODECOUNT_EXPSOON, MIN(NODECOUNT) = -1 as UNLIMITED_EXPSOON, MIN(SUBENDDATE) as MINDATE ";
    $statement .= "from Subscriptions where SUBSTATUS = 'ACTIVE' and SUBENDDATE <= ? and SUBENDDATE > ?";
    $statement .= "group by PRODUCT_CLASS;";
    $sth = $dbh->prepare($statement);
    $sth->bind_param(1, $nowP30day, SQL_TIMESTAMP);
    $sth->bind_param(2, $now, SQL_TIMESTAMP);
    $sth->execute;
    $res = $sth->fetchall_arrayref({});

    printLog($options{log}, $vblevel, LOG_DEBUG, "STATEMENT: $statement");

    foreach my $node (@{$res})
    {
        $subhash->{$node->{PRODUCT_CLASS}}->{NODECOUNT_EXPSOON} = int($node->{NODECOUNT_EXPSOON});
        $subhash->{$node->{PRODUCT_CLASS}}->{MINDATE_EXPSOON} = ((defined $node->{MINDATE})?"$node->{MINDATE}":"never");
        $subhash->{$node->{PRODUCT_CLASS}}->{UNLIMITED_EXPSOON} = $node->{UNLIMITED_EXPSOON};
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

        if(!exists $calchash->{$set->{PRODUCT_CLASS}})
        {
            $calchash->{$set->{PRODUCT_CLASS}}->{VMCOUNT}       = 0;
            $calchash->{$set->{PRODUCT_CLASS}}->{VMCOUNT_TOTAL} = 0;
            $calchash->{$set->{PRODUCT_CLASS}}->{MACHINES_LEFT} = 0;
            $calchash->{$set->{PRODUCT_CLASS}}->{TOTMACHINES}   = 0;
        }
        
        $statement = sprintf("select VALUE from MachineData where GUID='%s' and KEYNAME='host';", $set->{GUID});
        my $arr = $dbh->selectcol_arrayref($statement);
        
        if( exists $arr->[0] && defined $arr->[0] && $arr->[0] ne "")
        {
            #
            # this is a VM, count it
            #
            $calchash->{$set->{PRODUCT_CLASS}}->{VMCOUNT} += 1;
            $calchash->{$set->{PRODUCT_CLASS}}->{VMCOUNT_TOTAL} += 1;

            next;
        }
        $dhash->{$key} = $set;
        
        #
        # count the machines which need a subscription
        #
        $calchash->{$set->{PRODUCT_CLASS}}->{MACHINES_LEFT} += 1;
        $calchash->{$set->{PRODUCT_CLASS}}->{TOTMACHINES}   += 1;
    }
    
    printLog($options{log}, $vblevel, LOG_DEBUG, "SUBSCRIPTION HASH");
    printLog($options{log}, $vblevel, LOG_DEBUG, Data::Dumper->Dump([$subhash]));
    printLog($options{log}, $vblevel, LOG_DEBUG, "CALC HASH");
    printLog($options{log}, $vblevel, LOG_DEBUG, Data::Dumper->Dump([$calchash]));

    foreach my $subprodclass (keys %{$subhash})
    {
        # multi class in the second iteration
        next if($subprodclass =~ /,/);

        if(exists $calchash->{$subprodclass} && $calchash->{$subprodclass}->{MACHINES_LEFT} > 0 &&
           ( $subhash->{$subprodclass}->{ASSIGNEDMACHINES} < ($subhash->{$subprodclass}->{NODECOUNT_ACTIVE} + $subhash->{$subprodclass}->{NODECOUNT_EXPSOON}) ||
             $subhash->{$subprodclass}->{UNLIMITED_ACTIVE} || $subhash->{$subprodclass}->{UNLIMITED_EXPSOON})
          )
        {
            # we have not assigned machines and the subscription has free nodecounts

            my $free = ($subhash->{$subprodclass}->{NODECOUNT_ACTIVE} + $subhash->{$subprodclass}->{NODECOUNT_EXPSOON}) - $subhash->{$subprodclass}->{ASSIGNEDMACHINES};

            if( $free >= $calchash->{$subprodclass}->{MACHINES_LEFT} ||
                $subhash->{$subprodclass}->{UNLIMITED_ACTIVE}  ||
                $subhash->{$subprodclass}->{UNLIMITED_EXPSOON} )
            {
                # we have more (or equal) free subscriptions left then registered maschines to assign
                # => we can assign all machines to this subscription

                $subhash->{$subprodclass}->{ASSIGNEDMACHINES} += $calchash->{$subprodclass}->{MACHINES_LEFT};
                $calchash->{$subprodclass}->{MACHINES_LEFT} = 0;
            }
            elsif ( $free > 0 )
            {
                # we have free subscriptions, but not enough to assign them all

                $subhash->{$subprodclass}->{ASSIGNEDMACHINES} += $free;
                $calchash->{$subprodclass}->{MACHINES_LEFT}   -= $free;
            }
        }
    }

    printLog($options{log}, $vblevel, LOG_DEBUG, "SUBSCRIPTION HASH");
    printLog($options{log}, $vblevel, LOG_DEBUG, Data::Dumper->Dump([$subhash]));
    printLog($options{log}, $vblevel, LOG_DEBUG, "CALC HASH");
    printLog($options{log}, $vblevel, LOG_DEBUG, Data::Dumper->Dump([$calchash]));

    foreach my $subprodclass (keys %{$subhash})
    {
        # all single product class subscriptions are finished
        # concentrate on multi product class subscriptions now
        next if($subprodclass !~ /,/);

        my @prodclasses = split(/,/, $subprodclass);

        foreach my $pc (@prodclasses)
        {
            if(exists $calchash->{$pc} && $calchash->{$pc}->{MACHINES_LEFT} > 0 &&
               ( $subhash->{$subprodclass}->{ASSIGNEDMACHINES} < ($subhash->{$subprodclass}->{NODECOUNT_ACTIVE} + $subhash->{$subprodclass}->{NODECOUNT_EXPSOON}) ||
                 $subhash->{$subprodclass}->{UNLIMITED_ACTIVE} || $subhash->{$subprodclass}->{UNLIMITED_EXPSOON} )
              )
            {
                # we have not assigned machines and the subscription has free nodecounts

                my $free = ($subhash->{$subprodclass}->{NODECOUNT_ACTIVE} + $subhash->{$subprodclass}->{NODECOUNT_EXPSOON}) - $subhash->{$subprodclass}->{ASSIGNEDMACHINES};

                if( $free >= $calchash->{$pc}->{MACHINES_LEFT} || 
                    $subhash->{$subprodclass}->{UNLIMITED_ACTIVE} || 
                    $subhash->{$subprodclass}->{UNLIMITED_EXPSOON} )
                {
                    # we have more (or equal) free subscriptions left then registered maschines to assign
                    # => we can assign all machines to this subscription

                    $subhash->{$subprodclass}->{ASSIGNEDMACHINES} += $calchash->{$pc}->{MACHINES_LEFT};
                    $calchash->{$pc}->{MACHINES_LEFT} = 0;
                }
                elsif ( $free > 0 )
                {
                    # we have free subscriptions, but not enough to assign them all

                    $subhash->{$subprodclass}->{ASSIGNEDMACHINES} += $free;
                    $calchash->{$pc}->{MACHINES_LEFT}   -= $free;
                }
            }
        }
    }

    printLog($options{log}, $vblevel, LOG_DEBUG, "SUBSCRIPTION HASH");
    printLog($options{log}, $vblevel, LOG_DEBUG, Data::Dumper->Dump([$subhash]));
    printLog($options{log}, $vblevel, LOG_DEBUG, "CALC HASH");
    printLog($options{log}, $vblevel, LOG_DEBUG, Data::Dumper->Dump([$calchash]));

    # search now for left registrations and virtual machines

    foreach my $pc_string (keys %{$calchash})
    {
        if(exists $subhash->{$pc_string} && defined $calchash->{$pc_string}->{VMCOUNT} &&
           int($calchash->{$pc_string}->{VMCOUNT}) > 0)
        {
            $subhash->{$pc_string}->{VMCOUNT} = $calchash->{$pc_string}->{VMCOUNT};
            $subhash->{$pc_string}->{VMCOUNT_TOTAL} = $calchash->{$pc_string}->{VMCOUNT_TOTAL};
        }

        if(exists $subhash->{$pc_string} && defined $calchash->{$pc_string}->{MACHINES_LEFT} &&
           int($calchash->{$pc_string}->{MACHINES_LEFT}) > 0)
        {
            $subhash->{$pc_string}->{MACHINES_LEFT} = $calchash->{$pc_string}->{MACHINES_LEFT};
        }

        if(exists $subhash->{$pc_string} && defined $calchash->{$pc_string}->{MACHINES_LEFT} &&
           int($calchash->{$pc_string}->{MACHINES_LEFT}) <= 0)
        {
            delete $calchash->{$pc_string};
        }
    }

    # now the same for multi product class subscriptions

    foreach my $pc_string (keys %{$calchash})
    {
        #next if(!defined $calchash->{$pc_string}->{MACHINES_LEFT} ||
        #        int($calchash->{$pc_string}->{MACHINES_LEFT}) <= 0);

        my $found = 0;

        foreach my $spc (keys %{$subhash})
        {
            next if($spc !~ /,/);

            my @spclasses = split(/,/, $spc);
            foreach my $productclass (@spclasses)
            {
                $found = 1 if($productclass eq $pc_string);
                last;
            }
            if($found == 1)
            {
                if(exists $calchash->{$pc_string} && defined $calchash->{$pc_string}->{VMCOUNT} &&
                   int($calchash->{$pc_string}->{VMCOUNT}) > 0)
                {
                    $subhash->{$spc}->{VMCOUNT} += $calchash->{$pc_string}->{VMCOUNT};
                    $subhash->{$spc}->{VMCOUNT_TOTAL} += $calchash->{$pc_string}->{VMCOUNT_TOTAL};
                }

                $subhash->{$spc}->{MACHINES_LEFT} += $calchash->{$pc_string}->{MACHINES_LEFT};
                delete $calchash->{$pc_string};
                last;
            }
        }
    }

    printLog($options{log}, $vblevel, LOG_DEBUG, "SUBSCRIPTION HASH");
    printLog($options{log}, $vblevel, LOG_DEBUG, Data::Dumper->Dump([$subhash]));
    printLog($options{log}, $vblevel, LOG_DEBUG, "CALC HASH");
    printLog($options{log}, $vblevel, LOG_DEBUG, Data::Dumper->Dump([$calchash]));

    #
    # Active Subscriptions
    #
    
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

    foreach my $pc (keys %{$subhash})
    {
        # skip subscription with a nodecount of 0
        next if($subhash->{$pc}->{NODECOUNT_ACTIVE} == 0);
    
        if( $subhash->{$pc}->{UNLIMITED_ACTIVE} ||
            $subhash->{$pc}->{NODECOUNT_ACTIVE} >= $subhash->{$pc}->{ASSIGNEDMACHINES} )
        {
            # we can assign all machines to this node
            $subhash->{$pc}->{ASSIGNEDMACHINES_ACTIVE} = $subhash->{$pc}->{ASSIGNEDMACHINES};
        }
        elsif( $subhash->{$pc}->{NODECOUNT_ACTIVE} < $subhash->{$pc}->{ASSIGNEDMACHINES} )
        {
            $subhash->{$pc}->{ASSIGNEDMACHINES_ACTIVE} = $subhash->{$pc}->{NODECOUNT_ACTIVE};
        }

        push @AVALUES, [ $subnamesByProductClass->{$pc},
                         (($subhash->{$pc}->{UNLIMITED_ACTIVE})?"unlimited":$subhash->{$pc}->{NODECOUNT_ACTIVE}),
                         ($subhash->{$pc}->{ASSIGNEDMACHINES_ACTIVE} + $subhash->{$pc}->{MACHINES_LEFT}),
                         $subhash->{$pc}->{VMCOUNT},
                         $subhash->{$pc}->{MINDATE_ACTIVE}
                       ];
        if( exists $subhash->{$pc}->{VMCOUNT} && $subhash->{$pc}->{VMCOUNT} > 0)
        {
            # we have them assigned to this subscription, set to 0 now.
            $subhash->{$pc}->{VMCOUNT} = 0;
        }
    }

    $report{'active'} = {'cols' => \@AHEAD, 'vals' => \@AVALUES, 'opts' => \%AOPTIONS };

    #
    # Expire soon
    #
    
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

    foreach my $pc (keys %{$subhash})
    {
        # skip subscription with a nodecount of 0
        next if($subhash->{$pc}->{NODECOUNT_EXPSOON} == 0);

        if( $subhash->{$pc}->{UNLIMITED_EXPSOON} ||
            $subhash->{$pc}->{NODECOUNT_EXPSOON} >= ($subhash->{$pc}->{ASSIGNEDMACHINES} - $subhash->{$pc}->{ASSIGNEDMACHINES_ACTIVE}) )
        {
            # we can assign all machines to this node
            $subhash->{$pc}->{ASSIGNEDMACHINES_EXPSOON} = ($subhash->{$pc}->{ASSIGNEDMACHINES} - $subhash->{$pc}->{ASSIGNEDMACHINES_ACTIVE});
        }
        elsif( $subhash->{$pc}->{NODECOUNT_EXPSOON} < ($subhash->{$pc}->{ASSIGNEDMACHINES} - $subhash->{$pc}->{ASSIGNEDMACHINES_ACTIVE}) )
        {
            $subhash->{$pc}->{ASSIGNEDMACHINES_EXPSOON} = ($subhash->{$pc}->{ASSIGNEDMACHINES} - $subhash->{$pc}->{ASSIGNEDMACHINES_ACTIVE});
        }
        
        next if($subhash->{$pc}->{NODECOUNT_EXPSOON} == 0 && $subhash->{$pc}->{ASSIGNEDMACHINES_EXPSOON} == 0);
        
        push @SVALUES, [ $subnamesByProductClass->{$pc},
                         ($subhash->{$pc}->{UNLIMITED_EXPSOON})?"unlimited":$subhash->{$pc}->{NODECOUNT_EXPSOON},
                         $subhash->{$pc}->{ASSIGNEDMACHINES_EXPSOON},
                         $subhash->{$pc}->{VMCOUNT},
                         $subhash->{$pc}->{MINDATE_EXPSOON}
                       ];
        if( exists $subhash->{$pc}->{VMCOUNT} && $subhash->{$pc}->{VMCOUNT} > 0)
        {
            # we have them assigned to this subscription, set to 0 now.
            $subhash->{$pc}->{VMCOUNT} = 0;
        }
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
                   name  => __("Subscription\nExpires"),
                   align => "auto",
                   id    => "expires"
                  });
    my @EVALUES = ();
    my %EOPTIONS = ( 'headingText' => __("Expired Subscriptions")." ($time)", drawRowLine => 1 );
    
    foreach my $product_class (keys %{$res})
    {
        my $nc =  (int $res->{$product_class}->{SUM_NODECOUNT});

        if($res->{$product_class}->{UNLIMITED})
        {
            $nc = "unlimited";
        }
        
        push @EVALUES, [ $subnamesByProductClass->{$product_class},
                         $nc,
                         $res->{$product_class}->{MAXENDDATE}
                       ];
    }

    $report{'expired'} = (@EVALUES > 0) ? {'cols' => \@EHEAD, 'vals' => \@EVALUES, 'opts' => \%EOPTIONS } : undef; 

    #
    # registrations without subscriptions
    #

    my @RHEAD = ( {
                   name  => __("Product"),
                   align => "auto",
                   id    => "sub"
                  },
                  {
                   name  => __("Registrations"),
                   align => "right",
                   id    => "number"
                  });
    my @RVALUES = ();
    my %ROPTIONS = ( 'headingText' => __("Registered Products without Subscriptions")." ($time)", drawRowLine => 1 );
    
    $statement  = "select p.PRODUCT_CLASS, p.PRODUCT, p.VERSION, p.ARCH, p.REL, count(r.GUID) as NUMBER ";
    $statement .= "from Products p, Registration r where r.PRODUCTID = p.PRODUCTDATAID group by p.PRODUCT_CLASS;";
    $res = $dbh->selectall_hashref($statement, "PRODUCT_CLASS");

    foreach my $product_class (keys %{$res})
    {
        next if(exists $subnamesByProductClass->{$product_class});
        
        my $pname = $res->{$product_class}->{PRODUCT}." ".$res->{$product_class}->{VERSION};
        $pname .= " ".$res->{$product_class}->{ARCH} if(defined $res->{$product_class}->{ARCH} && $res->{$product_class}->{ARCH} ne "");
        $pname .= " ".$res->{$product_class}->{REL} if(defined $res->{$product_class}->{REL} && $res->{$product_class}->{REL} ne "");
        
        push @RVALUES, [ $pname,
                         $res->{$product_class}->{NUMBER}
                       ];
    }

    $report{'wosub'} = (@RVALUES > 0) ? {'cols' => \@RHEAD, 'vals' => \@RVALUES, 'opts' => \%ROPTIONS } : undef; 

    #
    # Summary
    #
    
    my $alerts = ''; 
    my $warning = ''; 

    my @SUMHEAD = ( {
                     name  => __("Subscription Type"), 
                     align => "auto",
                     id    => "subtype"
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
                     name  => __("Over\nLimit"),
                     align => "right",
                     id    => "overlimit"
                    });

    my @SUMVALUES = ();
    my %SUMOPTIONS = ( 'headingText' => __('Summary')." ($time)", drawRowLine => 1 );


    foreach my $product_class (keys %{$subhash})
    {
        push @SUMVALUES, [$subnamesByProductClass->{$product_class},
                          ($subhash->{$product_class}->{UNLIMITED_ACTIVE})?"unlimited":$subhash->{$product_class}->{NODECOUNT_ACTIVE},
                          ($subhash->{$product_class}->{UNLIMITED_EXPSOON})?"unlimited":$subhash->{$product_class}->{NODECOUNT_EXPSOON},
                          $subhash->{$product_class}->{ASSIGNEDMACHINES} + $subhash->{$product_class}->{MACHINES_LEFT},
                          $subhash->{$product_class}->{VMCOUNT_TOTAL},
                          $subhash->{$product_class}->{MACHINES_LEFT}];
        
        if($subhash->{$product_class}->{ASSIGNEDMACHINES_EXPSOON} == 1)
        {
            $warning .= sprintf(__("%d machine use a '%s' subscription, which expires within the next 30 Days. Please renew the subscription.\n"),
                                $subhash->{$product_class}->{ASSIGNEDMACHINES_EXPSOON}, join(" / ", split(/\n/, $subnamesByProductClass->{$product_class})));
        }
        elsif($subhash->{$product_class}->{ASSIGNEDMACHINES_EXPSOON} > 1)
        {
            $warning .= sprintf(__("%d machines use a '%s' subscription, which expires within the next 30 Days. Please renew the subscription.\n"),
                                $subhash->{$product_class}->{ASSIGNEDMACHINES_EXPSOON}, join(" / ", split(/\n/, $subnamesByProductClass->{$product_class})));
        }
        
        if($subhash->{$product_class}->{MACHINES_LEFT} == 1)
        {
            $alerts .= sprintf(__("%d machine use too many '%s' subscriptions. Please log in to the Novell Customer Center (http://www.novell.com/center) and assign or purchase matching entitlements.\n"),
                               $subhash->{$product_class}->{MACHINES_LEFT}, join(" / ", split(/\n/, $subnamesByProductClass->{$product_class})));
        }
        elsif($subhash->{$product_class}->{MACHINES_LEFT} > 1)
        {
            $alerts .= sprintf(__("%d machines use too many '%s' subscriptions. Please log in to the Novell Customer Center (http://www.novell.com/center) and assign or purchase matching entitlements.\n"),
                               $subhash->{$product_class}->{MACHINES_LEFT}, join(" / ", split(/\n/, $subnamesByProductClass->{$product_class})));
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
        $report{'alerts'} .= __("Alerts:\n").$alerts ;
    }
    if($warning ne "")
    {
        $report{'alerts'} .= "\n".__("Warnings:\n").$warning ;
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

    $statement  = "select s.SUBID, COUNT(cs.GUID) as MACHINES from Subscriptions s, ClientSubscriptions cs, MachineData m ";
    $statement .= "where s.SUBID = cs.SUBID and cs.GUID = m.GUID and m.KEYNAME= 'host' and m.VALUE = '' ";
    $statement .= "group by SUBID order by SUBENDDATE";
    my $assigned = $dbh->selectall_hashref($statement, "SUBID");

    printLog($options{log}, $vblevel, LOG_DEBUG, "STATEMENT: $statement DATE: $nowP30day");

    $statement  = "select s.SUBID, COUNT(cs.GUID) as MACHINES from Subscriptions s, ClientSubscriptions cs, MachineData m ";
    $statement .= "where s.SUBID = cs.SUBID and cs.GUID = m.GUID and m.KEYNAME= 'host' and m.VALUE != '' ";
    $statement .= "group by SUBID order by SUBENDDATE";
    my $assignedVirt = $dbh->selectall_hashref($statement, "SUBID");

    printLog($options{log}, $vblevel, LOG_DEBUG, "STATEMENT: $statement DATE: $nowP30day");

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

    foreach my $subid (keys %{$assigned})
    {
        if(exists $res->{$subid})
        {
            $res->{$subid}->{ASSIGNED_MACHINES} = $assigned->{$subid}->{MACHINES};
            delete $assigned->{$subid};
        }
    }

    foreach my $subid (keys %{$assignedVirt})
    {
        if(exists $res->{$subid})
        {
            $res->{$subid}->{ASSIGNED_VIRT_MACHINES} = $assignedVirt->{$subid}->{MACHINES};
            delete $assignedVirt->{$subid};
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
    
    my $skipped = 0;
    
    foreach my $subid (keys %{$res})
    {
        my $nc = (int $res->{$subid}->{NODECOUNT});
        my $subname = $res->{$subid}->{SUBNAME};
        my $product_class = $res->{$subid}->{PRODUCT_CLASS};

        #
        # let us skip all subscriptions with nodecount = 0 and no machines assigned to it.
        #
        if($nc == 0 && $res->{$subid}->{CONSUMED} == 0 && $res->{$subid}->{CONSUMEDVIRT} == 0)
        {
            $skipped++;
            next;
        }
        
        
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

    printLog($options{log}, $vblevel, LOG_DEBUG,  "ACTIVE skipped $skipped");

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

    foreach my $subid (keys %{$assigned})
    {
        if(exists $res->{$subid})
        {
            $res->{$subid}->{ASSIGNED_MACHINES} = $assigned->{$subid}->{MACHINES};
            delete $assigned->{$subid};
        }
    }

    foreach my $subid (keys %{$assignedVirt})
    {
        if(exists $res->{$subid})
        {
            $res->{$subid}->{ASSIGNED_VIRT_MACHINES} = $assignedVirt->{$subid}->{MACHINES};
            delete $assignedVirt->{$subid};
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

    $skipped = 0;

    foreach my $subid (keys %{$res})
    {
        my $nc = (int $res->{$subid}->{NODECOUNT});
        my $subname = $res->{$subid}->{SUBNAME};
        my $product_class = $res->{$subid}->{PRODUCT_CLASS};

        #
        # let us skip all subscriptions with nodecount = 0 and no machines assigned to it.
        #
        if($nc == 0 && $res->{$subid}->{CONSUMED} == 0 && $res->{$subid}->{CONSUMEDVIRT} == 0)
        {
            $skipped++;
            next;
        }
        
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

    printLog($options{log}, $vblevel, LOG_DEBUG, "EXPIRE SOON skipped $skipped");

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
    
    foreach my $subid (keys %{$assigned})
    {
        if(exists $res->{$subid})
        {
            $res->{$subid}->{ASSIGNED_MACHINES} = $assigned->{$subid}->{MACHINES};
            delete $assigned->{$subid};
        }
    }

    foreach my $subid (keys %{$assignedVirt})
    {
        if(exists $res->{$subid})
        {
            $res->{$subid}->{ASSIGNED_VIRT_MACHINES} = $assignedVirt->{$subid}->{MACHINES};
            delete $assignedVirt->{$subid};
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
    
    $skipped = 0;

    foreach my $subid (keys %{$res})
    {
        my $nc = (int $res->{$subid}->{NODECOUNT});
        my $subname = $res->{$subid}->{SUBNAME};

        #
        # let us skip all subscriptions with nodecount = 0 and no machines assigned to it.
        #
        if($nc == 0 && $res->{$subid}->{CONSUMED} == 0 && $res->{$subid}->{CONSUMEDVIRT} == 0)
        {
            $skipped++;
            next;
        }
        
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
    printLog($options{log}, $vblevel, LOG_DEBUG, "EXPIRED skipped $skipped");

    $report{'expired'} = (@EVALUES > 0) ? {'cols' => \@EHEAD, 'vals' => [sort {$a->[0] cmp $b->[0]} @EVALUES], 'opts' => \%EOPTIONS } : undef; 


    #
    # registrations without subscriptions
    #

    my @RHEAD = ( {
                   name  => __("Product"),
                   align => "auto",
                   id    => "sub"
                  },
                  {
                   name  => __("Registrations"),
                   align => "right",
                   id    => "number"
                  });
    my @RVALUES = ();
    my %ROPTIONS = ( 'headingText' => __("Registered Products without Subscriptions")." ($time)", drawRowLine => 1 );
    
    $statement  = "select p.PRODUCT_CLASS, p.PRODUCT, p.VERSION, p.ARCH, p.REL, count(r.GUID) as NUMBER from Products p, Registration r ";
    $statement .= "where r.PRODUCTID = p.PRODUCTDATAID group by p.PRODUCT_CLASS;";
    $res = $dbh->selectall_hashref($statement, "PRODUCT_CLASS");

    foreach my $product_class (keys %{$res})
    {
        next if(exists $subnamesByProductClass->{$product_class});
        
        my $pname = $res->{$product_class}->{PRODUCT}." ".$res->{$product_class}->{VERSION};
        $pname .= " ".$res->{$product_class}->{ARCH} if(defined $res->{$product_class}->{ARCH} && $res->{$product_class}->{ARCH} ne "");
        $pname .= " ".$res->{$product_class}->{REL} if(defined $res->{$product_class}->{REL} && $res->{$product_class}->{REL} ne "");
        
        push @RVALUES, [ $pname,
                         $res->{$product_class}->{NUMBER}
                       ];
    }

    $report{'wosub'} = (@RVALUES > 0) ? {'cols' => \@RHEAD, 'vals' => \@RVALUES, 'opts' => \%ROPTIONS } : undef; 


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
                     name  => __("Over\nLimit"),
                     align => "right",
                     id    => "overlimit"
                    });
    my @SUMVALUES = ();
    my %SUMOPTIONS = ( 'headingText' => __('Summary')." ($time)", drawRowLine => 1 );

    $skipped = 0;
    foreach my $product_class (keys %{$calchash})
    {
        #
        # let us skip all subscriptions with nodecount = 0 and no machines assigned to it.
        #
        if($calchash->{$product_class}->{SUM_ACTIVE_SUB} == 0 && $calchash->{$product_class}->{SUM_ESOON_SUB} == 0 && 
           $calchash->{$product_class}->{TOTMACHINES} == 0 && $calchash->{$product_class}->{TOTMACHINESVIRT} == 0)
        {
            $skipped++;
            next;
        }
        
        my $missing = $calchash->{$product_class}->{TOTMACHINES} - $calchash->{$product_class}->{SUM_ACTIVE_SUB} - $calchash->{$product_class}->{SUM_ESOON_SUB};

        if($calchash->{$product_class}->{SUM_ACTIVE_SUB} == -1 ||
           $calchash->{$product_class}->{SUM_ESOON_SUB}  == -1)
        {
            $missing = 0;
        }
        
        $missing = 0 if ($missing < 0);
        
        push @SUMVALUES, [$subnamesByProductClass->{$product_class}, 
                          ($calchash->{$product_class}->{SUM_ACTIVE_SUB}==-1)?"unlimited":$calchash->{$product_class}->{SUM_ACTIVE_SUB}, 
                          ($calchash->{$product_class}->{SUM_ESOON_SUB}==-1)?"unlimited":$calchash->{$product_class}->{SUM_ESOON_SUB}, 
                          $calchash->{$product_class}->{TOTMACHINES}, 
                          $calchash->{$product_class}->{TOTMACHINESVIRT}, 
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

    printLog($options{log}, $vblevel, LOG_DEBUG, "SUMMARY skipped $skipped");

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

=back

=head1 AUTHOR

dmacvicar@suse.de

=head1 COPYRIGHT

Copyright 2007, 2008 SUSE LINUX Products GmbH, Nuernberg, Germany.

=cut

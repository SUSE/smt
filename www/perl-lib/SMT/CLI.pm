# let's rename this module to SMT::Common (it's already used by YaST, too),
# or even split it into several (it's ~3000 lines already) e.g. SMT::Common,
# SMT::Common::Repos, SMT::Common::CLI, SMT::Command::Reports etc.

package SMT::CLI;
use strict;
use warnings;

use URI;
use SMT::Utils;
use SMT::DB;
use Text::ASCIITable;
use Config::IniFiles;
use File::Temp;
use File::Path;
use File::Copy;
use IO::File;

use XML::Writer;
#use Data::Dumper;

use File::Basename;
use Digest::SHA1  qw(sha1 sha1_hex);
use Time::HiRes qw(gettimeofday tv_interval);

use CaMgm;

use Locale::gettext ();
use POSIX ();     # Needed for setlocale()


=head1 NAME

 SMT::CLI - SMT common actions for command line programs

=head1 SYNOPSIS

  SMT::listProducts();
  SMT::listRepositories();
  SMT::setupCustomRepo();

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

sub getRepositories
{
    my %options = @_;

    my ($cfg, $dbh) = init();
    my $sth = $dbh->prepare("select * from Repositories");
    $sth->execute();

    my @HEAD = ();
    my @VALUES = ();

    push( @HEAD, "Name" );
    push( @HEAD, "Description" );

    push( @HEAD, "Mirrorable" );
    push( @HEAD, "Mirror?" );

    while (my $values = $sth->fetchrow_hashref())
    {
        next if ($options{mirrorable} && $values->{mirrorable} ne "Y");
        next if ($options{domirror} && $values->{domirror} ne "Y");
        next if ($options{name} && $values->{name} ne $options{name});

        my @row;
        push( @row, $values->{name} );
        push( @row, $values->{description} );
        push( @row, $values->{mirrorable} );
        push( @row, $values->{domirror} );
        push( @VALUES, @row );

        if ( exists $options{ used } && defined $options{used} )
        {
          push( @VALUES, ("", $values->{exturl},      "", "") );
          push( @VALUES, ("", $values->{localpath},   "", "") );
          push( @VALUES, ("", $values->{repotype}, "", "") );
        }
    }
    $sth->finish();
    return {'cols' => \@HEAD, 'vals' => \@VALUES };
}

#
# wrapper function to keep compatibility while changing the called function
#
sub listRepositories
{
    print renderReport(getRepositories(@_), 'asciitable', '');
}


sub getProducts
{
    my %options = @_;
    my ($cfg, $dbh) = init();

    my $sth = $dbh->prepare("SELECT p.*,
                                    0+(SELECT count(r.guid)
                                         FROM Products p2
                                         JOIN Registrations r
                                        WHERE r.productid = p2.id
                                          AND p2.id = p.id) AS registered_machines
                             FROM Products p
                             ORDER BY product,version,rel,arch");

    $sth->execute();

    my @HEAD = ( __('ID'), __('Name'), __('Version'), __('Architecture'), __('Release'), __('Usage') );
    my @VALUES = ();

    if($options{catstat})
    {
        push @HEAD,  __('Repos mirrored?');
    }
    my $ststat = $dbh->prepare("SELECT DISTINCT rp.domirror
                                  FROM ProductRepositories pr
                                  JOIN Repositories rp ON rp.id = pr.repository_id
                                 WHERE pc.product_id = :pdid");

    while (my $value = $sth->fetchrow_hashref())  # keep fetching until
                                                  # there's nothing left
    {
        next if ($options{used} && int($value->{registered_machines}) < 1);

        if($options{catstat})
        {
            $ststat->execute_h(pdid => $value->{ID});
            my $arr = $dbh->fetchall_arrayref();
            my $cm = __("No");

            if( @{$arr} == 0 )
            {
                # no repositories required for this product => all repositories available
                $cm = __("Yes");
            }
            elsif( @{$arr} == 1 )
            {
                if( uc($arr->[0]->[0]) eq "Y")
                {
                    # all repositories available
                    $cm = __("Yes");
                }
                # else default is NO
            }
            # else some are available, some not => not all repositories available


            push @VALUES, [ $value->{id},
                            $value->{product},
                            $value->{version} || "-",
                            $value->{arch}    || "-",
                            $value->{rel}     || "-",
                            $value->{registered_machines},
                            $cm ];
        }
        else
        {
            push @VALUES, [ $value->{id},
                            $value->{product},
                            $value->{version} || "-",
                            $value->{arch}    || "-",
                            $value->{rel}     || "-",
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

    my $sth = $dbh->prepare("SELECT c.guid,
                                    c.hostname,
                                    c.lastcontact,
                                    p.product,
                                    p.version,
                                    p.rel,
                                    p.arch
                               FROM Clients c
                               JOIN Registrations r ON c.id = r.client_id
                               JOIN Products p ON r.product_id = p.id
                           ORDER BY guid, lastcontact, product, version, rel, arch");
    $sth->execute();
    my $clients = $dbh->fetchall_arrayref({Slice => {}});

    my @HEAD = ( __('Unique ID'), __('Hostname'), __('Last Contact'), __('Product') );
    my @VALUES = ();
    my %OPTIONS = ('drawRowLine' => 1 );

    my $lastguid = "";
    my $lasthostname = "";
    my $lastcontact = "";
    my $prdstr = "";
    foreach my $clnt (@{$clients})
    {
        if ($lastguid && $lastguid ne $clnt->{guid})
        {
            push @VALUES, [ $lastguid, $lasthostname, $lastcontact, $prdstr ];
            $prdstr = "";
        }
        $lastguid = $clnt->{guid};
        $lasthostname = $clnt->{hostname};
        $lastcontact = $clnt->{lastcontact};
        $prdstr .=     $product->{product} if($product->{product});
        $prdstr .= " ".$product->{version} if($product->{version});
        $prdstr .= " ".$product->{rel}     if($product->{rel});
        $prdstr .= " ".$product->{arch}    if($product->{arch});
        $prdstr .= "\n";
    }
    push @VALUES, [ $lastguid, $lasthostname, $lastcontact, $prdstr ];
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
        my $sth_products = $dbh->prepare("SELECT p.product, p.version, p.rel, p.arch,
                                                 r.regdate, r.sccregdate, r.sccregerror
                                            FROM Registration r
                                            JOIN Products p ON r.product_id = p.id
                                           WHERE r.id = :cid");

        my $sth_sub = $dbh->prepare("SELECT s.subname, s.regcode, s.substatus,
                                            s.subenddate, s.nodecount, s.consumed,
                                            s.consumedvirt
                                       FROM ClientSubscriptions cs
                                       JOIN Subscriptions s ON cs.subscription_id = s.id
                                      WHERE cs.id = :cid");

        my $sth = $dbh->prepare("SELECT c.id,
                                        c.guid,
                                        c.hostname,
                                        c.lastcontact
                                   FROM Clients c
                               ORDER BY lastcontact");
        $sth->execute();
        my $clients = $dbh->fetchall_arrayref({Slice => {}});

        foreach my $clnt (@{$clients})
        {
            print __('Unique ID')." : $clnt->{guid}\n";
            print __('Hostname')." : $clnt->{hostname}\n";
            print __('Last Contact')." : $clnt->{lastcontact}\n";
            $sth_products->execute_h(cid => $clnt->{id});
            my $products = $sth_products->fecthall_arrayref({Slice => {}});
            foreach my $product (@{$products})
            {
                $prdstr  =     $product->{product} if($product->{product});
                $prdstr .= " ".$product->{version} if($product->{version});
                $prdstr .= " ".$product->{rel}     if($product->{rel});
                $prdstr .= " ".$product->{arch}    if($product->{arch});

                print __('Product')." : $prdstr\n" if($prdstr ne "");
                print "        ".__('Local Registration Date')." : $product->{regdate}\n";
                print "        ".__('SCC Registration Date')." : ".(($product->{sccregdate})?$product->{sccregdate}:"")."\n";
                if ($product->{sccregerror})
                {
                    print "        ".__('SCC Registration Errors')." : YES\n";
                }
            }
            $sth_sub->execute_h(cid => $clnt->{id});
            my $subscr = $sth_sub->fetchall_arrayref({Slice => {}});

            foreach my $sub (@{$subscr})
            {
                print  __("Subscription")." : ".$sub->{subname}."\n";
                print  "        ".__("Activation Code")." : ".$sub->{regcode}."\n";
                print  "        ".__("Status")." : ".$sub->{substatus}."\n";
                print  "        ".__("Expiration Date")." : ".(($sub->{subenddate})?"$sub->{subenddate}":"")."\n";
                print  "        ".__("Purchase Count/Used/Used Virtual")." : ".
                           $sub->{nodecount}."/".$sub->{consumed}."/".$sub->{consumedvirt}."\n";
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


sub setReposByProduct
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

    my $st1 = sprintf("SELECT id
                         FROM Products
                        WHERE product=%s ", $dbh->quote($product));
    $st1 .= sprintf("     AND version=%s ", $dbh->quote($version)) if($version);
    $st1 .= sprintf("     AND arch=%s ", $dbh->quote($arch)) if($arch);
    $st1 .= sprintf("     AND rel=%s ", $dbh->quote($release)) if($release);

    my $arr = $dbh->selectall_arrayref($st1, {Slice => {}});
    if(@{$arr} == 0)
    {
        print sprintf(__("Error: Product (%s) not found.\n"),$opts{prodStr});
        return 1;
    }

    my $statement = "SELECT DISTINCT pr.repository_id,
                                     rp.name,
                                     rp.target,
                                     rp.mirrorable,
                                     rp.domirror
                                FROM ProductRepositories pr
                                JOIN Repositories rp ON pr.repository_id = rp.id
                               WHERE pr.product_id IN ($st1)
                            ORDER BY name,target";

    $arr = $dbh->selectall_arrayref($statement, {Slice => {}});

    foreach my $row (@{$arr})
    {
        next if($enable && $row->{domirror} eq "Y");
        next if(!$enable && $row->{domirror} eq "N");

        if($enable && $row->{mirrorable} ne "Y")
        {
            print sprintf(__("Repository [%s %s] cannot be enabled. Access on the server denied.\n"),
                          $row->{name},
                          ($row->{target}) ? $row->{target} : "");
        }
        else
        {
            SMT::CLI::setRepositoryDoMirror(enabled => $enable, name => $row->{name}, target => $row->{target});
            print sprintf(__("Repository [%s %s] %s.\n"),
                          $row->{name},
                          ($row->{target}) ? $row->{target} : "",
                          ($enable?__("enabled"):__("disabled")));
        }
    }
    return 0;
}

sub resetRepoStatus
{
    my ($cfg, $dbh) = init();

    $dbh->do("UPDATE Repositories SET mirrorable='N' WHERE repotype='nu'");
    $dbh->commit();
}

sub deleteRepositories
{
    my %opt = @_;
    my ($cfg, $dbh) = init();
    my $basepath = $cfg->val("LOCAL", "MirrorTo");

    my $sql =     "SELECT id, name, target, domirror, localpath
                     FROM Repositories
                    WHERE 1 ";
    $sql .= sprintf(" AND name = %s ", $dbh->quote($opt{name})) if($opt{name});
    $sql .= sprintf(" AND target = %s ", $dbh->quote($opt{target})) if($opt{target});
    $sql .= sprintf(" AND id = %s ", $dbh->quote($opt{id})) if($opt{id});

    my $ref = $dbh->selectall_arrayref($sql, {Slice => {}});

    my $sth_rcdata = $dbh->prepare("DELETE FROM RepositoryContentData WHERE localpath like :localpath");
    my $sth_repo = $dbh->prepare("UPDATE Repositories SET last_mirror = '' WHERE id = :rid");
    foreach my $row (@{$ref})
    {
        if ( $row->{domirror} eq "Y" )
        {
            print "Repository ".$row->{name}."/".$row->{target}." is enabled for mirroring. Skip delete.\n";
            next;
        }
        my $localpath = $row->{localpath};
        my $fullrepopath = SMT::Utils::cleanPath( $basepath, 'repo', $localpath );

        print sprintf(__("Delete repository '%s'? (y/N) "), $fullrepopath);
        my $answer = <STDIN>;
        chomp($answer);
        if ( lc($answer) ne "y" )
        {
            print "Skipped\n";
            next;
        }

        $sth_rcdata->do_h(localpath => "$fullrepopath/%");
        $sth_repo->do_h(rid => $row->{ID});
        rmtree("$fullrepopath", 0, 0) if (-d "$fullrepopath");
        print "Repository ".$row->{NAME}."/".$row->{TARGET}." successfully deleted.\n";
    }
    $dbh->commit();
    return 0;
}


=item setRepositoyDoMirror

Set the repository mirror flag to enabled or disabled.

Pass id => foo to select the repository.
Pass enabled => 1 or enabled => 0;
disabled => 1 or disabled => 0 are supported as well.

Returns the number of rows changed.

 TODO: move to SMT::Common::Repos
 TODO: use SMT::Repositories::changeRepoStatus() (adjusted) to write to DB to
       avoid code duplication. (BTW, it may be in SMT::DB::Repos in the future)

=cut

sub setRepositoryDoMirror
{
    my %opt = @_;
    my ($cfg, $dbh) = init();

    if(defined $opt{enabled})
    {
        my $sql .= sprintf("UPDATE Repositories
                               SET domirror = %s
                             WHERE 1",
                            $dbh->quote(  $opt{enabled} ? "Y" : "N" ) );

        # allow enable mirroring only if the repository is mirrorable
        # but disabling is allowed if the repository is not mirrorable
        # See bnc#619314
        $sql .=         " and mirrorable = 'Y'" if($opt{enabled});
        $sql .= sprintf(" and name = %s", $dbh->quote($opt{name})) if($opt{name});
        $sql .= sprintf(" and target = %s", $dbh->quote($opt{target})) if($opt{target});
        $sql .= sprintf(" and id = %s", $dbh->quote($opt{id})) if($opt{id});

        my $rows = $dbh->do($sql);
        $rows = 0 if(!$rows || $rows = "0E0");
        $dbh->commit();
        return $rows;
    }
    else
    {
        die __("enabled option missing");
    }
    return 0;
}

sub _getSCCRepoList
{
    my %opt = @_;
    my $indexfile = "";

    my $sccsync = SMT::SCCSync->new(vblevel => $opt{vblevel},
                                   log      => $opt{log},
                                   fromdir  => $opt{fromdir},
                                   todir    => $opt{todir},
                                   dbh      => $opt{dbh}
    );
    $sccsync->finalize_mirrorable_repos();
}

sub setMirrorableRepos
{
    my %opt = @_;
    my ($cfg, $dbh) = ();

    _getSCCRepoList(%opt, dbh => $dbh, cfg => $cfg);

    return if($opt{todir});

    my $mirrorable_idx = undef;

    my $useragent = SMT::Utils::createUserAgent(log => $opt{log}, vblevel => $opt{vblevel});
    my $sth = $dbh->prepare("SELECT id, name, localpath, exturl, target
                               FROM Repositories
                              WHERE repotype = 'zypp'";
    $sth->execute();
    my $values = $dbh->fetchall_arrayref({Slice => {}});

    my $sth_updrepos = $dbh->prepare("UPDATE Repositories
                                         SET mirrorable = :mirrorable
                                       WHERE name = :name
                                         AND target = :target
                                         AND repotype = 'zypp'");
    foreach my $v (@{$values})
    {
        my $catId = $v->{id};
        my $catName = $v->{name};
        my $catLocal = $v->{localpath};
        my $catUrl = $v->{exturl};
        my $catTarget = $v->{target};
        if($catUrl && $catLocal)
        {
            my $ret = 0;
            if($opt{fromdir} && -d $opt{fromdir})
            {
                #FIXME: check if file exists on disk!

                $ret = 1;
            }
            else
            {
                $ret = isZyppMirrorable( log        => $opt{log},
                                         vblevel    => $opt{vblevel},
                                         repourl    => $catUrl);
            }
            printLog($opt{log}, $opt{vblevel}, LOG_DEBUG, sprintf(__("* set [%s] as%s mirrorable."), $catName, ( ($ret == 1) ? '' : ' not' )));
            $sth_updrepos->execute_h(mirrorable => (($ret == 1)?"Y":"N"),
                                     name => $catName,
                                     target => $catTarget);
        }
    }

    my $mirrorAll = $cfg->val("LOCAL", "MirrorAll");
    chomp($mirrorAll);
    if(defined $mirrorAll && lc($mirrorAll) eq "true")
    {
        # set DOMIRROR to Y where MIRRORABLE = Y
        $dbh->do("UPDATE Repositories SET domirror = 'Y' WHERE mirrorable = 'Y'");
    }
    $dbh->commit();
}

# returns true if the repository is an RPMMD repo
sub isZyppMirrorable
{
    my %opt = @_;

    my $useragent = SMT::Utils::createUserAgent(
                        log => $opt{log}, vblevel => $opt{vblevel});
    my $remote = SMT::Utils::appendPathToURI($opt{repourl}, "repodata/repomd.xml");

    return SMT::Utils::doesFileExist($useragent, $remote);
}

sub removeCustomRepo
{
    my %options = @_;
    my ($cfg, $dbh) = init();

    # delete existing repository with this id

    my $affected1 = $dbh->do(sprintf("DELETE from Repositories where id = %s", $dbh->quote($options{repository_id})));

    # FIXME: Not needed? delete cascade ?
    #my $affected2 = $dbh->do(sprintf("DELETE from ProductRepositories where id = %s", $dbh->quote($options{repository_id})));

    $affected1=0 if($affected1 != 1);

    return $affected1;
}

=item setupCustomRepo

modify the database to setup a repository create by the customer

=cut

sub setupCustomRepo
{
    my %options = @_;
    my ($cfg, $dbh) = init();

    # delete existing repository with this id

    removeCustomRepo(%options);

    # now insert it again.
    my $exthost = $options{exturl};
    if($exthost =~ /^(https?:\/\/[^\/]+\/)/)
    {
        $exthost = $1;
    }
    elsif($exthost =~ /^(ftp:\/\/[^\/]+\/)/)
    {
      $exthost = $1;
    }
    elsif($exthost =~ /^file:/)
    {
        $exthost = "file://localhost";
    }
    my $id = $dbh->sequence_nextval('repos_id_seq');
    my $sth = $dbh->prepare("INSERT INTO Repositories (id, repo_id, name, description, target,
                                                       localpath, exthost, exturl, repotype,
                                                       domirror, mirrorable, autorefresh, src)
                             VALUES(:id, :repoid, :name, :desc, :target,
                                    :localpath, :exthost, :exturl, :repotype, :domirror,
                                    :mirrorable, :autorefresh, 'C')");
    my $affected = $sth->execute_h(id => $id, repoid => $options{repository_id}, name => $options{name},
                                   desc => $options{description},
                                   target => $options{target}?$options{target}:'',
                                   localpath => "/RPMMD/".$options{name},
                                   exthost => $exthost, exturl => $options{exturl},
                                   repotype => "zypp", domirror => "Y",
                                   mirrorable => "Y", autorefresh => "Y");

    my $sth_prdrepos = $dbh->prepare("INSERT INTO ProductRepositories (product_id, repository_id, optional, src)
                                      VALUES(:pdid, :rid, 'N', 'C')");
    foreach my $pid (@{$options{productids}})
    {
        $affected += $dbh->do_h(pdid => $pid, rid => $id)
    }
    $dbh->commit();

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

    my $dbout = $dbh->selectall_arrayref("SELECT id, repo_id, name, description, target,
                                          exthost, exturl, localpath, repotype, authtoken
                                          FROM Repositories
                                          WHERE DOMIRROR = 'Y'
                                          ORDER BY repotype, name",
                                         { Slice => {} });

    my $output = new IO::File("> $xmlfile");
    if(!defined $output)
    {
        die "Cannot open file '$xmlfile':$!";
    }

    my $writer = new XML::Writer(OUTPUT => $output);

    $writer->xmlDecl("UTF-8");
    $writer->startTag("repositories", xmlns => "http://www.novell.com/xml/center/regsvc-1_0");

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
    $writer->endTag("repositories");
    $writer->end();
    $output->close();

    return ;
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

    my $certData = CaMgm::LocalManagement::getCertificate($certfile, $CaMgm::E_PEM);

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
Michael Calmer

=head1 COPYRIGHT

Copyright 2007-2014 SUSE LINUX Products GmbH, Nuernberg, Germany.

=cut

package SMT::Registration;

use strict;
use warnings;

use APR::Brigade ();
use APR::Bucket ();
use Apache2::Filter ();

use Apache2::RequestRec ();
use Apache2::RequestIO ();

use Apache2::Const -compile => qw(OK SERVER_ERROR :log MODE_READBYTES);
use APR::Const     -compile => qw(:error SUCCESS BLOCK_READ);

use constant IOBUFSIZE => 8192;

use SMT::Utils;
use DBI qw(:sql_types);

use Data::Dumper;
use DBI;
use XML::Writer;
use XML::Parser;

sub handler {
    my $r = shift;
    
    $r->content_type('text/xml');

    my $args = $r->args();
    my $hargs = {};
    
    if(! defined $args)
    {
        $r->warn("Registration called without args.");
	return Apache2::Const::SERVER_ERROR;
    }

    foreach my $a (split(/\&/, $args))
    {
        chomp($a);
        my ($key, $value) = split(/=/, $a, 2);
        $hargs->{$key} = $value;
    }
    $r->warn("Registration called with command: ".$hargs->{command});
    
    if(exists $hargs->{command} && defined $hargs->{command})
    {
        if($hargs->{command} eq "register")
        {
            SMT::Registration::register($r, $hargs);
        }
        elsif($hargs->{command} eq "listproducts")
        {
            SMT::Registration::listproducts($r, $hargs);
        }
        elsif($hargs->{command} eq "listparams")
        {
            SMT::Registration::listparams($r, $hargs);
        }
        else
        {
            $r->log_error("Unknown command: ".$hargs->{command});
            return Apache2::Const::SERVER_ERROR;
        }
    }
    else
    {
        $r->log_error("Missing command");
        return Apache2::Const::SERVER_ERROR;
    }
    
    return Apache2::Const::OK;
}

#
# called from handler if client wants to register
# command=register argument given
#
sub register
{
    my $r          = shift;
    my $hargs      = shift;

    my $usetestenv = 0;
    
    $r->warn("register called.");

    if(exists $hargs->{testenv} && $hargs->{testenv})
    {
        $usetestenv = 1;
    }
    
    my $data = read_post($r);
    my $dbh = SMT::Utils::db_connect();
    if(!$dbh)
    {
        $r->log_error("Cannot open Database");
        die "Please contact your administrator.";
    }
    
    my $regroot = { ACCEPTOPT => 1, CURRENTELEMENT => "", PRODUCTATTR => {}, register => {}};
    my $regparser = XML::Parser->new( Handlers =>
                                      { Start => sub { reg_handle_start_tag($regroot, @_) },
                                        Char  => sub { reg_handle_char_tag($regroot, @_) },
                                        End   => sub { reg_handle_end_tag($regroot, @_) }
                                      });

    eval {
        $regparser->parse( $data );
    };
    if($@) {
        # ignore the errors, but print them
        chomp($@);
        $r->log_error("SMT::Registration::register Invalid XML: $@");
    }


    my $needinfo = SMT::Registration::parseFromProducts($r, $dbh, $regroot->{register}->{product}, "NEEDINFO");

    #$r->log_error("REGROOT:".Data::Dumper->Dump([$regroot]));

    my $output = "";
    my $writer = XML::Writer->new(NEWLINES => 0, OUTPUT => \$output);
    $writer->xmlDecl("UTF-8");
    
    my $dat = { CACHE => [],
                WRITECACHE => 0,
                INFOCOUNT => 0, 
                REGISTER => $regroot,
                PARAMDEPTH => 0,
                PARAMISMAND => 0,
                R => $r,
                WRITER => $writer
               };
    
    my $parser = XML::Parser->new( Handlers =>
                                   { Start=> sub { nif_handle_start_tag($dat, @_) },
                                     End=>   sub { nif_handle_end_tag($dat, @_) }
                                   });
    eval {
        $parser->parse( $needinfo );
    };
    if($@) {
        # ignore the errors, but print them
        chomp($@);
        $r->log_error("SMT::Registration::register Invalid XML: $@");
    }

    #$r->log_error("INFOCOUNT: ".$dat->{INFOCOUNT});

    if($dat->{INFOCOUNT} > 0)
    {
        $r->warn("Return NEEDINFO: ".$output);
        
        # we need to send the <needinfo>
        print $output;
    }
    else
    {
        # we have all data; store it and send <zmdconfig>

        # get the os-target

        my $target = SMT::Registration::findTarget($r, $dbh, $regroot);

        # insert new registration data

        my $pidarr = SMT::Registration::insertRegistration($r, $dbh, $regroot, $target);

        # get the catalogs

        my $catalogs = SMT::Registration::findCatalogs($r, $dbh, $target, $pidarr);

        # send new <zmdconfig>

        my $zmdconfig = SMT::Registration::buildZmdConfig($r, $regroot->{register}->{guid}, $catalogs, $usetestenv);

        $r->warn("Return ZMDCONFIG: ".$zmdconfig);

        print $zmdconfig;
    }
    $dbh->disconnect();

    return;
}

#
# called from handler if client wants the product list
# command=listproducts argument given
#
sub listproducts
{
    my $r     = shift;
    my $hargs = shift;

    $r->warn("listproducts called.");
    
    my $dbh = SMT::Utils::db_connect();
    if(!$dbh)
    {
        $r->log_error("Cannot connect to database");
        die "Please contact your administrator";
    }
    
    my $sth = $dbh->prepare("SELECT DISTINCT PRODUCT FROM Products where product_list = 'Y'");
    $sth->execute();

    my $output = "";
    my $writer = new XML::Writer(NEWLINES => 1, OUTPUT => \$output);
    $writer->xmlDecl('UTF-8');

    $writer->startTag("productlist",
                      "xmlns" => "http://www.novell.com/xml/center/regsvc-1_0",
                      "lang"  => "en");
    
    while ( my @row = $sth->fetchrow_array ) 
    {
        $writer->startTag("product");
        $writer->characters($row[0]);
        $writer->endTag("product");
    }
    $writer->endTag("productlist");
    
    $r->warn("Return PRODUCTLIST: ".$output);

    print $output;

    $dbh->disconnect();

    return;
}

#
# called from handler if client wants to fetch the parameter list
# command=listparams argument given
#
sub listparams
{
    my $r     = shift;
    my $hargs = shift;

    $r->warn("listparams called.");
    
    my $lpreq = read_post($r);
    my $dbh = SMT::Utils::db_connect();

    my $data  = {STATE => 0, PRODUCTS => []};
    my $parser = XML::Parser->new( Handlers =>
                                   { Start=> sub { prod_handle_start_tag($data, @_) },
                                     Char => sub { prod_handle_char($data, @_) },
                                     End=>   sub { prod_handle_end_tag($data, @_) }
                                   });
    eval {
        $parser->parse( $lpreq );
    };
    if($@) {
        # ignore the errors, but print them
        chomp($@);
        $r->log_error("SMT::Registration::parseFromProducts Invalid XML: $@");
    }
    
    my $xml = SMT::Registration::parseFromProducts($r, $dbh, $data->{PRODUCTS}, "PARAMLIST");
    
    $r->warn("Return PARAMLIST:".$xml);

    print $xml;

    $dbh->disconnect();

    return;
}

###############################################################################

sub parseFromProducts
{
    my $r      = shift;
    my $dbh    = shift;
    my $productarray = shift;
    my $column = shift;
    
    my @list = findColumnsForProducts($r, $dbh, $productarray, $column);

    if(uc($column) eq "PARAMLIST" || uc($column) eq "NEEDINFO")
    {
        return SMT::Registration::mergeDocuments($r, \@list);
    }
    
    return "";
}


sub writeXML
{
    my $node = shift;
    my $writer = shift;

    my $element = ref($node);
    $element =~ s/^smt:://;
    
    return if($element eq "Characters");

    my %attr = %{$node};
    delete $attr{Kids};
    
    $writer->startTag($element, %attr);
    
    foreach my $child (@{$node->{Kids}})
    {
        writeXML($child, $writer);
    }
    
    $writer->endTag($element);
}


sub mergeXML
{
    my $node1 = shift;
    my $node2 = shift;
    
    foreach my $child2 (@{$node2->{Kids}})
    {
        my $found = 0;
        
        foreach my $child1 (@{$node1->{Kids}})
        {
            
            if(ref($child2) eq ref($child1))
            {
                if(ref($child2) eq "smt::param")
                {
                    # we have to match the id
                    if($child2->{id} eq $child1->{id})
                    {
                        $found = 1;
                        mergeXML($child1, $child2);
                    }
                }
                else
                {
                    $found = 1;
                    mergeXML($child1, $child2);
                }
            }
        }
        if(!$found)
        {
            # found something new in child2 - put it in child 1
            push @{$node1->{Kids}}, $child2;
        }
    }
}

sub mergeDocuments
{
    my $r    = shift;
    my $list = shift;
    
    my $basedoc = "";

    my $root1;
    my $node1;
    

    foreach my $other (@$list)
    {
        next if(!defined $other || $other eq "");
        if($basedoc eq "")
        {
            $basedoc = $other;
            my $p1 = XML::Parser->new(Style => 'Objects', Pkg => 'smt');
            eval {
                $root1 = $p1->parse( $basedoc );
                $node1 = $root1->[0];
            };
            if($@) {
                # ignore the errors, but print them
                chomp($@);
                $r->log_error("SMT::Registration::mergeDocuments Invalid XML: $@");
            }
            
            next;
        }
        next if($basedoc eq $other);
        
        my $p2 = XML::Parser->new(Style => 'Objects', Pkg => 'smt');
        eval {
            my $root2 = $p2->parse( $other );
            my $node2;
      
            if(ref($root1->[0]) eq ref($root2->[0]))
            {
                $node1 = $root1->[0];
                $node2 = $root2->[0];
                
                mergeXML($node1, $node2);
            }
        };
        if($@) {
            # ignore the errors, but print them
            chomp($@);
            $r->log_error("SMT::Registration::register Invalid XML: $@");
        }
    }
    
    my $output = "";
    my $w = XML::Writer->new(NEWLINES => 0, OUTPUT => \$output);
    $w->xmlDecl("UTF-8");
    
    writeXML($node1, $w);

    return $output;
}


sub insertRegistration
{
    my $r       = shift;
    my $dbh     = shift;
    my $regdata = shift;
    my $target  = shift || '';
    
    my $cnt     = 0;
    my $existingpids = {};
    my $regtimestring = "";
    my $hostname = "";
    
    my @list = findColumnsForProducts($r, $dbh, $regdata->{register}->{product}, "PRODUCTDATAID");

    my $statement = sprintf("SELECT PRODUCTID from Registration where GUID=%s", $dbh->quote($regdata->{register}->{guid}));
    $r->log_rerror(Apache2::Log::LOG_MARK, Apache2::Const::LOG_INFO,
                   APR::Const::SUCCESS,"STATEMENT: $statement");
    eval {
        $existingpids = $dbh->selectall_hashref($statement, "PRODUCTID");
        
    };
    if($@)
    {
        $r->log_error("DBERROR: ".$dbh->errstr);
    }

    # store the regtime
    $regtimestring = SMT::Utils::getDBTimestamp();

    my @insert = ();
    my @update = ();

    foreach my $pnum (@list)
    {
        if(exists $existingpids->{$pnum})
        {
            # reg exists, do update
            push @update, $pnum;
            delete $existingpids->{$pnum};
        }
        else
        {
            # reg does not exist, do insert
            push @insert, $pnum;
        }
    }
    
    my @delete = keys %{$existingpids};
    
    if(@delete > 0)
    {
        $statement = sprintf("DELETE from Registration where GUID=%s AND PRODUCTID ", $dbh->quote($regdata->{register}->{guid}));
        if(@delete > 1)
        {
            $statement .= "IN (".join(",", @delete).")";
        }
        else
        {
            $statement .= "= ".$delete[0];
        }
        
        eval {
            $cnt = $dbh->do($statement);
            $r->log_rerror(Apache2::Log::LOG_MARK, Apache2::Const::LOG_INFO,
                           APR::Const::SUCCESS,"STATEMENT: $statement  Affected rows: $cnt");
        };
        if($@)
        {
            $r->log_error("DBERROR: ".$dbh->errstr);
        }
    }

    foreach my $id (@insert)
    {
        eval {
            my $sth = $dbh->prepare("INSERT into Registration (GUID, PRODUCTID, REGDATE) VALUES (?, ?, ?)");
            $sth->bind_param(1, $regdata->{register}->{guid});
            $sth->bind_param(2, $id, SQL_INTEGER);
            $sth->bind_param(3, $regtimestring, SQL_TIMESTAMP);
            $cnt = $sth->execute;
            
            $r->log_rerror(Apache2::Log::LOG_MARK, Apache2::Const::LOG_INFO,
                           APR::Const::SUCCESS,"STATEMENT: ".$sth->{Statement}." Affected rows: $cnt");
        };
        if($@)
        {
            $r->log_error("DBERROR: ".$dbh->errstr);
        }
    }

    if(@update > 0)
    {
        $statement = sprintf("UPDATE Registration SET REGDATE=? WHERE GUID=%s AND PRODUCTID ", 
                             $dbh->quote($regtimestring),
                             $dbh->quote($regdata->{register}->{guid})
                            );
        if(@update > 1)
        {
            $statement .= "IN (".join(",", @update).")";
        }
        else
        {
            $statement .= "= ".$update[0];
        }
        
        eval {
            my $sth = $dbh->prepare($statement);
            $sth->bind_param(1, $regtimestring, SQL_TIMESTAMP);
            $cnt = $sth->execute;
            $r->log_rerror(Apache2::Log::LOG_MARK, Apache2::Const::LOG_INFO,
                           APR::Const::SUCCESS,"STATEMENT: ".$sth->{Statement}."  Affected rows: $cnt");
        };
        if($@)
        {
            $r->log_error("DBERROR: ".$dbh->errstr);
        }
    }
    
    
    #
    # clean old machinedata
    #
    $cnt = 0;
    $statement = sprintf("DELETE from MachineData where GUID=%s", $dbh->quote($regdata->{register}->{guid}));
    eval {
        $cnt = $dbh->do($statement);
        $r->log_rerror(Apache2::Log::LOG_MARK, Apache2::Const::LOG_INFO,
                       APR::Const::SUCCESS, "STATEMENT: $statement  Affected rows: $cnt");
    };
    if($@)
    {
        $r->log_error("DBERROR: ".$dbh->errstr);
    }
    
    #
    # insert new machinedata
    #
    foreach my $key (keys %{$regdata->{register}})
    {
        next if($key eq "guid" || $key eq "product" || $key eq "mirrors");
        if($key eq "hostname")
        {
            $hostname = $regdata->{register}->{$key};
        }
        
        my $statement = sprintf("INSERT into MachineData (GUID, KEYNAME, VALUE) VALUES (%s, %s, %s)",
                                $dbh->quote($regdata->{register}->{guid}), 
                                $dbh->quote($key),
                                $dbh->quote($regdata->{register}->{$key}));
        $r->log_rerror(Apache2::Log::LOG_MARK, Apache2::Const::LOG_INFO,
                       APR::Const::SUCCESS,"STATEMENT: $statement");
        eval {
            $dbh->do($statement);
        };
        if($@)
        {
            $r->log_error("DBERROR: ".$dbh->errstr);
        }
    }

    #
    # update Clients table
    #
    my $aff = 0;
    if($hostname ne "")
    {
        eval
        {
            my $sth = $dbh->prepare("UPDATE Clients SET HOSTNAME=?, TARGET=?, LASTCONTACT=? WHERE GUID=?");
            $sth->bind_param(1, $hostname);
            $sth->bind_param(2, $target);
            $sth->bind_param(3, $regtimestring, SQL_TIMESTAMP);
            $sth->bind_param(4, $regdata->{register}->{guid});
            $aff = $sth->execute;
            
            $r->log_rerror(Apache2::Log::LOG_MARK, Apache2::Const::LOG_INFO,
                           APR::Const::SUCCESS,"STATEMENT: $statement");
        };
        if($@)
        {
            $r->log_error("DBERROR: ".$dbh->errstr);
            $aff = 0;
        }
        if($aff == 0)
        {
            # New registration; we need an insert
            $statement = sprintf("INSERT INTO Clients (GUID, HOSTNAME, TARGET) VALUES (%s, %s, %s)", 
                                 $dbh->quote($regdata->{register}->{guid}),
                                 $dbh->quote($hostname),
                                 $dbh->quote($target));
            $r->log_rerror(Apache2::Log::LOG_MARK, Apache2::Const::LOG_INFO,
                           APR::Const::SUCCESS,"STATEMENT: $statement");
            eval
            {
                $aff = $dbh->do($statement);
            };
            if($@)
            {
                $r->log_error("DBERROR: ".$dbh->errstr);
                $aff = 0;
            }
        }
    }
    else
    {
        eval
        {
            my $sth = $dbh->prepare("UPDATE Clients SET TARGET=?, LASTCONTACT=? WHERE GUID=?");
            $sth->bind_param(1, $target);
            $sth->bind_param(2, $regtimestring, SQL_TIMESTAMP);
            $sth->bind_param(3, $regdata->{register}->{guid});
            $aff = $sth->execute;
            
            $r->log_rerror(Apache2::Log::LOG_MARK, Apache2::Const::LOG_INFO,
                           APR::Const::SUCCESS,"STATEMENT: $statement");
        };
        if($@)
        {
            $r->log_error("DBERROR: ".$dbh->errstr);
            $aff = 0;
        }
        if($aff == 0)
        {
            # New registration; we need an insert
            $statement = sprintf("INSERT INTO Clients (GUID, TARGET) VALUES (%s, %s)", 
                                 $dbh->quote($regdata->{register}->{guid}),
                                 $dbh->quote($target));
            $r->log_rerror(Apache2::Log::LOG_MARK, Apache2::Const::LOG_INFO,
                           APR::Const::SUCCESS,"STATEMENT: $statement");
            eval
            {
                $aff = $dbh->do($statement);
            };
            if($@)
            {
                $r->log_error("DBERROR: ".$dbh->errstr);
                $aff = 0;
            }
        }
    }
    
    return \@list;
}

sub findTarget
{
    my $r       = shift;
    my $dbh     = shift;
    my $regroot = shift;

    my $result  = undef;
    
    if(exists $regroot->{register}->{ostarget} && defined $regroot->{register}->{ostarget} &&
       $regroot->{register}->{ostarget} ne "")
    {
        my $statement = sprintf("SELECT TARGET from Targets WHERE OS=%s", $dbh->quote($regroot->{register}->{ostarget})) ;
        $r->log_rerror(Apache2::Log::LOG_MARK, Apache2::Const::LOG_INFO,
                       APR::Const::SUCCESS,"STATEMENT: $statement");

        my $target = $dbh->selectcol_arrayref($statement);
        
        if(exists $target->[0])
        {
            $result = $target->[0];
        }
    }
    elsif(exists $regroot->{register}->{"ostarget-bak"} && defined $regroot->{register}->{"ostarget-bak"} &&
          $regroot->{register}->{"ostarget-bak"} ne "")
    {
        my $statement = sprintf("SELECT TARGET from Targets WHERE OS=%s", $dbh->quote($regroot->{register}->{"ostarget-bak"})) ;
        $r->log_rerror(Apache2::Log::LOG_MARK, Apache2::Const::LOG_INFO,
                       APR::Const::SUCCESS,"STATEMENT: $statement");

        my $target = $dbh->selectcol_arrayref($statement);
        
        if(exists $target->[0])
        {
            $result = $target->[0];
        }
    }
    return $result;
}

sub findCatalogs
{
    my $r      = shift;
    my $dbh    = shift;
    my $target = shift;
    my $productids = shift;
    

    my $result = {};
    my $statement ="";

    # get catalog values (only for the once we DOMIRROR)

    $statement  = "SELECT c.CATALOGID, c.NAME, c.DESCRIPTION, c.TARGET, c.LOCALPATH, c.CATALOGTYPE from Catalogs c, ProductCatalogs pc WHERE ";

    $statement .= "pc.OPTIONAL='N' AND c.DOMIRROR='Y' AND c.CATALOGID=pc.CATALOGID ";
    $statement .= "AND (c.TARGET IS NULL ";
    if(defined $target && $target ne "")
    {
        $statement .= sprintf("OR c.TARGET=%s", $dbh->quote($target));
    }
    $statement .= ") AND ";

    if(@{$productids} > 1)
    {
        $statement .= "pc.PRODUCTDATAID IN (".join(",", @{$productids}).") ";
    }
    elsif(@{$productids} == 1)
    {
        $statement .= "pc.PRODUCTDATAID = ".$productids->[0]." ";
    }
    else
    {
        # This should not happen
        $r->log_error("No productids found");
        return $result;
    }
    
    $r->log_rerror(Apache2::Log::LOG_MARK, Apache2::Const::LOG_INFO,
                   APR::Const::SUCCESS,"STATEMENT: $statement");

    $result = $dbh->selectall_hashref($statement, "CATALOGID");

    $r->log_rerror(Apache2::Log::LOG_MARK, Apache2::Const::LOG_INFO,
                   APR::Const::SUCCESS, "RESULT: ".Data::Dumper->Dump([$result]));

    return $result;
}

sub buildZmdConfig
{
    my $r          = shift;
    my $guid       = shift;
    my $catalogs   = shift;
    my $usetestenv = shift || 0;
    
    my $cfg = new Config::IniFiles( -file => "/etc/smt.conf" );
    if(!defined $cfg)
    {
        $r->log_error("Cannot read the SMT configuration file: ".@Config::IniFiles::errors);
        die "SMT server is missconfigured. Please contact your administrator.";
    }
    
    my $LocalNUUrl = $cfg->val('LOCAL', 'url');
    $LocalNUUrl =~ s/\s*$//;
    if(!defined $LocalNUUrl || $LocalNUUrl !~ /^http/)
    {
        $r->log_error("Invalid url parameter in smt.conf. Please fix the url parameter in the [LOCAL] section.");
        die "SMT server is missconfigured. Please contact your administrator.";
    }
    
    if($usetestenv)
    {
        $LocalNUUrl    .= "/testing/";
    }
    

    my $output = "";
    my $writer = new XML::Writer(OUTPUT => \$output);

    $writer->xmlDecl("UTF-8");
    $writer->startTag("zmdconfig", 
                      "xmlns" => "http://www.novell.com/xml/center/regsvc-1_0",
                      "lang"  => "en");
    
    $writer->startTag("guid");
    $writer->characters($guid);
    $writer->endTag("guid");
    
    # first write all catalogs of type NU

    $writer->startTag("service", 
                      "id"          => "local_nu_server",
                      "description" => "Local NU Server",
                      "type"        => "nu");
    $writer->startTag("param", "id" => "url");
    $writer->characters($LocalNUUrl);
    $writer->endTag("param");
    
    foreach my $cat (keys %{$catalogs})
    {
        next if(lc($catalogs->{$cat}->{CATALOGTYPE}) ne "nu");
        if(! exists $catalogs->{$cat}->{LOCALPATH} || ! defined $catalogs->{$cat}->{LOCALPATH} ||
           $catalogs->{$cat}->{LOCALPATH} eq "")
        {
            $r->log_error("Path for catalog '$cat' does not exists. Skipping Catalog.");
            next;
        }
        
        $writer->startTag("param", 
                          "name" => "catalog",
                          "url"  => "$LocalNUUrl/repo/".$catalogs->{$cat}->{LOCALPATH}
                         );
        $writer->characters($catalogs->{$cat}->{NAME});
        $writer->endTag("param");
    }
    $writer->endTag("service");
    
    # and now the zypp Repositories

    foreach my $cat (keys %{$catalogs})
    {
        next if(lc($catalogs->{$cat}->{CATALOGTYPE}) ne "zypp");
        if(! exists $catalogs->{$cat}->{LOCALPATH} || ! defined $catalogs->{$cat}->{LOCALPATH} ||
           $catalogs->{$cat}->{LOCALPATH} eq "")
        {
            $r->log_error("Path for catalog '$cat' does not exists. Skipping Catalog.");
            next;
        }

        $writer->startTag("service", 
                          "id"          => $catalogs->{$cat}->{NAME},
                          "description" => $catalogs->{$cat}->{DESCRIPTION},
                          "type"        => "zypp");
        $writer->startTag("param", "id" => "url");
        $writer->characters("$LocalNUUrl/repo/".$catalogs->{$cat}->{LOCALPATH});
        $writer->endTag("param");
        

        $writer->startTag("param", "name" => "catalog");
        $writer->characters($catalogs->{$cat}->{NAME});
        $writer->endTag("param");

        $writer->endTag("service");
    }

    $writer->endTag("zmdconfig");

    return $output;
}

sub findColumnsForProducts
{
    my $r      = shift;
    my $dbh    = shift;
    my $parray = shift;
    my $column = shift;
    
    my @list = ();

    foreach my $phash (@{$parray})
    {
        foreach my $cnt (1..3)
        {
            my $statement = "SELECT $column FROM Products where ";

            $statement .= "PRODUCTLOWER = ".$dbh->quote(lc($phash->{name}))." AND ";

            $statement .= "VERSIONLOWER ";

            if(!defined $phash->{version})
            {
                $statement .= "IS NULL AND ";
            }
            else
            {
                $statement .= "= ".$dbh->quote(lc($phash->{version}))." AND ";
            }
            
            $statement .= "ARCHLOWER ";
            
            if(!defined $phash->{arch})
            {
                $statement .= "IS NULL AND ";
            }
            else
            {
                $statement .= "= ".$dbh->quote(lc($phash->{arch}))." AND ";
            }
            
            $statement .= "RELLOWER ";

            if(!defined $phash->{release})
            {
                $statement .= "IS NULL";
            }
            else
            {
                $statement .= "= ".$dbh->quote(lc($phash->{release}));
            }
                        
            $r->log_rerror(Apache2::Log::LOG_MARK, Apache2::Const::LOG_INFO,
                           APR::Const::SUCCESS, "STATEMENT: $statement");
            
            my $pl = $dbh->selectall_arrayref($statement, {Slice => {}});
            
            #$r->log_error("RESULT: ".Data::Dumper->Dump([$pl]));
            #$r->log_error("RESULT: not defined ") if(!defined $pl);
            #$r->log_error("RESULT: empty ") if(@$pl == 0);

            if(@$pl == 0 && $cnt == 1)
            {
                $phash->{release} = undef;
            }
            elsif(@$pl == 0 && $cnt == 2)
            {
                $phash->{arch} = undef;
            }
            elsif(@$pl == 0 && $cnt == 3)
            {
                $phash->{version} = undef;
            }
            elsif(@$pl == 1 && exists $pl->[0]->{$column})
            {
                push @list, $pl->[0]->{$column};
                last;
            }
        }
    }

    return @list;
}


#
# read the content of a POST and return the data
#
sub read_post {
    my $r = shift;
    
    my $bb = APR::Brigade->new($r->pool,
                               $r->connection->bucket_alloc);
    
    my $data = '';
    my $seen_eos = 0;
    do {
        $r->input_filters->get_brigade($bb, Apache2::Const::MODE_READBYTES,
                                       APR::Const::BLOCK_READ, IOBUFSIZE);
        
        for (my $b = $bb->first; $b; $b = $bb->next($b)) {
            if ($b->is_eos) {
                $seen_eos++;
                last;
            }
            
            if ($b->read(my $buf)) {
                $data .= $buf;
            }
            
            $b->remove; # optimization to reuse memory
        }
        
    } while (!$seen_eos);
    
    $bb->destroy;
    
    return $data;
}


###############################################################################
### XML::Parser Handler
###############################################################################


sub prod_handle_start_tag
{
    my $data = shift;
    my( $expat, $element, %attrs ) = @_;

    if(lc($element) eq "product")
    {
        $data->{STATE} = 1;
        foreach (keys %attrs)
        {
            $data->{CURRENT}->{lc($_)} = $attrs{$_};
        }
    }
}

sub prod_handle_char
{
    my $data = shift;
    my( $expat, $string) = @_;

    if($data->{STATE} == 1)
    {
        chomp($string);
        if(!exists $data->{CURRENT}->{name} || !defined $data->{CURRENT}->{name})
        {
            $data->{CURRENT}->{name} = $string;
        }
        else
        {
            $data->{CURRENT}->{name} .= $string;
        }
    }
}

sub prod_handle_end_tag
{
    my $data = shift;
    my( $expat, $element) = @_;

    if($data->{STATE} == 1)
    {
        push @{$data->{PRODUCTS}}, $data->{CURRENT};
        $data->{CURRENT} = undef;
        $data->{STATE} = 0;
    }
}

sub reg_handle_start_tag
{
    my $data = shift;
    my( $expat, $element, %attrs ) = @_;

    if(lc($element) eq "param")
    {
        if(exists $attrs{id} && defined $attrs{id} && $attrs{id} ne "")
        {
            $data->{CURRENTELEMENT} = $attrs{id};
            # empty params are allowed, so we create the node here
            $data->{register}->{$data->{CURRENTELEMENT}} = "";
        }
    }
    elsif(lc($element) eq "product")
    {
        $data->{CURRENTELEMENT} = lc($element);
        $data->{PRODUCTATTR} = \%attrs;
    }
    elsif(lc($element) eq "register")
    {
        if(exists $attrs{accept} && defined $attrs{accept} && lc($attrs{accept}) eq "mandatory")
        {
            $data->{ACCEPTOPT} = 0;
        }        
    }
    elsif(lc($element) eq "host")
    {
        $data->{CURRENTELEMENT} = lc($element);
        # empty host is allowed, so we create the node here
        $data->{register}->{$data->{CURRENTELEMENT}} = "";
    }
    else
    {
        $data->{CURRENTELEMENT} = lc($element);
    }
}

sub reg_handle_char_tag
{
    my $data = shift;
    my( $expat, $string) = @_;

    if($data->{CURRENTELEMENT} ne "" && $data->{CURRENTELEMENT} ne "product")
    {
        if(exists $data->{register}->{$data->{CURRENTELEMENT}} &&
           defined $data->{register}->{$data->{CURRENTELEMENT}} &&
           $data->{register}->{$data->{CURRENTELEMENT}} ne "")
        {
            $data->{register}->{$data->{CURRENTELEMENT}} .= $string;
        }
        else
        {
            $data->{register}->{$data->{CURRENTELEMENT}} = $string;
        }
    }
    elsif($data->{CURRENTELEMENT} eq "product")
    {
        if(exists $data->{PRODUCTATTR}->{name} &&
           defined $data->{PRODUCTATTR}->{name} &&
           $data->{PRODUCTATTR}->{name} ne "")
        {
            $data->{PRODUCTATTR}->{name} .= $string;
        }
        else
        {
            $data->{PRODUCTATTR}->{name} = $string;
        }
    }
}

sub reg_handle_end_tag
{
    my $data = shift;
    my( $expat, $element) = @_;

    if(lc($element) eq "product")
    {
        if(!exists $data->{register}->{product})
        {
            $data->{register}->{product} = [];
        }
        push @{$data->{register}->{product}}, $data->{PRODUCTATTR};
    }
}

sub nif_handle_start_tag
{
    my $data = shift;
    my( $expat, $element, %attrs ) = @_;
    
    if(lc($element) eq "needinfo")
    {
        $data->{WRITER}->startTag(lc($element), %attrs);
    }
    elsif(lc($element) eq "guid")
    {
        if(!exists $data->{REGISTER}->{register}->{lc($element)})
        {
            $data->{WRITER}->emptyTag(lc($element), %attrs);
            $data->{INFOCOUNT} += 1;
        }           
    }
    elsif(lc($element) eq "host")
    {
        if(!exists $data->{REGISTER}->{register}->{lc($element)})
        {
            $data->{WRITER}->emptyTag(lc($element), %attrs);
            $data->{INFOCOUNT} += 1;
        }              
    }
    elsif(lc($element) eq "product")
    {
        if(!exists $data->{REGISTER}->{register}->{lc($element)})
        {
            $data->{WRITER}->emptyTag(lc($element), %attrs);
            $data->{INFOCOUNT} += 1;
        }
    }
    elsif(lc($element) eq "privacy")
    {
        if(!exists $data->{REGISTER}->{register}->{lc($element)})
        {
            $data->{WRITER}->emptyTag(lc($element), %attrs);
        }
    }
    elsif(lc($element) eq "param")
    {
        my $resetmandhere = 0;
        
        $data->{PARAMDEPTH} += 1;

        if($#{$data->{CACHE}} >= 0)
        {
            $data->{CACHE}->[$#{$data->{CACHE}}]->{SKIP} = 0;
        }
        

        if(exists $attrs{class} && defined $attrs{class} && lc($attrs{class}) eq "mandatory")
        {
            $data->{PARAMISMAND} = 1;
            $resetmandhere = 1;
        }
        
        if(exists $attrs{id} && defined $attrs{id})
        {
            if(exists $data->{REGISTER}->{register}->{$attrs{id}})
            {
                # skip this, it is already there
            }
            elsif(exists $attrs{command} && defined $attrs{command})
            {
                if($data->{REGISTER}->{ACCEPTOPT} || (!$data->{REGISTER}->{ACCEPTOPT} && $data->{PARAMISMAND}))
                {
                    # we do not have a value for this command
                    # if we accept optional => write it
                    #   OR
                    # if the param is mandatory

       
                    push @{$data->{CACHE}}, { SKIP      => 0, 
                                              MUST      => 1,
                                              ELEMENT   => lc($element),
                                              ATTRS     => \%attrs,
                                              WRITTEN   => 0,
                                              RESETMAND => $resetmandhere
                                            };
                    $data->{WRITECACHE} = 1;
                    $data->{INFOCOUNT} += 1;
                    return;
                }
            }
            else
            {
                # Hmmm, maybe we need this later. We need to switch SKIP to 0 if the next
                # element is a start element
                push @{$data->{CACHE}}, { SKIP      => 1,
                                          MUST      => 0,
                                          ELEMENT   => lc($element),
                                          ATTRS     => \%attrs,
                                          WRITTEN   => 0,
                                          RESETMAND => $resetmandhere
                                        };
                return;
            }
        }
        push @{$data->{CACHE}}, { SKIP      => 1, 
                                  MUST      => 0,
                                  ELEMENT   => lc($element),
                                  ATTRS     => \%attrs,
                                  WRITTEN   => 0,
                                  RESETMAND => $resetmandhere
                                };
    }
    elsif(lc($element) eq "select")
    {
        my $resetmandhere = 0;
        
        $data->{PARAMDEPTH} += 1;
        
        if(exists $attrs{class} && defined $attrs{class} && lc($attrs{class}) eq "mandatory")
        {
            $data->{PARAMISMAND} = 1;
            $resetmandhere = 1;
        }
        push @{$data->{CACHE}}, { SKIP      => 0, 
                                  MUST      => 0,
                                  ELEMENT   => lc($element),
                                  ATTRS     => \%attrs,
                                  WRITTEN   => 0,
                                  RESETMAND => $resetmandhere
                                };
    }
    
}

sub nif_handle_end_tag
{
    my $data = shift;
    my( $expat, $element) = @_;

    if(lc($element) eq "param" || lc($element) eq "select")
    {
        $data->{PARAMDEPTH} -= 1;
        
        if($data->{CACHE}->[(@{$data->{CACHE}}-1)]->{SKIP})
        {
            my $msg = "SKIP CACHE element:".$data->{CACHE}->[(@{$data->{CACHE}}-1)]->{ELEMENT};
            if(exists $data->{CACHE}->[(@{$data->{CACHE}}-1)]->{ATTRS}->{id})
            {
                $msg .= " id=".$data->{CACHE}->[(@{$data->{CACHE}}-1)]->{ATTRS}->{id}
            }
            $data->{R}->log_rerror(Apache2::Log::LOG_MARK, Apache2::Const::LOG_INFO,
                                   APR::Const::SUCCESS, $msg);
            my $entry = pop @{$data->{CACHE}};
            if($entry->{RESETMAND})
            {
                $data->{PARAMISMAND} = 0;
            }
            return;
        }

        my $mustwrite = 0;
        for(my $i = 0; $i < @{$data->{CACHE}}; $i++)
        {
            $mustwrite = 1 if($data->{CACHE}->[$i]->{MUST});
        }
        
        if(!$mustwrite)
        {
            # skip last 
            my $msg = "SKIP CACHE (No MUST) element:".$data->{CACHE}->[(@{$data->{CACHE}}-1)]->{ELEMENT};
            if(exists $data->{CACHE}->[(@{$data->{CACHE}}-1)]->{ATTRS}->{id})
            {
                $msg .= " id=".$data->{CACHE}->[(@{$data->{CACHE}}-1)]->{ATTRS}->{id}
            }
            $data->{R}->log_rerror(Apache2::Log::LOG_MARK, Apache2::Const::LOG_INFO,
                                   APR::Const::SUCCESS, $msg);
            my $entry = pop @{$data->{CACHE}};
            if($entry->{RESETMAND})
            {
                $data->{PARAMISMAND} = 0;
            }
            return;
        }
        
        for(my $i = 0; $i < @{$data->{CACHE}}; $i++)
        {
            if(!$data->{CACHE}->[$i]->{WRITTEN})
            {
                my $msg = "Write CACHE START element:".$data->{CACHE}->[$i]->{ELEMENT};
                if(exists $data->{CACHE}->[$i]->{ATTRS}->{id})
                {
                    $msg .= " id=".$data->{CACHE}->[$i]->{ATTRS}->{id}
                }
                                
                $data->{R}->log_rerror(Apache2::Log::LOG_MARK, Apache2::Const::LOG_INFO,
                                       APR::Const::SUCCESS, $msg);
                $data->{WRITER}->startTag($data->{CACHE}->[$i]->{ELEMENT}, %{$data->{CACHE}->[$i]->{ATTRS}});
                $data->{CACHE}->[$i]->{WRITTEN} = 1;
                $data->{CACHE}->[$i]->{MUST} = 1;
            }
        }
        
        # write the last end element
        my $d = pop @{$data->{CACHE}};
        
        if($d->{WRITTEN})
        {
            $data->{R}->log_rerror(Apache2::Log::LOG_MARK, Apache2::Const::LOG_INFO,
                                   APR::Const::SUCCESS, "Write CACHE END element:".$d->{ELEMENT});
            $data->{WRITER}->endTag($d->{ELEMENT});
        }
        if($d->{RESETMAND})
        {
            $data->{PARAMISMAND} = 0;
        }
        
        if($data->{PARAMDEPTH} <= 0)
        {
            $data->{PARAMDEPTH}  = 0;
            $data->{CACHE} = [];
        }
        
    }
    elsif(lc($element) eq "needinfo")
    {
        $data->{WRITER}->endTag(lc($element));
    }
}

1;


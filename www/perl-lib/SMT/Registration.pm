package SMT::Registration;

use strict;
use warnings;

use APR::Brigade ();
use APR::Bucket ();
use Apache2::Filter ();
use Apache2::Log;
use Apache2::RequestRec ();
use Apache2::RequestIO ();

use Apache2::Const -compile => qw(OK SERVER_ERROR :log MODE_READBYTES);
use APR::Const     -compile => qw(:error SUCCESS BLOCK_READ);

use SMT::Utils;
use SMT::Client;
use DBI qw(:sql_types);

use Data::Dumper;
use DBI;
use XML::Writer;
use XML::Parser;
use Date::Parse;

my $REGSHARING = undef;

sub handler {
    my $r = shift;

    $r->content_type('text/xml');

    my $args = $r->args();
    my $hargs = {};

    if(! defined $args)
    {
        $r->log_error("Registration called without args.");
        return SMT::Utils::http_fail($r, 400, "Bad Request");
    }

    foreach my $a (split(/\&/, $args))
    {
        chomp($a);
        my ($key, $value) = split(/=/, $a, 2);
        $hargs->{$key} = $value;
    }

    # check protocol version
    if( exists $hargs->{'version'} && defined $hargs->{'version'} &&
        $hargs->{'version'} ne "1.0")
    {
        $r->log_error("protocol version '".$hargs->{'version'}."' not implemented");
        return SMT::Utils::http_fail($r, 400, "Invalid protocol version.");
    }

    if (! defined $REGSHARING) {
        $REGSHARING = 0;
        if (SMT::Utils::hasRegSharing($r)) {
            eval
            {
                require 'SMT/RegistrationSharing.pm';
            };
            if ($@)
            {
                my $msg = 'Failed to load registration sharing module '
                . '"SMT/RegistrationSharing.pm"'
                . "\n$@";
                $r->log_error($msg);
                $msg = 'Internal Server Error. Please contact your '
                . 'administrator.';
                return SMT::Utils::http_fail($r, 500, $msg);
            }
            # Plugin successfully loaded
            $REGSHARING = 1;
        }
    }

    $r->log->info("Registration called with command: ".$hargs->{command});

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
        elsif($hargs->{command} eq "shareregistration")
        {
            if (! $REGSHARING) {
                my $msg = "Registration sharing is not configured\n";
                $r->log_error($msg);
                $msg = 'Internal Server Error. Please contact your '
                    . 'administrator.';
                return http_fail($r, 500, $msg);
            }
            SMT::RegistrationSharing::addSharedRegistration($r, $hargs);
        }
        elsif($hargs->{command} eq "deltesharedregistration")
        {
            if (! $REGSHARING) {
                my $msg = "Registration sharing is not configured\n";
                $r->log_error($msg);
                $msg = 'Internal Server Error. Please contact your '
                    . 'administrator.';
                return http_fail($r, 500, $msg);
            }
            SMT::RegistrationSharing::deleteSharedRegistration($r, $hargs);
        }
        else
        {
            $r->log_error("Unknown command: ".$hargs->{command});
            return SMT::Utils::http_fail($r, 400, "Bad Request");
        }
    }
    else
    {
        $r->log_error("Missing command");
        return SMT::Utils::http_fail($r, 400, "Bad Request");
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

    my $namespace  = "";

    $r->log->info("register called");

    # to be compatible with SMT10
    if(exists $hargs->{testenv} && $hargs->{testenv})
    {
        $namespace = "testing";
    }
    if(exists $hargs->{namespace} && defined $hargs->{namespace} && $hargs->{namespace} ne "")
    {
        $namespace = $hargs->{namespace};
        if ( $namespace !~ /^[a-zA-z0-9_-]+$/ )
        {
            $namespace  = "";
            $r->log->warn("Invalid Namespace in registration request. Reset to empty");
        }
    }

    my $cfg = undef;

    eval
    {
        $cfg = SMT::Utils::getSMTConfig();
    };
    if($@ || !defined $cfg)
    {
        $r->log_error("Cannot read the SMT configuration file: ".$@);
        return SMT::Utils::http_fail($r, 500,
           "SMT server is missconfigured. Please contact your administrator.");
    }

    if( $namespace ne "" )
    {
        my $LocalBasePath = $cfg->val('LOCAL', 'MirrorTo');
        if(! -d  "$LocalBasePath/repo/$namespace" )
        {
            $r->log_error("Invalid namespace requested: $LocalBasePath/repo/$namespace/ does not exists.");
            $namespace = "";
        }
    }

    my $data = SMT::Utils::read_post($r);
    my $dbh = SMT::Utils::db_connect();
    if(!$dbh)
    {
        $r->log_error("Cannot open Database");
        return SMT::Utils::http_fail($r, 500, "Internal Server Error. Please contact your administrator.");
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
        $r->log->info("Return NEEDINFO: $output");

        # we need to send the <needinfo>
        print $output;
    }
    else
    {
        # we have all data; store it and send <zmdconfig>
        # for cloud quests verify they are authorized to access the server
        my $verifyModule = $cfg->val('LOCAL', 'cloudGuestVerify');
        if ($verifyModule && $verifyModule ne 'none')
        {
            my $module = "SMT::Client::$verifyModule";
            (my $modFile = $module) =~ s|::|/|g;
            eval
            {
                require $modFile . '.pm';
            };
            if ($@)
            {
                $r->log_error(
                 "Failed to load guest verification module '$modFile.pm'\n$@");
                return SMT::Utils::http_fail($r, 500,
                  "Internal Server Error. Please contact your administrator.");
            }
            my $result = $module->verifyGuest($r, $regroot);
            if (! $result)
            {
                $r->log_error("Guest verification failed\n");
                return SMT::Utils::http_fail($r, 403,
                     "Guest verification failed repository access denied");
            }
        }

        # get the os-target

        my $target = SMT::Registration::findTarget($r, $dbh, $regroot);

        # insert new registration data

        my $pidarr = SMT::Registration::insertRegistration($r, $dbh, $regroot, $namespace, $target);

        # get the catalogs

        my $catalogs = SMT::Registration::findCatalogs($r, $dbh, $target, $pidarr);

        my $status = SMT::Registration::getRegistrationStatus($r, $dbh, $regroot->{register}->{guid});

        # send new <zmdconfig>

        my $zmdconfig = SMT::Registration::buildZmdConfig($r, $dbh, $regroot->{register}->{guid}, $catalogs, $status, $namespace);

        if( ! defined $zmdconfig )
        {
            # error already printed, so we only need to return
            return;
        }
        $r->log->info("Return ZMDCONFIG: $zmdconfig");

        print $zmdconfig;
    }
    $dbh->disconnect();

    if ($REGSHARING) {
        # share the registration
        SMT::RegistrationSharing::shareRegistration(
                                               $regroot->{register}->{guid});
    }

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

    $r->log->info("listproducts called");

    my $dbh = SMT::Utils::db_connect();
    if(!$dbh)
    {
        $r->log_error("Cannot connect to database");
        return SMT::Utils::http_fail($r, 500, "Internal Server Error. Please contact your administrator.");
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

    $r->log->info("Return PRODUCTLIST: $output");

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

    $r->log->info("listparams called");

    my $lpreq = SMT::Utils::read_post($r);
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

    $r->log->info("Return PARAMLIST: $xml");

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
    return if($element !~ /^smt::/);

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
    my $r         = shift;
    my $dbh       = shift;
    my $regdata   = shift;
    my $namespace = shift || '';
    my $target    = shift || '';

    my $cnt     = 0;
    my $existingpids = {};
    my $regtimestring = "";
    my $hostname = "";

    my @list = findColumnsForProducts($r, $dbh, $regdata->{register}->{product}, "ID");

    my $statement = sprintf("SELECT PRODUCTID from Registration where GUID=%s", $dbh->quote($regdata->{register}->{guid}));
    $r->log->info("STATEMENT: $statement");
    eval
    {
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
            push @update, $dbh->quote($pnum);
            delete $existingpids->{$pnum};
        }
        else
        {
            # reg does not exist, do insert
            push @insert, $pnum;
        }
    }

    my @delete = ();
    foreach my $d (keys %{$existingpids})
    {
        push @delete, $dbh->quote($d);
    }

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
            $r->log->info("STATEMENT: $statement  Affected rows: $cnt");
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

            $r->log->info("STATEMENT: ".$sth->{Statement}." Affected rows: $cnt");
        };
        if($@)
        {
            $r->log_error("DBERROR: ".$dbh->errstr);
        }
    }

    if(@update > 0)
    {
        $statement = "UPDATE Registration SET REGDATE=? WHERE GUID=? AND PRODUCTID ";

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
            $sth->bind_param(2, $regdata->{register}->{guid});
            $cnt = $sth->execute;
            $r->log->info("STATEMENT: ".$sth->{Statement}."  Affected rows: $cnt");
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
        $r->log->info("STATEMENT: $statement  Affected rows: $cnt");
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
        $r->log->info("STATEMENT: $statement");
        eval {
            $dbh->do($statement);
        };
        if($@)
        {
            $r->log_error("DBERROR: ".$dbh->errstr);
        }
    }

    for(my $i = 0; $i < @{$regdata->{register}->{product}}; $i++)
    {
        my $ph = @{$regdata->{register}->{product}}[$i];

        my $statement = sprintf("INSERT into MachineData (GUID, KEYNAME, VALUE) VALUES (%s, %s, %s)",
                                $dbh->quote($regdata->{register}->{guid}),
                                $dbh->quote("product-name-".$list[$i]),
                                $dbh->quote($ph->{name}));
        $r->log->info("STATEMENT: $statement");
        eval {
            $dbh->do($statement);
        };
        if($@)
        {
            $r->log_error("DBERROR: ".$dbh->errstr);
        }
        $statement = sprintf("INSERT into MachineData (GUID, KEYNAME, VALUE) VALUES (%s, %s, %s)",
                             $dbh->quote($regdata->{register}->{guid}),
                             $dbh->quote("product-version-".$list[$i]),
                             $dbh->quote($ph->{version}));
        $r->log->info("STATEMENT: $statement");
        eval {
            $dbh->do($statement);
        };
        if($@)
        {
            $r->log_error("DBERROR: ".$dbh->errstr);
        }
        $statement = sprintf("INSERT into MachineData (GUID, KEYNAME, VALUE) VALUES (%s, %s, %s)",
                             $dbh->quote($regdata->{register}->{guid}),
                             $dbh->quote("product-arch-".$list[$i]),
                             $dbh->quote($ph->{arch}));
        $r->log->info("STATEMENT: $statement");
        eval {
            $dbh->do($statement);
        };
        if($@)
        {
            $r->log_error("DBERROR: ".$dbh->errstr);
        }
        $statement = sprintf("INSERT into MachineData (GUID, KEYNAME, VALUE) VALUES (%s, %s, %s)",
                             $dbh->quote($regdata->{register}->{guid}),
                             $dbh->quote("product-rel-".$list[$i]),
                             $dbh->quote($ph->{release}));
        $r->log->info("STATEMENT: $statement");
        eval {
            $dbh->do($statement);
        };
        if($@)
        {
            $r->log_error("DBERROR: ".$dbh->errstr);
        }
    }

    #
    # if we do not have the hostname, try to get the IP address
    #
    if($hostname eq "")
    {
        $hostname = $r->connection()->remote_host();
        if(! defined $hostname || $hostname eq "")
        {
            $hostname = $r->connection()->client_ip();
        }
    }

    #
    # update Clients table
    #
    my $aff = 0;
    eval
    {
        my $sth = $dbh->prepare("UPDATE Clients SET HOSTNAME=?, TARGET=?, LASTCONTACT=?, NAMESPACE=?, SECRET=? WHERE GUID=?");
        $sth->bind_param(1, $hostname);
        $sth->bind_param(2, $target);
        $sth->bind_param(3, $regtimestring, SQL_TIMESTAMP);
        $sth->bind_param(4, $namespace );
        $sth->bind_param(5, $regdata->{register}->{secret});
        $sth->bind_param(6, $regdata->{register}->{guid});
        $aff = $sth->execute;

        $r->log->info("STATEMENT: ".$sth->{Statement});
    };
    if ($@)
    {
        $r->log_error("DBERROR: ".$dbh->errstr);
        $aff = 0;
    }
    if ($aff == 0)
    {
        # New registration; we need an insert
        $statement = sprintf("INSERT INTO Clients (GUID, HOSTNAME, TARGET, NAMESPACE, SECRET, REGTYPE) VALUES (%s, %s, %s, %s, %s, 'SR')",
                             $dbh->quote($regdata->{register}->{guid}),
                             $dbh->quote($hostname),
                             $dbh->quote($target),
                             $dbh->quote($namespace),
                             $dbh->quote($regdata->{register}->{secret}));
        $r->log->info("STATEMENT: $statement");
        eval
        {
            $aff = $dbh->do($statement);
        };
        if ($@)
        {
            $r->log_error("DBERROR: ".$dbh->errstr);
            $aff = 0;
        }
    }

    my $client = SMT::Client->new({ 'dbh' => $dbh });

    if ( !  $client->insertPatchstatusJob( $regdata->{register}->{guid} ) )
    {
        $r->log_error(sprintf("SMT Registration error: Could not create initial patchstatus reporting job for client with guid: %s  ",
                              $regdata->{register}->{guid} )  );
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
        $r->log->info("STATEMENT: $statement");

        my $target = $dbh->selectcol_arrayref($statement);

        if(exists $target->[0])
        {
            $result = $target->[0];
        }
    }
    elsif(exists $regroot->{register}->{"ostarget-bak"} && defined $regroot->{register}->{"ostarget-bak"} &&
          $regroot->{register}->{"ostarget-bak"} ne "")
    {
        my $targetString = $regroot->{register}->{"ostarget-bak"};
        $targetString =~ s/^\s*"//;
        $targetString =~ s/"\s*$//;

        my $statement = sprintf("SELECT TARGET from Targets WHERE OS=%s", $dbh->quote($targetString)) ;
        $r->log->info("STATEMENT: $statement");

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

    my @q_pids = ();
    foreach my $id (@{$productids})
    {
        push @q_pids, $dbh->quote($id);
    }


    # get catalog values (only for the once we DOMIRROR)

    $statement  = "SELECT c.ID, c.NAME, c.DESCRIPTION, c.TARGET, c.LOCALPATH, ";
    $statement .= "c.CATALOGTYPE, c.STAGING, pc.OPTIONAL, c.AUTOREFRESH ";
    $statement .= "from Catalogs c, ProductCatalogs pc WHERE ";
    $statement .= "c.DOMIRROR='Y' AND c.ID=pc.CATALOGID ";
    if($target)
    {
        $statement .= sprintf("AND (c.TARGET IS NULL OR c.TARGET=%s)", $dbh->quote($target));
    } # if we do not have the target we use all catalogs assigned to a product
    if(@{$productids} > 1)
    {
        $statement .= "AND pc.PRODUCTID IN (".join(",", @q_pids).") ";
    }
    elsif(@{$productids} == 1)
    {
        $statement .= "AND pc.PRODUCTID = ".$q_pids[0]." ";
    }
    else
    {
        # This should not happen
        $r->log_error("No productids found");
        return $result;
    }

    $r->log->info("STATEMENT: $statement");

    $result = $dbh->selectall_hashref($statement, "ID");

    $r->log->info("RESULT: ".Data::Dumper->Dump([$result]));

    return $result;
}

sub getRegistrationStatus
{
    my $r    = shift;
    my $dbh  = shift;
    my $guid = shift;

    my $statement = sprintf("SELECT r.GUID,
                                    r.NCCREGERROR,
                                    p.PRODUCT,
                                    p.VERSION,
                                    p.REL,
                                    p.ARCH,
                                    p.FRIENDLY,
                                    s.SUBSTATUS STATUS,
                                    s.SUBTYPE TYPE,
                                    s.SUBENDDATE ENDDATE
                               FROM Registration r
                               JOIN Products p ON r.PRODUCTID = p.ID
                          LEFT JOIN ClientSubscriptions cs ON cs.GUID = r.GUID
                          LEFT JOIN Subscriptions s ON s.SUBID = cs.SUBID
                              WHERE r.GUID = %s", $dbh->quote($guid));
    my $status = $dbh->selectall_arrayref( $statement, {Slice=>{}});
    foreach my $prodstatusentry (@{$status})
    {
        # By default it is a success. We set it to error only if we find one.
        $prodstatusentry->{"RESULT"}    = "success";
        $prodstatusentry->{"ERRORCODE"} = "OK";
        $prodstatusentry->{"MESSAGE"}   = "Ok.";
        if ($prodstatusentry->{"NCCREGERROR"})
        {
            $prodstatusentry->{"RESULT"}    = "error";
            $prodstatusentry->{"ERRORCODE"} = "ERR_LOCKED";
            $prodstatusentry->{"MESSAGE"}   = "The regcode is locked by another email address.";
        }
        if ($prodstatusentry->{"STATUS"})
        {
            if ( $prodstatusentry->{"ENDDATE"} )
            {
                $prodstatusentry->{"ENDDATE"} = int(str2time($prodstatusentry->{"ENDDATE"}, "GMT"));
                if ( $prodstatusentry->{"ENDDATE"} < time() )
                {
                    $prodstatusentry->{"STATUS"} = "EXPIRED";
                }
            }
            if ($prodstatusentry->{"STATUS"} eq "EXPIRED")
            {
                $prodstatusentry->{"RESULT"}    = "error";
                $prodstatusentry->{"ERRORCODE"} = "ERR_SUB_EXP";
                $prodstatusentry->{"MESSAGE"}   = "The subscription for ".$prodstatusentry->{"FRIENDLY"}." is expired.";
            }
        }
    }

    return $status;
}

sub buildZmdConfig
{
    my $r          = shift;
    my $dbh        = shift;
    my $guid       = shift;
    my $catalogs   = shift;
    my $status     = shift;
    my $namespace  = shift || '';

    my $cfg = undef;

    eval
    {
        $cfg = SMT::Utils::getSMTConfig();
    };
    if($@ || !defined $cfg)
    {
        $r->log_error("Cannot read the SMT configuration file: ".$@);
        SMT::Utils::http_fail($r, 500, "SMT server is missconfigured. Please contact your administrator.");
        return undef;
    }

    my $LocalNUUrl = $cfg->val('LOCAL', 'url');
    my $LocalBasePath = $cfg->val('LOCAL', 'MirrorTo');
    my $aliasChange = $cfg->val('NU', 'changeAlias');
    if(defined $aliasChange && $aliasChange eq "true")
    {
        $aliasChange = 1;
    }
    else
    {
        $aliasChange = 0;
    }

    $LocalNUUrl =~ s/\s*$//;
    $LocalNUUrl =~ s/\/*$//;
    if(!defined $LocalNUUrl || $LocalNUUrl !~ /^http/)
    {
        $r->log_error("Invalid url parameter in smt.conf. Please fix the url parameter in the [LOCAL] section.");
        SMT::Utils::http_fail($r, 500, "SMT server is missconfigured. Please contact your administrator.");
        return undef;
    }
    my $localID = "SMT-".$LocalNUUrl;
    $localID =~ s/:*\/+/_/g;
    $localID =~ s/\./_/g;
    $localID =~ s/_$//;

    my $nuCatCount = 0;
    foreach my $cat (keys %{$catalogs})
    {
        $nuCatCount++ if(lc($catalogs->{$cat}->{CATALOGTYPE}) eq "nu");
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
    if($nuCatCount > 0 && !SMT::Utils::isRES($dbh, $guid))
    {
        $writer->startTag("service",
                          "id"          => "$localID",
                          "description" => "Local NU Server",
                          "type"        => "nu");
        $writer->startTag("param", "id" => "url");
        $writer->characters($LocalNUUrl."/");
        $writer->endTag("param");

        foreach my $cat (keys %{$catalogs})
        {
            next if(lc($catalogs->{$cat}->{OPTIONAL}) eq "y");
            next if(lc($catalogs->{$cat}->{CATALOGTYPE}) ne "nu");
            if(! exists $catalogs->{$cat}->{LOCALPATH} || ! defined $catalogs->{$cat}->{LOCALPATH} ||
               $catalogs->{$cat}->{LOCALPATH} eq "")
            {
                $r->log_error("Path for repository '$cat' does not exists. Skipping the repository.");
                next;
            }

            my $catalogPath = "repo/";
            my $catalogName = $catalogs->{$cat}->{NAME};
            if($namespace ne "" && uc($catalogs->{$cat}->{STAGING}) eq "Y")
            {
                $catalogPath = SMT::Utils::cleanPath( $catalogPath, $namespace );
                if($aliasChange)
                {
                    $catalogName .= ":$namespace";
                }
            }
            $catalogPath = SMT::Utils::cleanPath( $catalogPath, $catalogs->{$cat}->{LOCALPATH} );
            if(! -d  SMT::Utils::cleanPath( $LocalBasePath, $catalogPath ) )
            {
                # we print only a warning in the log, but return this repos.
                # the user on the client should see immediately that he requested
                # a repo which does not exist.
                $r->log->warn("Returning not existing repositoriy: ".SMT::Utils::cleanPath( $LocalBasePath, $catalogPath ));
            }
            my $catalogURL = $LocalNUUrl."/".$catalogPath;

            $writer->startTag("param",
                              "name" => "catalog",
                              "url"  => $catalogURL
                             );
            $writer->characters($catalogName);
            $writer->endTag("param");
        }
        $writer->endTag("service");
    }

    # and now the zypp and yum Repositories

    foreach my $cat (keys %{$catalogs})
    {
        next if (not ( lc($catalogs->{$cat}->{CATALOGTYPE}) eq "zypp" || SMT::Utils::isRES($dbh, $guid)) );
        if(! exists $catalogs->{$cat}->{LOCALPATH} || ! defined $catalogs->{$cat}->{LOCALPATH} ||
           $catalogs->{$cat}->{LOCALPATH} eq "")
        {
            $r->log_error("Path for repository '$cat' does not exists. Skipping the repository.");
            next;
        }

        my $catalogPath = SMT::Utils::cleanPath( "repo/" );
        my $catalogName = $catalogs->{$cat}->{NAME};
        if($namespace ne "" && uc($catalogs->{$cat}->{STAGING}) eq "Y")
        {
            $catalogPath = SMT::Utils::cleanPath( $catalogPath, $namespace );
            $catalogName = $catalogs->{$cat}->{NAME}.":$namespace";
        }
        $catalogPath = SMT::Utils::cleanPath( $catalogPath, $catalogs->{$cat}->{LOCALPATH} );
        if(! -d  SMT::Utils::cleanPath( $LocalBasePath, $catalogPath) )
        {
            # we print only a warning in the log, but return this repos.
            # the user on the client should see immediately that he requested
            # a repo which does not exist.
            $r->log->warn("Returning not existing repositoriy: ". SMT::Utils::cleanPath( $LocalBasePath, $catalogPath) );
        }
        my $catalogURL = $LocalNUUrl."/".$catalogPath;
        #
        # this does not work
        # NCCcredentials are not known in SLE10 and not in RES
        #
        #$catalogURL .= "?credentials=NCCcredentials";

        $writer->startTag("service",
                          "id"          => $catalogName,
                          "description" => $catalogs->{$cat}->{DESCRIPTION},
                          "type"        => $catalogs->{$cat}->{CATALOGTYPE});
        $writer->startTag("param", "id" => "url");
        $writer->characters($catalogURL);
        $writer->endTag("param");


        $writer->startTag("param", "name" => "catalog");
        $writer->characters($catalogName);
        $writer->endTag("param");

        $writer->endTag("service");
    }
    my $now = time();
    $writer->startTag("status", "generated" => $now);
    foreach my $prodstatusentry (@{$status})
    {
        $writer->startTag("productstatus",
                          "product"   => $prodstatusentry->{"PRODUCT"},
                          "version"   => $prodstatusentry->{"VERSION"},
                          "release"   => $prodstatusentry->{"REL"},
                          "arch"      => $prodstatusentry->{"ARCH"},
                          "result"    => $prodstatusentry->{"RESULT"},
                          "errorcode" => $prodstatusentry->{"ERRORCODE"});
        if ($prodstatusentry->{"STATUS"})
        {
            $writer->emptyTag("subscription",
                              "status"     => $prodstatusentry->{"STATUS"},
                              "expiration" => $prodstatusentry->{"ENDDATE"},
                              "type"       => $prodstatusentry->{"TYPE"});
        }
        if ($prodstatusentry->{"MESSAGE"})
        {
            $writer->startTag("message");
            $writer->characters($prodstatusentry->{"MESSAGE"});
            $writer->endTag("message");
        }
        $writer->endTag("productstatus");
    }
    $writer->endTag("status");
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
        my $statement = sprintf("SELECT %s, PRODUCTLOWER, VERSIONLOWER, RELLOWER, ARCHLOWER FROM Products where ", $dbh->quote_identifier($column));

        $statement .= "PRODUCTLOWER = ".$dbh->quote(lc($phash->{name}));

        $statement .= " AND (";
        $statement .= "VERSIONLOWER=".$dbh->quote(lc($phash->{version}))." OR " if(defined $phash->{version} && $phash->{version} ne "");
        $statement .= "VERSIONLOWER IS NULL)";

        $statement .= " AND (";
        $statement .= "RELLOWER=".$dbh->quote(lc($phash->{release}))." OR " if(defined $phash->{release} && $phash->{release} ne "");
        $statement .= "RELLOWER IS NULL)";

        $statement .= " AND (";
        $statement .= "ARCHLOWER=".$dbh->quote(lc($phash->{arch}))." OR " if(defined $phash->{arch} && $phash->{arch} ne "");
        $statement .= "ARCHLOWER IS NULL)";

        # order by name,version,release,arch with NULL values at the end (bnc#659912)
        $statement .= " ORDER BY PRODUCTLOWER, VERSIONLOWER DESC, RELLOWER DESC, ARCHLOWER DESC";

        $r->log->info( "STATEMENT: $statement");

        my $pl = $dbh->selectall_arrayref($statement, {Slice => {}});

        #$r->log_error("RESULT: ".Data::Dumper->Dump([$pl]));
        #$r->log_error("RESULT: not defined ") if(!defined $pl);
        #$r->log_error("RESULT: empty ") if(@$pl == 0);

        if(@$pl == 1)
        {
            # Only one match found.
            push @list, $pl->[0]->{$column};
        }
        elsif(@$pl > 1)
        {
            my $found = 0;
            # Do we have an exact match?
            foreach my $prod (@$pl)
            {
                if(lc($prod->{VERSIONLOWER}) eq lc($phash->{version}) &&
                   lc($prod->{ARCHLOWER}) eq  lc($phash->{arch})&&
                   lc($prod->{RELLOWER}) eq lc($phash->{release}))
                {
                    # Exact match found.
                    push @list, $prod->{$column};
                    $found = 1;
                    last;
                }
            }
            if(!$found)
            {
                $r->log_error("No exact match found: ".$phash->{name}." ".$phash->{version}." ".$phash->{release}." ".$phash->{arch}." Choose the first one.");
                push @list, $pl->[0]->{$column};
            }
        }
        else
        {
            $r->log_error("No Product match found: ".$phash->{name}." ".$phash->{version}." ".$phash->{release}." ".$phash->{arch});
            SMT::Utils::http_fail($r, 400, "Product (".$phash->{name}." ".$phash->{version}." ".$phash->{release}." ".$phash->{arch}.") not found on Server.");
            exit 0;
        }
    }
    return @list;
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
        if(exists $attrs{type} && defined $attrs{type} && $attrs{type} ne "")
        {
            $data->{register}->{virttype} = $attrs{type};
        }
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
            $data->{R}->log->info($msg);
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
            $data->{R}->log->info($msg);
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

                $data->{R}->log->info($msg);
                $data->{WRITER}->startTag($data->{CACHE}->[$i]->{ELEMENT}, %{$data->{CACHE}->[$i]->{ATTRS}});
                $data->{CACHE}->[$i]->{WRITTEN} = 1;
                $data->{CACHE}->[$i]->{MUST} = 1;
            }
        }

        # write the last end element
        my $d = pop @{$data->{CACHE}};

        if($d->{WRITTEN})
        {
            $data->{R}->log->info("Write CACHE END element:".$d->{ELEMENT});
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


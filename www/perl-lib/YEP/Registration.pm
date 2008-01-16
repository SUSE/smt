package YEP::Registration;

use strict;
use warnings;

use Apache2::RequestRec ();
use Apache2::RequestIO ();

use Apache2::Const -compile => qw(OK SERVER_ERROR :log);
use APR::Const    -compile => qw(:error SUCCESS);

use YEP::Utils;

use Data::Dumper;
use DBI;
use XML::Writer;
use XML::Parser;
use XML::Bare;

sub handler {
    my $r = shift;
    
    $r->content_type('text/xml');

    my $args = $r->args();
    my $hargs = {};
    
    foreach my $a (split(/\&/, $args))
    {
        chomp($a);
        my ($key, $value) = split(/=/, $a, 2);
        $hargs->{$key} = $value;
    }
    $r->warn("Registration called with args: ".Data::Dumper->Dump([$hargs]));
    
    if(exists $hargs->{command} && defined $hargs->{command})
    {
        if($hargs->{command} eq "register")
        {
            YEP::Registration::register($r, $hargs);
        }
        elsif($hargs->{command} eq "listproducts")
        {
            YEP::Registration::listproducts($r, $hargs);
        }
        elsif($hargs->{command} eq "listparams")
        {
            YEP::Registration::listparams($r, $hargs);
        }
        else
        {
            $r->log_error("Unknown command: $hargs->{command}");
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
    my $r     = shift;
    my $hargs = shift;

    $r->warn("register called: ".Data::Dumper->Dump([$r]).",".Data::Dumper->Dump([$hargs]));

    my $data = YEP::Utils::read_post($r);
    my $dbh = YEP::Utils::db_connect();
    if(!$dbh)
    {
        die "Cannot open Database";
    }
    
    my $regroot = { ACCEPTOPT => 1, CURRENTELEMENT => "", PRODUCTATTR => {}, register => {}};
    my $regparser = XML::Parser->new( Handlers =>
                                      { Start => sub { reg_handle_start_tag($regroot, @_) },
                                        Char  => sub { reg_handle_char_tag($regroot, @_) },
                                        End   => sub { reg_handle_end_tag($regroot, @_) }
                                      });

    $regparser->parse( $data );

    my $needinfo = YEP::Registration::parseFromProducts($r, $dbh, $data, "NEEDINFO");

    $r->log_error("REGROOT:".Data::Dumper->Dump([$regroot]));

    my $dat = { NEWINFO => "", 
                CACHE => [],
                WRITECACHE => 0,
                INFOCOUNT => 0, 
                REGISTER => $regroot,
                PARAMDEPTH => 0,
                PARAMISMAND => 0,
                R => $r
               };
    
    my $parser = XML::Parser->new( Handlers =>
                                   { Start=> sub { nif_handle_start_tag($dat, @_) },
                                     End=>   sub { nif_handle_end_tag($dat, @_) }
                                   });
    $parser->parse( $needinfo );

    $r->log_error("INFOCOUNT: ".$dat->{INFOCOUNT});

    if($dat->{INFOCOUNT} > 0)
    {
        # we need to send the <needinfo>
        print $dat->{NEWINFO};
    }
    else
    {
        # we have all data; store it and send <zmdconfig>

        # remove all db values from an old registration of this GUID

        YEP::Registration::cleanOldRegistration($r, $dbh, $regroot->{register}->{guid});

        # insert new registration data

        YEP::Registration::insertRegistration($r, $dbh, $regroot);

        # get the catalogs

        my $catalogs = YEP::Registration::findCatalogs($r, $dbh, $regroot->{register}->{guid});

        # send new <zmdconfig>

        my $zmdconfig = YEP::Registration::buildZmdConfig($r, $regroot->{register}->{guid}, $catalogs);

        $r->log_error("ZMDCONFIG: $zmdconfig");

        print $zmdconfig;
    }
    
    return;
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


sub writeElement
{
    my $element = shift;
    my $empty   = shift;
    my %attr  = @_;
    my $txt     = "";
    
    $txt .= "<$element ";
    foreach (keys %attr)
    {
        $txt .= "$_='$attr{$_}' ";
    }
    if($empty)
    {
        $txt .= "/>";
    }
    else
    {
        $txt .= ">";
    }
    return $txt;
}


sub nif_handle_start_tag
{
    my $data = shift;
    my( $expat, $element, %attrs ) = @_;
    
    if(lc($element) eq "needinfo")
    {
        $data->{NEWINFO} .= writeElement(lc($element), 0, %attrs);
    }
    elsif(lc($element) eq "guid")
    {
        if(!exists $data->{REGISTER}->{register}->{lc($element)})
        {
            $data->{NEWINFO} .= writeElement(lc($element), 1, %attrs);
            $data->{INFOCOUNT} += 1;
        }           
    }
    elsif(lc($element) eq "host")
    {
        if(!exists $data->{REGISTER}->{register}->{lc($element)})
        {
            $data->{NEWINFO} .= writeElement(lc($element), 1, %attrs);
            $data->{INFOCOUNT} += 1;
        }              
    }
    elsif(lc($element) eq "product")
    {
        if(!exists $data->{REGISTER}->{register}->{lc($element)})
        {
            $data->{NEWINFO} .= writeElement(lc($element), 1, %attrs);
            $data->{INFOCOUNT} += 1;
        }
    }
    elsif(lc($element) eq "privacy")
    {
        if(!exists $data->{REGISTER}->{register}->{lc($element)})
        {
            $data->{NEWINFO} .= writeElement(lc($element), 1, %attrs);
        }
    }
    elsif(lc($element) eq "param")
    {
        $data->{PARAMDEPTH} += 1;

        if($#{$data->{CACHE}} >= 0)
        {
            $data->{CACHE}->[$#{$data->{CACHE}}]->{SKIP} = 0;
        }
        

        if(exists $attrs{class} && defined $attrs{class} && lc($attrs{class}) eq "mandatory")
        {
            $data->{PARAMISMAND} = 1;
        }
        
        if(exists $attrs{id} && defined $attrs{id})
        {
            #my $pnode = $data->{PARSER}->find_node($data->{REGISTER}->{register}, "param", id => $attrs{id});
            #if($pnode)
            #{
            #    # skip this, it is already there
            #}

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

       
                    push @{$data->{CACHE}}, { SKIP    => 0, 
                                              MUST    => 1,
                                              START   =>  writeElement(lc($element), 0, %attrs),
                                              WRITTEN => 0,
                                              END     => '</'.lc($element).">"
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
                push @{$data->{CACHE}}, { SKIP    => 1,
                                          MUST    => 0,
                                          START => writeElement(lc($element), 0, %attrs),
                                          WRITTEN => 0,
                                          END     => '</'.lc($element).">"
                                        };
                return;
            }
        }
        push @{$data->{CACHE}}, { SKIP    => 1, 
                                  MUST    => 0,
                                  START => writeElement(lc($element), 0, %attrs),
                                  WRITTEN => 0,
                                  END     => '</'.lc($element).">"
                                };
    }
    elsif(lc($element) eq "select")
    {
        $data->{PARAMDEPTH} += 1;
        
        if(exists $attrs{class} && defined $attrs{class} && lc($attrs{class}) eq "mandatory")
        {
            $data->{PARAMISMAND} = 1;
        }
        push @{$data->{CACHE}}, { SKIP    => 0, 
                                  MUST    => 0,
                                  START => writeElement(lc($element), 0, %attrs),
                                  WRITTEN => 0,
                                  END     => '</'.lc($element).">"
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
        $data->{R}->log_error("CACHE: ".@{$data->{CACHE}});
        
        if($data->{CACHE}->[(@{$data->{CACHE}}-1)]->{SKIP})
        {
            $data->{R}->log_error("SKIP CACHE element:".$data->{CACHE}->[(@{$data->{CACHE}}-1)]->{START});
            pop @{$data->{CACHE}};
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
            $data->{R}->log_error("SKIP CACHE (No MUST) element:".$data->{CACHE}->[(@{$data->{CACHE}}-1)]->{START});
            pop @{$data->{CACHE}};
            return;
        }
        
        for(my $i = 0; $i < @{$data->{CACHE}}; $i++)
        {
            if(!$data->{CACHE}->[$i]->{WRITTEN})
            {
                $data->{R}->log_error("Write CACHE START element:".$data->{CACHE}->[$i]->{START}."   SKIP:".$data->{CACHE}->[$i]->{SKIP});
                $data->{NEWINFO} .= $data->{CACHE}->[$i]->{START};
                $data->{CACHE}->[$i]->{WRITTEN} = 1;
                $data->{CACHE}->[$i]->{MUST} = 1;
            }
        }
        
        # write the last end element
        my $d = pop @{$data->{CACHE}};
        
        if($d->{WRITTEN})
        {
            $data->{R}->log_error("Write CACHE END element:".$d->{END});
            $data->{NEWINFO} .= $d->{END};
        }
        
        if($data->{PARAMDEPTH} <= 0)
        {
            $data->{PARAMISMAND} = 0;
            $data->{PARAMDEPTH}  = 0;
            $data->{CACHE} = [];
        }
        
    }
    elsif(lc($element) eq "needinfo")
    {
        $data->{NEWINFO} .= "</$element>";
    }
}

#
# called from handler if client wants the product list
# command=listproducts argument given
#
sub listproducts
{
    my $r     = shift;
    my $hargs = shift;

    $r->warn("listproducts called: ".Data::Dumper->Dump([$r]).",".Data::Dumper->Dump([$hargs]));
    
    my $dbh = YEP::Utils::db_connect();
    
    my $sth = $dbh->prepare("SELECT DISTINCT PRODUCT FROM Products where product_list = 'Y'");
    $sth->execute();

    my $writer = new XML::Writer(NEWLINES => 1);
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

    $r->warn("listparams called: ".Data::Dumper->Dump([$r]).",".Data::Dumper->Dump([$hargs]));
    
    my $data = YEP::Utils::read_post($r);
    my $dbh = YEP::Utils::db_connect();
    
    my $xml = YEP::Registration::parseFromProducts($r, $dbh, $data, "PARAMLIST");
    
    #$r->log_error("XML: $xml");

    print $xml;

    return;
}

sub parseFromProducts
{
    my $r      = shift;
    my $dbh    = shift;
    my $xml    = shift;
    my $column = shift;
    
    my $data  = {STATE => 0, PRODUCTS => {}};
    
    my $parser = XML::Parser->new( Handlers =>
                                   { Start=> sub { handle_start_tag($data, @_) },
                                     Char => sub { handle_char($data, @_) },
                                     End=>\&handle_end_tag,
                                   });
    $parser->parse( $xml );
    
    my @list = ();
    foreach my $product (keys %{$data->{PRODUCTS}})
    {
        foreach my $cnt (1..3)
        {
            my $statement = "SELECT $column FROM Products where ";

            $statement .= "PRODUCTLOWER = ".$dbh->quote(lc($product))." AND ";

            $statement .= "VERSIONLOWER ";

            if(!defined $data->{PRODUCTS}->{$product}->{version})
            {
                $statement .= "IS NULL AND ";
            }
            else
            {
                $statement .= "= ".$dbh->quote(lc($data->{PRODUCTS}->{$product}->{version}))." AND ";
            }
            
            $statement .= "ARCHLOWER ";
            
            if(!defined $data->{PRODUCTS}->{$product}->{arch})
            {
                $statement .= "IS NULL AND ";
            }
            else
            {
                $statement .= "= ".$dbh->quote(lc($data->{PRODUCTS}->{$product}->{arch}))." AND ";
            }
            
            $statement .= "RELEASELOWER ";

            if(!defined $data->{PRODUCTS}->{$product}->{release})
            {
                $statement .= "IS NULL";
            }
            else
            {
                $statement .= "= ".$dbh->quote(lc($data->{PRODUCTS}->{$product}->{release}));
            }
                        
            #$r->log_error("STATEMENT: $statement");
            
            my $pl = $dbh->selectall_arrayref($statement, {Slice => {}});
            
            #$r->log_error("RESULT: ".Data::Dumper->Dump([$pl]));
            #$r->log_error("RESULT: not defined ") if(!defined $pl);
            #$r->log_error("RESULT: empty ") if(@$pl == 0);

            if(@$pl == 0 && $cnt == 1)
            {
                $data->{PRODUCTS}->{$product}->{release} = undef;
            }
            elsif(@$pl == 0 && $cnt == 2)
            {
                $data->{PRODUCTS}->{$product}->{arch} = undef;
            }
            elsif(@$pl == 0 && $cnt == 3)
            {
                $data->{PRODUCTS}->{$product}->{version} = undef;
            }
            elsif(@$pl == 1 && exists $pl->[0]->{$column})
            {
                push @list, $pl->[0]->{$column};
                last;
            }
        }
    }

    if(uc($column) eq "PARAMLIST")
    {
        return YEP::Registration::joinParamlist($r, \@list);
    }
    elsif(uc($column) eq "NEEDINFO")
    {
        return YEP::Registration::joinNeedinfolist($r, \@list);
    }
    
    return "";
}

sub handle_start_tag
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

sub handle_char
{
    my $data = shift;
    my( $expat, $string) = @_;

    if($data->{STATE} == 1)
    {
        chomp($string);
        foreach (keys %{$data->{CURRENT}})
        {
            $data->{PRODUCTS}->{$string}->{$_} = $data->{CURRENT}->{$_};
        }
        delete $data->{CURRENT};
        $data->{STATE} = 0;
    }
}

sub handle_end_tag
{
    my( $expat, $element, %attrs ) = @_;
}


sub joinParamlist
{
    my $r         = shift;
    my $paramlist = shift;
    
    if(@$paramlist == 1)
    {
        return $paramlist->[0];
    }
    
    my $basedoc = shift @$paramlist;
    
    my $parser = new XML::Bare( text => $basedoc );
    my $root   = $parser->parse( );

    foreach my $other (@$paramlist)
    {
        my $po = new XML::Bare( text => $other );
        my $do = $po->parse( );
        
        foreach my $node (keys %{$do->{paramlist}})
        {
            if($node ne "param" && exists $root->{paramlist}->{$node})
            {
                next;
            }
            elsif($node ne "param" && !exists $root->{paramlist}->{$node})
            {
                # FIXME: is not save to do it this way
                $root->{paramlist}->{$node} = $do->{paramlist}->{$node};
                next;
            }
            # now we have the param node
            
            foreach my $par (@{$do->{paramlist}->{param}})
            {
                if(!$parser->find_node($root->{paramlist}, "param", id => $par->{id}->{value}))
                {
                    #$r->log_error("PARAMNODE: id $par->{id}->{value} does not exist. Add it");

                    if(!exists $root->{paramlist}->{param})
                    {
                        $root->{list}->{paramparam} = $par
                    }
                    elsif(exists $root->{paramlist}->{param} && ref($root->{paramlist}->{param}) eq "HASH")
                    {
                        my $d = $root->{paramlist}->{param};
                        $root->{paramlist}->{param} = [$d];
                        push @{$root->{paramlist}->{param}}, $par;
                    }
                    elsif(exists $root->{paramlist}->{param} && ref($root->{paramlist}->{param}) eq "ARRAY")
                    {
                        # FIXME: is not save to do it this way
                        push @{$root->{paramlist}->{param}}, $par;
                    }
                }
            }
        }
    }
    return $parser->xml( $root );
}

sub joinNeedinfolist
{
    my $r         = shift;
    my $list = shift;
    
    if(@$list == 1)
    {
        return $list->[0];
    }
    
    my $basedoc = shift @$list;
    
    my $parser = new XML::Bare( text => $basedoc );
    my $root   = $parser->parse( );

    foreach my $other (@$list)
    {
        my $po = new XML::Bare( text => $other );
        my $do = $po->parse( );
        
        foreach my $node (keys %{$do->{list}})
        {
            if($node ne "param" && $node ne "select" && exists $root->{list}->{$node})
            {
                next;
            }
            elsif($node ne "param" && $node ne "select" && !exists $root->{list}->{$node})
            {
                # FIXME: is not save to do it this way
                $root->{list}->{$node} = $do->{list}->{$node};
                next;
            }
            # now we have the param/select node
            
            foreach my $par (@{$do->{list}->{param}})
            {
                my $pnode = $parser->find_node($root->{list}, "param", id => $par->{id}->{value});
                if(!$pnode)
                {
                    #$r->log_error("PARAMNODE: id $par->{id}->{value} does not exist. Add it");

                    if(!exists $root->{list}->{param})
                    {
                        $root->{list}->{param} = $par
                    }
                    elsif(exists $root->{list}->{param} && ref($root->{list}->{param}) eq "HASH")
                    {
                        my $d = $root->{list}->{param};
                        $root->{list}->{param} = [$d];
                        push @{$root->{list}->{param}}, $par;
                    }
                    elsif(exists $root->{list}->{param} && ref($root->{list}->{param}) eq "ARRAY")
                    {
                        # FIXME: is not save to do it this way
                        push @{$root->{list}->{param}}, $par;
                    }
                }
                elsif($pnode && exists $pnode->{param})
                {
                    my $pnode2 = $parser->find_node($root->{list}->{param}, "param", id => $par->{param}->{id}->{value});
                    if(!$pnode2)
                    {
                        #$r->log_error("PARAMNODE: id $par->{id}->{value} does not exist. Add it");
                        
                        if(!exists $root->{list}->{param}->{param})
                        {
                            $root->{list}->{param}->{param} = $par->{param};
                        }
                        elsif(exists $root->{list}->{param}->{param} && ref($root->{list}->{param}->{param}) eq "HASH")
                        {
                            my $d = $root->{list}->{param}->{param};
                            $root->{list}->{param}->{param} = [$d];
                            push @{$root->{list}->{param}->{param}}, $par->{param};
                        }
                        elsif(exists $root->{list}->{param}->{param} && ref($root->{list}->{param}->{param}) eq "ARRAY")
                        {
                            # FIXME: is not save to do it this way
                            push @{$root->{list}->{param}->{param}}, $par->{param};
                        }
                    }
                }
            }
        }
    }
    return $parser->xml( $root );
}

sub cleanOldRegistration
{
    my $r    = shift;
    my $dbh  = shift;
    my $guid = shift;
    
    if(!$dbh)
    {
        $r->log_error("Something is wrong with the database handle");
    }
    

    my $statement = sprintf("DELETE from MachineData where GUID=%s", $dbh->quote($guid));
    $r->log_error("STATEMENT: $statement");
    eval {
        $dbh->do($statement);
    };
    if($@)
    {
        $r->log_error("DBERROR: ".$dbh->errstr);
    }
    

    $statement = sprintf("DELETE from Registration where GUID=%s", $dbh->quote($guid));
    $r->log_error("STATEMENT: $statement");
    $dbh->do($statement);

    return;
}

sub insertRegistration
{
    my $r       = shift;
    my $dbh     = shift;
    my $regdata = shift;

    my @list = ();
    foreach my $phash (@{$regdata->{register}->{product}})
    {
        foreach my $cnt (1..3)
        {
            my $statement = "SELECT PRODUCTDATAID FROM Products where ";

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
            
            $statement .= "RELEASELOWER ";

            if(!defined $phash->{release})
            {
                $statement .= "IS NULL";
            }
            else
            {
                $statement .= "= ".$dbh->quote(lc($phash->{release}));
            }
                        
            #$r->log_error("STATEMENT: $statement");
            
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
            elsif(@$pl == 1 && exists $pl->[0]->{PRODUCTDATAID})
            {
                push @list, $pl->[0]->{PRODUCTDATAID};
                last;
            }
        }
    }
   
    foreach my $pnum (@list)
    {
        my $statement = sprintf("INSERT into Registration (GUID, PRODUCTID) VALUES (%s, %s)", 
                                $dbh->quote($regdata->{register}->{guid}), $pnum);
        $r->log_error("STATEMENT: $statement");
        $dbh->do($statement);
    }
    
    foreach my $key (keys %{$regdata->{register}})
    {
        next if($key eq "guid" || $key eq "product" || $key eq "mirrors");
        
        my $statement = sprintf("INSERT into MachineData (GUID, KEY, VALUE) VALUES (%s, %s, %s)",
                                $dbh->quote($regdata->{register}->{guid}), 
                                $dbh->quote($key),
                                $dbh->quote($regdata->{register}->{$key}));
        $r->log_error("STATEMENT: $statement");
        $dbh->do($statement);
    }
    return;
}

sub findCatalogs
{
    my $r    = shift;
    my $dbh  = shift;
    my $guid = shift;

    my $result = {};

    # get productid for this guid

    my $statement = sprintf("SELECT PRODUCTID from Registration WHERE GUID=%s", $dbh->quote($guid));
    $r->log_error("STATEMENT: $statement");
    
    my $productids = $dbh->selectcol_arrayref($statement);
    
    # get product dependencies

    my $pidhash = {};
    
    foreach my $parent (@{$productids})
    {
        $pidhash->{$parent} = 1;
        
        $statement = "SELECT CHILD_PRODUCT_ID from ProductDependencies WHERE PARENT_PRODUCT_ID=$parent";
        $r->log_error("STATEMENT: $statement");

        my $childs = $dbh->selectcol_arrayref($statement);
        foreach my $child (@{$childs})
        {
            $pidhash->{$child} = 1;
        }
    }
    
    # get product catalogs

    $statement = "SELECT CATALOGID from ProductCatalogs WHERE OPTIONAL='N' AND PRODUCTDATAID ";
    
    if(keys %{$pidhash} > 1)
    {
        $statement .= "IN (".join(",", keys %{$pidhash}).")";
    }
    elsif(keys %{$pidhash} == 1)
    {
        $statement .= "= '".join("", keys %{$pidhash})."'";
    }
    else
    {
        # This should not happen
        $r->log_error("No productids found");
        return $result;
    }
    
    $r->log_error("STATEMENT: $statement");
    
    my $catalogs = $dbh->selectcol_arrayref($statement);

    # get catalog values (only for the once we DOMIRROR)

    $statement = "SELECT CATALOGID, NAME, DESCRIPTION, TARGET, LOCALPATH, CATALOGTYPE from Catalogs WHERE CATALOGID ";

    if(@{$catalogs} > 1)
    {
        $statement .= "IN ('".join("','", @{$catalogs})."')";
    }
    elsif(@{$catalogs} == 1)
    {
        $statement .= "= '".$catalogs->[0]."'";
    }
    else
    {
        $r->log_error("No catalogs for these products");
        return $result;
    }
    
    $r->log_error("STATEMENT: $statement");

    $result = $dbh->selectall_hashref($statement, "CATALOGID");

    $r->log_error("RESULT: ".Data::Dumper->Dump([$result]));

    return $result;
}

sub buildZmdConfig
{
    my $r         = shift;
    my $guid      = shift;
    my $catalogs  = shift;

    my $cfg = new Config::IniFiles( -file => "/etc/yep.conf" );
    if(!defined $cfg)
    {
        # FIXME: is die correct here?
        die "Cannot read the YEP configuration file: ".@Config::IniFiles::errors;
    }
    
    my $LocalNUUrl = $cfg->val('REG', 'url');

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
        next if($catalogs->{$cat}->{CATALOGTYPE} ne "nu");
        
        $writer->startTag("param", 
                          "name" => "catalog",
                          "url"  => "$LocalNUUrl/repo/".$catalogs->{$cat}->{LOCALPATH});
        $writer->characters($catalogs->{$cat}->{NAME});
        $writer->endTag("param");
    }
    $writer->endTag("service");
    
    # and now the YUM Repositories

    foreach my $cat (keys %{$catalogs})
    {
        next if($catalogs->{$cat}->{CATALOGTYPE} ne "yum");

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


1;


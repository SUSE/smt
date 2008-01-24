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
    $r->warn("Registration called with command: ".$hargs->{command});
    
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
    my $r          = shift;
    my $hargs      = shift;

    my $usetestenv = 0;
    
    $r->warn("register called.");

    if(exists $hargs->{testenv} && $hargs->{testenv})
    {
        $usetestenv = 1;
    }
    
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
    $parser->parse( $needinfo );

    #$r->log_error("INFOCOUNT: ".$dat->{INFOCOUNT});

    if($dat->{INFOCOUNT} > 0)
    {
        $r->warn("Return NEEDINFO: $output");
        
        # we need to send the <needinfo>
        print $output;
    }
    else
    {
        # we have all data; store it and send <zmdconfig>

        # remove all db values from an old registration of this GUID

        YEP::Registration::cleanOldRegistration($r, $dbh, $regroot->{register}->{guid});

        # insert new registration data

        YEP::Registration::insertRegistration($r, $dbh, $regroot);

        # get the os-target

        my $target = YEP::Registration::findTarget($r, $dbh, $regroot);

        # get the catalogs

        my $catalogs = YEP::Registration::findCatalogs($r, $dbh, $target, $regroot->{register}->{guid});

        # send new <zmdconfig>

        my $zmdconfig = YEP::Registration::buildZmdConfig($r, $regroot->{register}->{guid}, $catalogs, $usetestenv);

        $r->warn("Return ZMDCONFIG: $zmdconfig");

        print $zmdconfig;
    }
    $dbh->disconnect();

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

#
# called from handler if client wants the product list
# command=listproducts argument given
#
sub listproducts
{
    my $r     = shift;
    my $hargs = shift;

    $r->warn("listproducts called.");
    
    my $dbh = YEP::Utils::db_connect();
    if(!$dbh)
    {
        die "Cannot connect to database";
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
    
    $r->warn("Return PRODUCTLIST: $output");

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
    
    my $data = YEP::Utils::read_post($r);
    my $dbh = YEP::Utils::db_connect();
    
    my $xml = YEP::Registration::parseFromProducts($r, $dbh, $data, "PARAMLIST");
    
    $r->warn("Return PARAMLIST: $xml");

    print $xml;

    $dbh->disconnect();

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
        #return YEP::Registration::joinParamlist($r, \@list);
        return YEP::Registration::mergeDocuments($r, \@list);
        
    }
    elsif(uc($column) eq "NEEDINFO")
    {
        #return YEP::Registration::joinNeedinfolist($r, \@list);
        return YEP::Registration::mergeDocuments($r, \@list);
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


sub writeXML
{
    my $node = shift;
    my $writer = shift;

    my $element = ref($node);
    $element =~ s/^yep:://;
    
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
                if(ref($child2) eq "yep::param")
                {
                    # we have to match the id
                    if($child2->{id} eq $child1->{id})
                    {
                        $found = 1;
                        merge($child1, $child2);
                    }
                }
                else
                {
                    $found = 1;
                    merge($child1, $child2);
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
            my $p1 = XML::Parser->new(Style => 'Objects', Pkg => 'yep');
            $root1 = $p1->parse( $basedoc );
            $node1 = $root1->[0];
            next;
        }
        next if($basedoc eq $other);
        
        my $p2 = XML::Parser->new(Style => 'Objects', Pkg => 'yep');
        my $root2 = $p2->parse( $other );
        my $node2;
        
        if(ref($root1->[0]) eq ref($root2->[0]))
        {
            $node1 = $root1->[0];
            $node2 = $root2->[0];

            merge($node1, $node2);
        }
    }
    
    my $output = "";
    my $w = XML::Writer->new(NEWLINES => 0, OUTPUT => \$output);
    $w->xmlDecl("UTF-8");
    
    writeXML($node1, $w);

    return $output;
}

sub cleanOldRegistration
{
    my $r    = shift;
    my $dbh  = shift;
    my $guid = shift;
    
    if(!$dbh)
    {
        $r->log_error("Something is wrong with the database handle");
        return;
    }
    

    my $statement = sprintf("DELETE from MachineData where GUID=%s", $dbh->quote($guid));
    $r->log_rerror(Apache2::Log::LOG_MARK, Apache2::Const::LOG_INFO,
                   APR::Const::SUCCESS, "STATEMENT: $statement");
    eval {
        $dbh->do($statement);
    };
    if($@)
    {
        $r->log_error("DBERROR: ".$dbh->errstr);
    }
    

    $statement = sprintf("DELETE from Registration where GUID=%s", $dbh->quote($guid));
    $r->log_rerror(Apache2::Log::LOG_MARK, Apache2::Const::LOG_INFO,
                   APR::Const::SUCCESS,"STATEMENT: $statement");
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
        $r->log_rerror(Apache2::Log::LOG_MARK, Apache2::Const::LOG_INFO,
                       APR::Const::SUCCESS,"STATEMENT: $statement");
        $dbh->do($statement);
    }
    
    foreach my $key (keys %{$regdata->{register}})
    {
        next if($key eq "guid" || $key eq "product" || $key eq "mirrors");
        
        my $statement = sprintf("INSERT into MachineData (GUID, KEY, VALUE) VALUES (%s, %s, %s)",
                                $dbh->quote($regdata->{register}->{guid}), 
                                $dbh->quote($key),
                                $dbh->quote($regdata->{register}->{$key}));
        $r->log_rerror(Apache2::Log::LOG_MARK, Apache2::Const::LOG_INFO,
                       APR::Const::SUCCESS,"STATEMENT: $statement");
        $dbh->do($statement);
    }
    return;
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
    my $guid   = shift;

    my $result = {};

    # get productid for this guid

    my $statement = sprintf("SELECT PRODUCTID from Registration WHERE GUID=%s", $dbh->quote($guid));
    $r->log_rerror(Apache2::Log::LOG_MARK, Apache2::Const::LOG_INFO,
                   APR::Const::SUCCESS,"STATEMENT: $statement");
    
    my $productids = $dbh->selectcol_arrayref($statement);
    
    # get product dependencies

    my $pidhash = {};
    
    foreach my $parent (@{$productids})
    {
        $pidhash->{$parent} = 1;
        
        $statement = "SELECT CHILD_PRODUCT_ID from ProductDependencies WHERE PARENT_PRODUCT_ID=$parent";
        $r->log_rerror(Apache2::Log::LOG_MARK, Apache2::Const::LOG_INFO,
                       APR::Const::SUCCESS,"STATEMENT: $statement");

        my $childs = $dbh->selectcol_arrayref($statement);
        foreach my $child (@{$childs})
        {
            $pidhash->{$child} = 1;
        }
    }
    
    # get catalog values (only for the once we DOMIRROR)

    $statement  = "SELECT c.CATALOGID, c.NAME, c.DESCRIPTION, c.TARGET, c.LOCALPATH, c.CATALOGTYPE from Catalogs c, ProductCatalogs pc WHERE ";

    $statement .= "pc.OPTIONAL='N' AND c.DOMIRROR='Y' AND c.CATALOGID=pc.CATALOGID ";
    $statement .= "AND (c.TARGET IS NULL ";
    if(defined $target && $target ne "")
    {
        $statement .= sprintf("OR c.TARGET=%s", $dbh->quote($target));
    }
    $statement .= ") AND ";


    if(keys %{$pidhash} > 1)
    {
        $statement .= "pc.PRODUCTDATAID IN (".join(",", keys %{$pidhash}).") ";
    }
    elsif(keys %{$pidhash} == 1)
    {
        $statement .= "pc.PRODUCTDATAID = ".join("", keys %{$pidhash})." ";
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
    
    my $cfg = new Config::IniFiles( -file => "/etc/yep.conf" );
    if(!defined $cfg)
    {
        # FIXME: is die correct here?
        die "Cannot read the YEP configuration file: ".@Config::IniFiles::errors;
    }
    
    my $LocalNUUrl = $cfg->val('LOCAL', 'url');
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
    
        $writer->startTag("param", 
                          "name" => "catalog",
                          "url"  => "$LocalNUUrl/repo/".$catalogs->{$cat}->{LOCALPATH}
                         );
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


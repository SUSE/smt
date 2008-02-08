package YEP::NCCRegTools;
use strict;

use LWP::UserAgent;
use URI;
use YEP::Parser::ListReg;
use XML::Writer;
use Crypt::SSLeay;
use YEP::Utils;
use File::Temp;

use Data::Dumper;

BEGIN
{
    if(exists $ENV{https_proxy})
    {
        # required for Crypt::SSLeay HTTPS Proxy support
        $ENV{HTTPS_PROXY} = $ENV{https_proxy};
    }
}

# constructor
sub new
{
    my $pkgname = shift;
    my %opt   = @_;

    my $self  = {};

    $self->{URI}   = undef;
    $self->{DEBUG} = 0;
    # Do _NOT_ set env_proxy for LWP::UserAgent, this would break https proxy support
    $self->{USERAGENT}  = undef; 
    $self->{YEPGUID} = "";
    $self->{YEPSECRET} = "";

    $self->{DBH} = undef;

    $self->{TEMPDIR} = File::Temp::tempdir(CLEANUP => 1);

    $self->{FROMDIR} = undef;
    $self->{TODIR}   = undef;

    if(exists $opt{useragent} && defined $opt{useragent} && $opt{useragent})
    {
        $self->{USERAGENT} = $opt{useragent};
    }
    else
    {
        $self->{USERAGENT} = LWP::UserAgent->new(keep_alive => 1);
        $self->{USERAGENT}->default_headers->push_header('Content-Type' => 'text/xml');
        # FIXME: remove http for production
        $self->{USERAGENT}->protocols_allowed( [ 'http', 'https'] );
        push @{ $self->{USERAGENT}->requests_redirectable }, 'POST';
    }
    
    if(exists $ENV{http_proxy})
    {
        $self->{USERAGENT}->proxy("http",  $ENV{http_proxy});
    }

    if(exists $opt{debug} && defined $opt{debug} && $opt{debug})
    {
        $self->{DEBUG} = 1;
    }

    if(exists $opt{fromdir} && defined $opt{fromdir} && -d $opt{fromdir})
    {
	    $self->{FROMDIR} = $opt{fromdir};
    }
    elsif(exists $opt{todir} && defined $opt{todir} && -d $opt{todir})
    {
	    $self->{TODIR} = $opt{todir};
    }

    if(exists $opt{dbh} && defined $opt{dbh} && $opt{dbh})
    {
	    $self->{DBH} = $opt{dbh};
    }
    else
    {
        $self->{DBH} = YEP::Utils::db_connect();
    }
    
    
    my ($ruri, $rguid, $rsecret) = YEP::Utils::getLocalRegInfos();
    
    $self->{URI}      = $ruri;
    $self->{YEPGUID}  = $rguid;
    $self->{YEPSECRET}= $rsecret;
    bless($self);
    
    return $self;
}

#
# return count of errors. 0 == success
#
sub NCCRegister
{
    my $self = shift;
    
    my $errors = 0;
    
    if(! defined $self->{DBH} || !$self->{DBH})
    {
        print STDERR __("Database handle is not available.\n");
        return 1;
    }

    eval
    {
        my $guids = $self->{DBH}->selectcol_arrayref("SELECT DISTINCT GUID from Registration WHERE REGDATE > NCCREGDATE");
        
        foreach my $guid (@{$guids})
        {
            my $regtimestring = YEP::Utils::getDBTimestamp();
            my $products = $self->{DBH}->selectall_arrayref(sprintf("select p.PRODUCTDATAID, p.PRODUCT, p.VERSION, p.REL, p.ARCH from Products p, Registration r where r.GUID=%s
 and r.PRODUCTID=p.PRODUCTDATAID", $self->{DBH}->quote($guid)), {Slice => {}});
            
            my $regdata =  $self->{DBH}->selectall_arrayref(sprintf("select KEYNAME, VALUE from MachineData where GUID=%s", 
                                                                    $self->{DBH}->quote($guid)), {Slice => {}});
            
            if(defined $regdata && ref($regdata) eq "ARRAY")
            {
                my $out = $self->_buildRegisterXML($guid, $products, $regdata);
                
                if(!defined $out || $out eq "")
                {
                    print STDERR sprintf(__("Unable to generate XML for GUID: %s\n"). $guid);
                    $errors++;
                    next;
                }
                
                my $ret = $self->_sendData($out, "command=register");
                if(!$ret)
                {
                    $errors++;
                    next;
                }
                
                $ret = $self->_updateRegistration($guid, $products, $regtimestring);
                if(!$ret)
                {
                    $errors++;
                    next;
                }
            }
            else
            {
                print STDERR sprintf(__("Incomplete registration found. GUID:%s\n"), $guid);
                $errors++;
                next;
            }
        }
    };
    if($@)
    {
        print STDERR $@."\n";
        $errors++;
    }
    return $errors;
}

#
# return count of errors. 0 == success
#
sub NCCListRegistrations
{
    my $self = shift;

    my $destfile = $self->{TEMPDIR};
    
    if(defined $self->{FROMDIR} && -d $self->{FROMDIR})
    {
        $destfile = $self->{FROMDIR}."/listregistrations.xml";
    }
    else
    {
        my $output = "";
        my %a = ("xmlns" => "http://www.novell.com/xml/center/regsvc-1_0",
                 "client_version" => "1.2.3");
        
        my $writer = new XML::Writer(OUTPUT => \$output);
        $writer->xmlDecl("UTF-8");
        $writer->startTag("listregistrations", %a);
        
        $writer->startTag("yepguid");
        $writer->characters($self->{YEPGUID});
        $writer->endTag("yepguid");
        
        $writer->startTag("yepsecret");
        $writer->characters($self->{YEPSECRET});
        $writer->endTag("yepsecret");

        $writer->endTag("listregistrations");
        
        if(defined $self->{TODIR} && $self->{TODIR} ne "")
        {
            $destfile = $self->{TODIR};
        }
    
        $destfile .= "/listregistrations.xml";
        my $ok = $self->_sendData($output, "command=listregistrations", $destfile);
    
        if(!$ok || !-e $destfile)
        {
            print STDERR "List registrations request failed.\n";
            return 1;
        }
        return 0;
    }
    
    if(defined $self->{TODIR} && $self->{TODIR} ne "")
    {
        return 0;
    }
    else
    {
        if(! defined $self->{DBH} || !$self->{DBH})
        {
            print STDERR __("Database handle is not available.\n");
            return 1;
        }
        
        my $guidhash = $self->{DBH}->selectall_hashref("SELECT DISTINCT GUID from Registration WHERE NCCREGDATE > '2000-01-01 00:00:00'");

        my $parser = new YEP::Parser::ListReg();
        $parser->parse($destfile, sub{ _listreg_handler($self, $guidhash, @_)});
    
        # $guidhash includes now a list of GUIDs which are no longer in NCC
        # A customer may have removed them via NCC web page. 
        # So remove them also here in YEP
        
        $self->_deleteRegistrationLocal(keys %{$guidhash});
        
        return 0;
    }
}

#
# return count of errors. 0 == success
#
sub NCCDeleteRegistration
{
    my $self = shift;
    my @guids = @_;
    
    my $errors = 0;
    
    if(! defined $self->{DBH} || !$self->{DBH})
    {
        print STDERR __("Database handle is not available.\n");
        return 1;
    }

    foreach my $guid (@guids)
    {
        my $output = "";
        my %a = ("xmlns" => "http://www.novell.com/xml/center/regsvc-1_0",
                 "client_version" => "1.2.3");
        
        my $writer = new XML::Writer(OUTPUT => \$output);
        $writer->xmlDecl("UTF-8");
        $writer->startTag("de-register", %a);

        $writer->startTag("guid");
        $writer->characters($guid);
        $writer->endTag("guid");
        
        $writer->startTag("yepguid");
        $writer->characters($self->{YEPGUID});
        $writer->endTag("yepguid");
        
        $writer->startTag("yepsecret");
        $writer->characters($self->{YEPSECRET});
        $writer->endTag("yepsecret");
        
        $writer->endTag("de-register");
        
        my $ok = $self->_sendData($output, "command=de-register");
        
        if(!$ok)
        {
            print STDERR sprintf(__("Delete registration request failed: %s.\n"), $guid);
            $errors++;
        }
        $self->_deleteRegistrationLocal($guid);
    }
    return $errors;
}


###############################################################################
###############################################################################
###############################################################################
###############################################################################

sub _deleteRegistrationLocal
{
    my $self = shift;
    my @guids = @_;
    
    my $where = "";
    if(@guids == 0)
    {
        return 1;
    }
    elsif(@guids == 1)
    {
        $where = sprintf("GUID = %s", $self->{DBH}->quote( $guids[0] ) );
    }
    else
    {
        $where = sprintf("GUID IN ('%s')", join("','", @guids));
    }
        
    my $statement = "DELETE FROM Registration where ".$where;
    
    $self->{DBH}->do($statement);
    
    $statement = "DELETE FROM Clients where ".$where;

    $self->{DBH}->do($statement);
    
    $statement = "DELETE FROM MachineData where ".$where;
    
    $self->{DBH}->do($statement);
    
    $statement = "DELETE FROM SubscriptionStatus where ".$where;

    $self->{DBH}->do($statement);

    return 1;
}


sub _listreg_handler
{
    my $self     = shift;
    my $guidhash = shift;
    my $data     = shift;
    
    my $statement = "";

    if(!exists $data->{GUID} || !defined $data->{GUID})
    {
        # should not happen, but it is better to check it
        return;
    }
    
    eval
    {
        # check if data->{GUID} exists localy
        if(exists $guidhash->{$data->{GUID}})
        {
            delete $guidhash->{$data->{GUID}};
            $statement = sprintf("DELETE from SubscriptionStatus where GUID=%s", $self->{DBH}->quote($data->{GUID}));
            
            $self->{DBH}->do($statement);
            
            foreach my $key (keys %{$data})
            {
                next if($key eq "GUID" || $key eq "");
                
                # FIXME# STARTDATE and ENDDATE may need a format convert
                $statement = "INSERT INTO SubscriptionStatus (GUID, SUBSCRIPTION, SUBTYPE, SUBSTATUS, SUBSTARTDATE, SUBENDDATE, SUBDURATION, SERVERCLASS) ";
                $statement .= sprintf("VALUES(%s, %s, %s, %s, %s, %s, %s, %s)", 
                                      $self->{DBH}->quote($data->{GUID}),
                                      $self->{DBH}->quote($key),
                                      $self->{DBH}->quote($data->{$key}->{TYPE}),
                                      $self->{DBH}->quote($data->{$key}->{STATUS}),
                                      $self->{DBH}->quote($data->{$key}->{STARTDATE}),
                                      $self->{DBH}->quote($data->{$key}->{ENDDATE}),
                                      $data->{$key}->{DURATION},
                                      $self->{DBH}->quote($data->{$key}->{SERVERCLASS}));
                
                $self->{DBH}->do($statement);
            }
        }
        else
        {
            # We found a registration from YEP in NCC which does not exist in YEP anymore
            # print and error. The admin has to delete it in NCC by hand.
            print STDERR sprintf(__("WARNING: Found a subscription in NCC which is not available here: '%s'"), $data->{GUID});
        }
    };
    if($@)
    {
        print STDERR $@."\n";
        return;
    }
    return;
}


sub _updateRegistration
{
    my $self          = shift || undef;
    my $guid          = shift || undef;
    my $products      = shift || undef;
    my $regtimestring = shift || undef;
    
    if(!defined $guid)
    {
        print STDERR __("Invalid GUID\n");
        return 0;
    }
    
    if(!defined $products || ref($products) ne "ARRAY")
    {
        print STDERR __("Invalid Products\n");
        return 0;
    }
    
    if(!defined $regtimestring)
    {
        print STDERR __("Invalid time string\n");
        return 0;
    }
    
    my @productids = ();
    foreach my $prod (@{$products})
    {
        if( exists $prod->{PRODUCTDATAID} && defined $prod->{PRODUCTDATAID} )
        {
            push @productids, $prod->{PRODUCTDATAID};
        }
    }
    
    my $statement = "UPDATE Registration SET NCCREGDATE=%s WHERE GUID=%s and ";
    if(@productids > 1)
    {
        $statement .= "PRODUCTID IN (".join(",", @productids).")";
    }
    elsif(@productids == 1)
    {
        $statement .= "PRODUCTID = ".$productids[0];
    }
    else
    {
        # this should not happen
        print STDERR __("No products found.\n");
        return 0;
    }
    
    return $self->{DBH}->do(sprintf($statement, $self->{DBH}->quote($regtimestring), $self->{DBH}->quote($guid)));
}


sub _sendData
{
    my $self = shift || undef;
    my $data = shift || undef;
    my $query = shift || undef;
    my $destfile = shift || undef;
    

    if (! defined $self->{URI})
    {
        print STDERR __("Cannot send data to registration server. Missing URL.\n");
        return 0;
    }
    if($self->{URI} =~ /^-/)
    {
        print STDERR sprintf(__("Invalid protocol(%s).\n"), $self->{URI});
        return 0;
    }

    my $regurl = URI->new($self->{URI});
    if(defined $query && $query =~ /\w=\w/)
    {
        $regurl->query($query);
    }
    

    print "SEND TO: ".$regurl->as_string()."\n" if($self->{DEBUG});
    print "XML:\n$data\n" if($self->{DEBUG});

    # FIXME: we need to delete this as soon as NCC provide these features
    return 1;

    my %params = ('Content' => $data);
    if(defined $destfile && $destfile ne "")
    {
        $params{':content_file'} = $destfile;
    } 
    
    my $response = $self->{USERAGENT}->post( $regurl->as_string(), %params);
    
    if($response->is_success)
    {
        return 1;
    }
    else
    {
        print STDERR $response->status_line."\n";
        return 0;
    }
}


sub _buildRegisterXML
{
    my $self     = shift;
    my $guid     = shift;
    my $products = shift;
    my $regdata  = shift;

    my $output = "";

    my $writer = new XML::Writer(OUTPUT => \$output);
    $writer->xmlDecl("UTF-8");
    
    my %a = ("xmlns" => "http://www.novell.com/xml/center/regsvc-1_0",
             "client_version" => "1.2.3");

#     if(!$ctx->{nooptional})
#     {
#         $a{accept} = "optional";
#     }
#     if($ctx->{acceptmand} || $ctx->{nooptional})
#     {
#         $a{accept} = "mandatory";
#     }
    $a{force} = "batch";
    
    $writer->startTag("register", %a);

    $writer->startTag("guid");
    $writer->characters($guid);
    $writer->endTag("guid");

    foreach my $pair (@{$regdata})
    {
        if($pair->{KEYNAME} eq "host")
        {
            if(defined $pair->{VALUE} && $pair->{VALUE} ne "")
            {
                $writer->startTag("host");
                $writer->characters($pair->{VALUE});
                $writer->endTag("host");
            }
            else
            {
                $writer->emptyTag("host");
            }
            last;
        }
    }
    
    $writer->startTag("yepguid");
    $writer->characters($self->{YEPGUID});
    $writer->endTag("yepguid");

    $writer->startTag("yepsecret");
    $writer->characters($self->{YEPSECRET});
    $writer->endTag("yepsecret");
    
    foreach my $PHash (@{$products})
    {
        if(defined $PHash->{PRODUCT} && $PHash->{PRODUCT} ne "" &&
           defined $PHash->{VERSION} && $PHash->{VERSION} ne "")
        {
            $writer->startTag("product",
                              "version" => $PHash->{VERSION},
                              "release" => (defined $PHash->{REL})?$PHash->{REL}:"",
                              "arch"    => (defined $PHash->{ARCH})?$PHash->{ARCH}:"");
            if ($PHash->{PRODUCT} =~ /\s+/)
            {
                $writer->cdata($PHash->{PRODUCT});
            }
            else
            {
                $writer->characters($PHash->{PRODUCT});
            }
            $writer->endTag("product");
        }
    }

    foreach my $pair (@{$regdata})
    {
        next if($pair->{KEYNAME} eq "host");
        if(!defined $pair->{VALUE})
        {
            $pair->{VALUE} = "";
        }
        
        if($pair->{VALUE} eq "")
        {
            $writer->emptyTag("param", "id" => $pair->{KEYNAME});
        }
        else
        {
            $writer->startTag("param",
                              "id" => $pair->{KEYNAME});
            if ($pair->{VALUE} =~ /\s+/)
            {
                $writer->cdata($pair->{VALUE});
            }
            else
            {
                $writer->characters($pair->{VALUE});
            }
            $writer->endTag("param");
        }
    }

    $writer->endTag("register");

    return $output;
}

1;

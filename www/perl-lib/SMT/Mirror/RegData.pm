package SMT::Mirror::RegData;
use strict;

use LWP::UserAgent;
use URI;
use SMT::Parser::RegData;
use XML::Writer;
use Crypt::SSLeay;
use SMT::Utils;
use File::Temp;

use Data::Dumper;

=head1 NAME

SMT::Mirror::RegData - Get data from Registration Server

=head1 SYNOPSIS

  use SMT::Mirror::RegData;

    my $rd= SMT::Mirror::RegData->new(element => "productdata",
                                      table   => "Products",
                                      key     => "PRODUCTDATAID");
    my $res = $rd->sync();

=head1 DESCRIPTION

Sync data from registration server

=head1 METHODS

=over 4

=item new([%params])

Create a new SMT::Mirror::RegData object:

  my $rd = SMT::Mirror::RegData->new();

Arguments are an anonymous hash array of parameters:

=over 4

=item debug <0|1>

Set to 1 to enable debug. 

=item log

Logfile handle

=item element

Requested element name

=item table

Table name

=item key

Primary key of the table. If more then one column build the primary key, provide 
a array reference. 

=item fromdir

Data are in fromdir. Do not contact registration server to get the data.

=item todir

Write data into todir. Do not update the database.

=back
=cut

# constructor
sub new
{
    my $pkgname = shift;
    my %opt   = @_;

    my $self  = {};

    $self->{URI}   = undef;
    $self->{DEBUG} = 0;
    $self->{LOG}   = undef;
    # Do _NOT_ set env_proxy for LWP::UserAgent, this would break https proxy support
    $self->{USERAGENT}  = SMT::Utils::createUserAgent(keep_alive => 1);
    $self->{USERAGENT}->default_headers->push_header('Content-Type' => 'text/xml');
    $self->{USERAGENT}->protocols_allowed( [ 'https'] );
    
    $self->{MAX_REDIRECTS} = 2;
    
    $self->{AUTHUSER} = "";
    $self->{AUTHPASS} = "";
    
    $self->{SMTGUID} = SMT::Utils::getSMTGuid();

    $self->{TEMPDIR} = File::Temp::tempdir("smt-XXXXXXXX", CLEANUP => 1, TMPDIR => 1);

    $self->{ELEMENT} = "";
    $self->{TABLE}   = "";
    $self->{KEYNAME}     = [];
    
    $self->{XML}->{DATA}    = {};

    $self->{FROMDIR} = undef;
    $self->{TODIR}   = undef;
    
    if(exists $opt{debug} && defined $opt{debug} && $opt{debug})
    {
        $self->{DEBUG} = 1;
    }

    if(exists $opt{element} && defined $opt{element} && $opt{element} ne "")
    {
        $self->{ELEMENT} = $opt{element};
    }

    if(exists $opt{table} && defined $opt{table} && $opt{table} ne "")
    {
        $self->{TABLE} = $opt{table};
    }

    if(exists $opt{fromdir} && defined $opt{fromdir} && -d $opt{fromdir})
    {
	    $self->{FROMDIR} = $opt{fromdir};
    }
    elsif(exists $opt{todir} && defined $opt{todir} && -d $opt{todir})
    {
	    $self->{TODIR} = $opt{todir};
    }

    if(exists $opt{log} && defined $opt{log} && $opt{log})
    {
        $self->{LOG} = $opt{log};
    }
    else
    {
        $self->{LOG} = SMT::Utils::openLog();
    }

    my ($ruri, $authuser, $authpass) = SMT::Utils::getLocalRegInfos();

    $self->{URI} = $ruri;
    #$self->{USERINFO} = $rguid.":".$rsecret;

    $self->{AUTHUSER} = $authuser;
    $self->{AUTHPASS} = $authpass;
    
    bless($self);

    if(exists $opt{key} && defined $opt{key})
    {
        $self->key($opt{key});
    }

    return $self;
}

=item element([name])

Set or get the element name

=cut
sub element
{
    my $self = shift;
    if (@_) { $self->{ELEMENT} = shift }

    return $self->{ELEMENT};
}

=item table([name])

Set or get the table name

=cut
sub table
{
    my $self = shift;
    if (@_) { $self->{TABLE} = shift }

    return $self->{TABLE};
}

=item key([$key|@key])

Set or get the key name(s). 

=cut
sub key
{
    my $self = shift;
    if (@_) 
    { 
        my $data = shift;
        if(ref($data) eq "ARRAY")
        {
            $self->{KEYNAME} = $data;
        }
        elsif(ref($data) eq "")
        {
            $self->{KEYNAME} = [$data];
        }
    }
    return $self->{KEYNAME};
}


=item sync

Start the sync process

=cut
sub sync
{
    my $self = shift;
    my $xmlfile = "";

    if(defined $self->{FROMDIR} && -d $self->{FROMDIR})
    {
	    $xmlfile = $self->{FROMDIR}."/".$self->{ELEMENT}.".xml";
    }
    else
    {
    	$xmlfile = $self->_requestData();
    	if(!$xmlfile)
    	{
        	return 1;
    	}
    }

    if(defined $self->{TODIR})
    {
	    return 0;
    }
    else
    {
    	my $ret = $self->_parseXML($xmlfile);
        if($ret)
        {
            return $ret;
        }
        $ret = $self->_updateDB();
        delete $self->{XML}->{DATA}->{$self->{ELEMENT}};
        return $ret;
    }
}


sub _requestData
{
    my $self    = shift;

    my $destdir = $self->{TEMPDIR};
    if(defined $self->{TODIR} && -d $self->{TODIR})
    {
         $destdir = $self->{TODIR};
    }

    my $uri = URI->new($self->{URI});
    $uri->query("command=regdata&lang=en-US&version=1.0");
    
    my %a = ("xmlns" => "http://www.novell.com/xml/center/regsvc-1_0",
             "client_version" => "1.2.3",
             "lang" => "en");

    my $content = "";
    my $writer = new XML::Writer(NEWLINES => 0, OUTPUT => \$content);
    $writer->xmlDecl();
    $writer->startTag($self->{ELEMENT}, %a);
    
    $writer->startTag("authuser");
    $writer->characters($self->{AUTHUSER});
    $writer->endTag("authuser");

    $writer->startTag("authpass");
    $writer->characters($self->{AUTHPASS});
    $writer->endTag("authpass");
    
    $writer->startTag("smtguid");
    $writer->characters($self->{SMTGUID});
    $writer->endTag("smtguid");
    
    $writer->endTag($self->{ELEMENT});
    
    my $response = "";
    my $redirects = 0;
    
    do
    {
        printLog($self->{LOG}, "debug", "Send to '$uri' content: $content") if($self->{DEBUG});

        eval
        {
            $response = $self->{USERAGENT}->post( $uri->as_string(), {},
                                                  ':content_file' => $destdir."/".$self->{ELEMENT}.".xml",
                                                  'Content' => $content);
        };
        if($@)
        {
            printLog($self->{LOG}, "error", sprintf(__("Failed to POST '%s'"), 
                                                    $uri->as_string()));
            if($self->{DEBUG})
            {
                printLog($self->{LOG}, "debug", $@);
            }
            return undef;
        }

        # enable this if you want to have a trace
        #printLog($self->{LOG}, "debug", Data::Dumper->Dump([$response]));
        
        printLog($self->{LOG}, "debug", "Result: ".$response->code()." ".$response->message()) if($self->{DEBUG});

        if ( $response->is_redirect )
        {
            $redirects++;
            if($redirects > $self->{MAX_REDIRECTS})
            {
                printLog($self->{LOG}, "error", "Reach maximal redirects. Abort");
                return undef;
            }
            
            my $newuri = $response->header("location");
            
            printLog($self->{LOG}, "debug", "Redirected to $newuri") if($self->{DEBUG});
            $uri = URI->new($newuri);
        }
    } while($response->is_redirect);
    
    if( $response->is_success && -e $destdir."/".$self->{ELEMENT}.".xml")
    {
        if($self->{DEBUG})
        {
            open(CONT, "< $destdir/".$self->{ELEMENT}.".xml") and do
            {
                my @c = <CONT>;
                close CONT;
                printLog($self->{LOG}, "debug", "Content:".join("\n", @c));
            };
        }
        
        return $destdir."/".$self->{ELEMENT}.".xml";
    }
    else
    {
        # FIXME: was 'die'; check if we should stop if a download failed
        printLog($self->{LOG}, "error", "Failed to POST '".$uri->as_string()."': ".$response->status_line);
        return undef;
    }
}

sub _parseXML
{
    my $self    = shift;
    my $xmlfile = shift;

    if(! -e $xmlfile)
    {
        printLog($self->{LOG}, "error", "File '$xmlfile' does not exist.");
        return 1;
    }

    my $parser = SMT::Parser::RegData->new();
    $parser->parse($xmlfile, sub { ncc_handler($self, @_); });

    return 0;
}

sub ncc_handler
{
    my $self = shift;
    my $data = shift;

    my $root = $data->{MAINELEMENT};
    delete $data->{MAINELEMENT};

    if(lc($root) eq "productdata")
    {
        $data->{PRODUCTLOWER} = undef;
        $data->{VERSIONLOWER} = undef;
        $data->{RELLOWER}     = undef;
        $data->{ARCHLOWER}    = undef;

        if(exists $data->{RELEASE} && defined $data->{RELEASE})
        {
            # fix RELEASE => REL
            $data->{REL} = $data->{RELEASE};
            delete $data->{RELEASE};
        }        

        if(exists $data->{PARAM} && defined $data->{PARAM})
        {
            # fix PARAM => PARAMLIST
            $data->{PARAMLIST} = $data->{PARAM};
            delete $data->{PARAM};
        }        


        $data->{PRODUCTLOWER} = lc($data->{PRODUCT}) if(exists $data->{PRODUCT} && defined $data->{PRODUCT});
        $data->{VERSIONLOWER} = lc($data->{VERSION}) if(exists $data->{VERSION} && defined $data->{VERSION});
        $data->{RELLOWER}     = lc($data->{REL}) if(exists $data->{REL} && defined $data->{REL});
        $data->{ARCHLOWER}    = lc($data->{ARCH}) if(exists $data->{ARCH} && defined $data->{ARCH});
    }
        
    push @{$self->{XML}->{DATA}->{$root}}, $data; 
}



sub _updateDB
{
    my $self  = shift;

    my $table = $self->{TABLE};
    my $key   = $self->{KEYNAME};
    
    if(!defined $table || $table eq "")
    {
        printLog($self->{LOG}, "error", "Invalid table name");
        return 1;
    }
    if(!defined $key || ref($key) ne "ARRAY")
    {
        printLog($self->{LOG}, "error", "Invalid key element.");
        return 1;
    }
    
    if(! exists $self->{XML}->{DATA}->{$self->{ELEMENT}})
    {
        # data not available; no need to update the database
        printLog($self->{LOG}, "warn", "WARNING: No content for $self->{ELEMENT}");
        return 1;
    }
    
    my $dbh = SMT::Utils::db_connect();
    if(!defined $dbh)
    {
        printLog($self->{LOG}, "error", "Cannot connect to database.");
        return 1;
    }

    # get all datasets which are from NCC
    my $stm = sprintf("SELECT %s FROM %s WHERE SRC='N'", join(',', @$key), $table);
    
    printLog($self->{LOG}, "debug", "STATEMENT: $stm") if($self->{DEBUG});
    
    my $alln = $dbh->selectall_arrayref($stm, {Slice=>{}});
    
    my $allhash = {};
    
    foreach my $sv (@{$alln})
    {
        my $str = "";
        my $j=0;
        foreach my $k (@$key) 
        {
            $str .= "-" if($j > 0);
            $str .= $sv->{$k};
            $j++;
        }
        $allhash->{$str} = 1;
    }
    
    foreach my $row (@{$self->{XML}->{DATA}->{$self->{ELEMENT}}})
    {
        my @primkeys_where = ();
        my $str = "";
        my $j=0;
        foreach (@$key) 
        {
            push @primkeys_where, "$_=".$dbh->quote($row->{$_});
            $str .= "-" if($j > 0);
            $str .= $row->{$_};
            $j++;
        }
        delete $allhash->{$str} if(exists $allhash->{$str});

        # does the key exists in the db?
        my $st = sprintf("SELECT %s FROM %s WHERE %s", 
                         join(',', @$key), $table, join(' AND ', @primkeys_where));
        
        printLog($self->{LOG}, "debug", "STATEMENT: $st") if($self->{DEBUG});
                    
        my $all = $dbh->selectall_arrayref($st);

        printLog($self->{LOG}, "debug", Data::Dumper->Dump([$all]))  if($self->{DEBUG});

        # special handling for catalogs table
        # LOCALPATH is required
        if(lc($table) eq "catalogs")
        {
            if(lc($row->{CATALOGTYPE}) eq "nu" || lc($row->{CATALOGTYPE}) eq "yum")
            {
                $row->{LOCALPATH} = '$RCE/'.$row->{NAME}."/".$row->{TARGET};
            }
            else
            {
                # we need to check if this is ATI or NVidia SP1 repos and have to rename it
                
                if($row->{NAME} eq "ATI-Drivers" && $row->{EXTURL} =~ /sle10sp1/)
                {
                    $row->{NAME} = $row->{NAME}."-SP1";
                }
                elsif($row->{NAME} eq "nVidia-Drivers" && $row->{EXTURL} =~ /sle10sp1/)
                {
                    $row->{NAME} = $row->{NAME}."-SP1";
                }
                
                $row->{LOCALPATH} = 'RPMMD/'.$row->{NAME};
            }
        }

        
        # PRIMARY KEY exists in DB, do update
        if(@$all == 1)
        {
            my $statement = "UPDATE $table SET ";
            my @pairs = ();
            foreach my $cn (keys %$row)
            {
                next if( grep( ($_ eq $cn), @$key ) );

                if(!defined $row->{$cn} || lc($row->{$cn}) eq "null")
                {
                    push @pairs, "$cn = NULL";
                }
                else
                {
                    push @pairs, "$cn = ".$dbh->quote($row->{$cn});
                }
            }
            
            # if all columns of a table are part of the primary key 
            # no update is needed. We found this with the select above.
            # This row is up-to-date.
            next if(@pairs == 0);
            
            $statement .= join(', ', @pairs);

            $statement .= " WHERE ".join(' AND ', @primkeys_where);
            
            printLog($self->{LOG}, "debug", "STATEMENT: $statement") if($self->{DEBUG});

            eval
            {
                $dbh->do($statement);
            };
            if($@)
            {
                printLog($self->{LOG}, "error", "$@");
            }
        }
        # PRIMARY KEY does not exists in DB, do insert
        elsif(@$all == 0)
        {
            my $statement = "INSERT INTO $table (";
            my @k = ();
            my @v = ();
            foreach my $cn (keys %$row)
            {
                push @k, $cn;
                if(!defined $row->{$cn} || lc($row->{$cn}) eq "null")
                {
                    push @v, "NULL";
                }
                else
                {
                    push @v, $dbh->quote($row->{$cn});
                }
            }

            $statement .= join(',', @k);
            $statement .= ") VALUES (";
            $statement .= join(',', @v);
            $statement .= ")";
            
            printLog($self->{LOG}, "debug", "STATEMENT: $statement") if($self->{DEBUG});
            
            eval
            {
                $dbh->do($statement);
            };
            if($@)
            {
                printLog($self->{LOG}, "error", "$@");
            }
        }
        else
        {
            # more then one element by selecting the keyvalue - evil
            printLog($self->{LOG}, "error", "ERROR: invalid key value '$key'");
        }
    }

    #printLog($self->{LOG}, "debug", "ALLHASH END: ".Data::Dumper->Dump([$allhash]));

    # delete all which where not touched but from NCC and no custom value
    foreach my $set (keys %{$allhash})
    {
        my @primkeys_where = ();
        if(@$key > 1)
        {
            my @vals = split(/-/, $set);
            
            for(my $j=0; $j < @vals; $j++)
            {
                push @primkeys_where, $key->[$j]." = ".$dbh->quote($vals[$j]);
            }
        }
        elsif(@$key == 1)
        {
            push @primkeys_where, $key->[0]." = ".$dbh->quote($set);
        }
        
        my $delstr = sprintf("DELETE from %s where %s", $table, join(' AND ', @primkeys_where));
                    
        my $res = $dbh->do($delstr);

        printLog($self->{LOG}, "debug", "STATEMENT: $delstr Result: $res") if($self->{DEBUG});
    }
    
    $dbh->disconnect;
    return 0;
}

=back

=head1 AUTHOR

mc@suse.de

=head1 COPYRIGHT

Copyright 2007, 2008, 2009 SUSE LINUX Products GmbH, Nuernberg, Germany.

=cut

1;

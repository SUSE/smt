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
    $self->{LOG}   = undef;
    # Do _NOT_ set env_proxy for LWP::UserAgent, this would break https proxy support
    $self->{USERAGENT}  = LWP::UserAgent->new(keep_alive => 1);
    push @{ $self->{USERAGENT}->requests_redirectable }, 'POST';
    # FIXME: remove http for production
    $self->{USERAGENT}->protocols_allowed( [ 'http', 'https'] );
    #$self->{USERINFO} = "";

    $self->{AUTHUSER} = "";
    $self->{AUTHPASS} = "";
    
    $self->{SMTGUID} = SMT::Utils::getSMTGuid();

    $self->{TEMPDIR} = File::Temp::tempdir(CLEANUP => 1);

    $self->{ELEMENT} = "";
    $self->{TABLE}   = "";
    $self->{KEYNAME}     = [];
    
    $self->{XML}->{DATA}    = {};

    $self->{FROMDIR} = undef;
    $self->{TODIR}   = undef;
    
    if(exists $ENV{http_proxy})
    {
        $self->{USERAGENT}->proxy("http",  $ENV{http_proxy});
    }

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

# element property
sub element
{
    my $self = shift;
    if (@_) { $self->{ELEMENT} = shift }

    return $self->{ELEMENT};
}

# table property
sub table
{
    my $self = shift;
    if (@_) { $self->{TABLE} = shift }

    return $self->{TABLE};
}

# keyproperty
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
    	$self->_parseXML($xmlfile);
    	return $self->_updateDB();
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
    #$uri->userinfo($self->{USERINFO});
    $uri->query("command=regdata&lang=en-US&version=1.0");
    
    my %a = ("xmlns" => "http://www.novell.com/xml/center/regsvc-1_0",
             "client_version" => "1.2.3",
             "lang" => "en");

    my $content = "";
    my $writer = new XML::Writer(NEWLINES => 1, OUTPUT => \$content);
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
    

    my $response = $self->{USERAGENT}->post( $uri->as_string(),
                                             ':content_file' => $destdir."/".$self->{ELEMENT}.".xml",
                                             'Content' => $content);
    
    if ( $response->is_redirect )
    {
        printLog($self->{LOG}, "debug", "Redirected") if($self->{DEBUG});
        return undef;
    }
    
    if( $response->is_success )
    {
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
        exit 1;
    }
    if(!defined $key || ref($key) ne "ARRAY")
    {
        printLog($self->{LOG}, "error", "Invalid key element.");
        exit 1;
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
        exit 1;
    }
    
    foreach my $row (@{$self->{XML}->{DATA}->{$self->{ELEMENT}}})
    {
        my @primkeys_where = ();
        foreach (@$key) 
        {
            push @primkeys_where, "$_=".$dbh->quote($row->{$_});
        }

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
            if(lc($row->{CATALOGTYPE}) eq "nu")
            {
                $row->{LOCALPATH} = '$RCE/'.$row->{NAME}."/".$row->{TARGET};
            }
            else
            {
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

                push @pairs, "$cn = ".$dbh->quote($row->{$cn});
            }
            
            # if all columns of a table are part of the primary key 
            # no update is needed. We found this with the select above.
            # This row is up-to-date.
            next if(@pairs == 0);
            
            $statement .= join(', ', @pairs);

            $statement .= " WHERE ".join(' AND ', @primkeys_where);
            
            printLog($self->{LOG}, "debug", "STATEMENT: $statement") if($self->{DEBUG});

            $dbh->do($statement);
            
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
                push @v, $dbh->quote($row->{$cn});
            }

            $statement .= join(',', @k);
            $statement .= ") VALUES (";
            $statement .= join(',', @v);
            $statement .= ")";
            
            printLog($self->{LOG}, "debug", "STATEMENT: $statement") if($self->{DEBUG});
            
            $dbh->do($statement);
        }
        else
        {
            # more then one element by selecting the keyvalue - evil
            printLog($self->{LOG}, "error", "ERROR: invalid key value '$key'");
        }
    }
    $dbh->disconnect;
    return 0;
}

1;





package YEP::Mirror::RegData;
use strict;

use LWP::UserAgent;
use URI;
use XML::Parser;
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


###############################################################################
## TEST DATA
###############################################################################

my $testdata_products = '<?xml version="1.0" encoding="UTF-8"?>
<product xmlns="http://www.novell.com/xml/center/regsvc-1_0">
<row>
  <col name="PRODUCTDATAID">436</col>
  <col name="PRODUCT">SUSE-Linux-Enterprise-Server-SP1</col>
  <col name="VERSION">10</col>
  <col name="RELEASE" />
  <col name="ARCH">i686</col>
  <col name="PRODUCTLOWER">suse-linux-enterprise-server-sp1</col>
  <col name="VERSIONLOWER">10</col>
  <col name="RELEASELOWER" />
  <col name="ARCHLOWER">i686</col>
  <col name="FRIENDLY">SUSE Linux Enterprise Server 10 SP1</col>
  <col name="PARAMLIST"><![CDATA[<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
        <guid description="" class="mandatory"/>
        <param id="secret" description="" command="zmd-secret" class="mandatory"/>
        <host description=""/>
        <product description="" class="mandatory"/>
        <param id="ostarget" description="" command="zmd-ostarget" class="mandatory"/>
        <param id="ostarget-bak" description="" command="lsb_release -sd" class="mandatory"/>
        <param id="email" description="" class="mandatory"/>
        <param id="regcode-sles" description=""/>
        <param id="moniker" description=""/>
        <param id="processor" description="" command="uname -p"/>
        <param id="platform" description="" command="uname -i"/>
        <param id="hostname" description="" command="uname -n"/>
        <param id="cpu" description="" command="hwinfo --cpu"/>
        <param id="disk" description="" command="hwinfo --disk"/>
        <param id="dsl" description="" command="hwinfo --dsl"/>
        <param id="gfxcard" description="" command="hwinfo --gfxcard"/>
        <param id="isdn" description="" command="hwinfo --isdn"/>
        <param id="memory" description="" command="hwinfo --memory"/>
        <param id="netcard" description="" command="hwinfo --netcard --nowpa"/>
        <param id="scsi" description="" command="hwinfo --scsi"/>
        <param id="sound" description="" command="hwinfo --sound"/>
        <param id="sys" description="" command="hwinfo --sys"/>
        <param id="tape" description="" command="hwinfo --tape"/>
</paramlist>]]></col>
  <col name="NEEDINFO"><![CDATA[<?xml version="1.0" encoding="UTF-8"?>
<needinfo xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="" href="">
        <guid description="" class="mandatory"/>
        <param id="secret" description="" command="zmd-secret" class="mandatory"/>
        <host description=""/>
        <product description="" class="mandatory"/>
        <param id="ostarget" description="" command="zmd-ostarget" class="mandatory"/>
        <param id="ostarget-bak" description="" command="lsb_release -sd" class="mandatory"/>
        <param id="identification" description="" page="reg.jsp?guid={guid}&amp;lang={lang}" class="mandatory">
                <param id="email" description=""/>
        </param>
        <param id="regcode-sles" description="" page="reg.jsp?guid={guid}&amp;lang={lang}"/>
        <param id="moniker" description="" page="reg.jsp?guid={guid}&amp;lang={lang}"/>
        <param id="sysident" description="">
                <param id="processor" description="" command="uname -p"/>
                <param id="platform" description="" command="uname -i"/>
                <param id="hostname" description="" command="uname -n"/>
        </param>
        <param id="hw_inventory" description="">
                <param id="cpu" description="" command="hwinfo --cpu"/>
                <param id="disk" description="" command="hwinfo --disk"/>
                <param id="dsl" description="" command="hwinfo --dsl"/>
                <param id="gfxcard" description="" command="hwinfo --gfxcard"/>
                <param id="isdn" description="" command="hwinfo --isdn"/>
                <param id="memory" description="" command="hwinfo --memory"/>
                <param id="netcard" description="" command="hwinfo --netcard --nowpa"/>
                <param id="scsi" description="" command="hwinfo --scsi"/>
                <param id="sound" description="" command="hwinfo --sound"/>
                <param id="sys" description="" command="hwinfo --sys"/>
                <param id="tape" description="" command="hwinfo --tape"/>
        </param>
        <privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</needinfo>
]]></col>
  <col name="SERVICE"><![CDATA[<service xmlns="http://www.novell.com/xml/center/regsvc-1_0" id="${mirror:id}" description="${mirror:name}" type="${mirror:type}">
        <param id="url">${mirror:url}</param>
        <group-catalogs/>
</service>
]]></col>
  <col name="PRODUCT_LIST">Y</col>
</row>
<row>
  <col name="PRODUCTDATAID">437</col>
  <col name="PRODUCT">SUSE-Linux-Enterprise-Server-SP1</col>
  <col name="VERSION">10</col>
  <col name="RELEASE" />
  <col name="ARCH">i586</col>
  <col name="PRODUCTLOWER">suse-linux-enterprise-server-sp1</col>
  <col name="VERSIONLOWER">10</col>
  <col name="RELEASELOWER" />
  <col name="ARCHLOWER">i586</col>
  <col name="FRIENDLY">SUSE Linux Enterprise Server 10 SP1</col>
  <col name="PARAMLIST"><![CDATA[<paramlist xmlns="http://something"/>  ]]></col>
  <col name="NEEDINFO"><![CDATA[ ... ]]></col>
  <col name="SERVICE"><![CDATA[ ... ]]></col>
  <col name="PRODUCT_LIST">Y</col>
</row>
<row>
  <col name="PRODUCTDATAID">9999</col>
  <col name="PRODUCT">SUSE-Linux-Enterprise-Server-SP2</col>
  <col name="VERSION">10</col>
  <col name="RELEASE" />
  <col name="ARCH">i686</col>
  <col name="PRODUCTLOWER">suse-linux-enterprise-server-sp2</col>
  <col name="VERSIONLOWER">10</col>
  <col name="RELEASELOWER" />
  <col name="ARCHLOWER">i686</col>
  <col name="FRIENDLY">SUSE Linux Enterprise Server 10 SP2</col>
  <col name="PARAMLIST"><![CDATA[<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
        <guid description="" class="mandatory"/>
        <param id="secret" description="" command="zmd-secret" class="mandatory"/>
        <host description=""/>
        <product description="" class="mandatory"/>
        <param id="ostarget" description="" command="zmd-ostarget" class="mandatory"/>
        <param id="ostarget-bak" description="" command="lsb_release -sd" class="mandatory"/>
        <param id="email" description="" class="mandatory"/>
        <param id="regcode-sles" description=""/>
        <param id="moniker" description=""/>
        <param id="processor" description="" command="uname -p"/>
        <param id="platform" description="" command="uname -i"/>
        <param id="hostname" description="" command="uname -n"/>
        <param id="cpu" description="" command="hwinfo --cpu"/>
        <param id="disk" description="" command="hwinfo --disk"/>
        <param id="dsl" description="" command="hwinfo --dsl"/>
        <param id="gfxcard" description="" command="hwinfo --gfxcard"/>
        <param id="isdn" description="" command="hwinfo --isdn"/>
        <param id="memory" description="" command="hwinfo --memory"/>
        <param id="netcard" description="" command="hwinfo --netcard --nowpa"/>
        <param id="scsi" description="" command="hwinfo --scsi"/>
        <param id="sound" description="" command="hwinfo --sound"/>
        <param id="sys" description="" command="hwinfo --sys"/>
        <param id="tape" description="" command="hwinfo --tape"/>
</paramlist>]]></col>
  <col name="NEEDINFO"><![CDATA[<?xml version="1.0" encoding="UTF-8"?>
<needinfo xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="" href="">
        <guid description="" class="mandatory"/>
        <param id="secret" description="" command="zmd-secret" class="mandatory"/>
        <host description=""/>
        <product description="" class="mandatory"/>
        <param id="ostarget" description="" command="zmd-ostarget" class="mandatory"/>
        <param id="ostarget-bak" description="" command="lsb_release -sd" class="mandatory"/>
        <param id="identification" description="" page="reg.jsp?guid={guid}&amp;lang={lang}" class="mandatory">
                <param id="email" description=""/>
        </param>
        <param id="regcode-sles" description="" page="reg.jsp?guid={guid}&amp;lang={lang}"/>
        <param id="moniker" description="" page="reg.jsp?guid={guid}&amp;lang={lang}"/>
        <param id="sysident" description="">
                <param id="processor" description="" command="uname -p"/>
                <param id="platform" description="" command="uname -i"/>
                <param id="hostname" description="" command="uname -n"/>
        </param>
        <param id="hw_inventory" description="">
                <param id="cpu" description="" command="hwinfo --cpu"/>
                <param id="disk" description="" command="hwinfo --disk"/>
                <param id="dsl" description="" command="hwinfo --dsl"/>
                <param id="gfxcard" description="" command="hwinfo --gfxcard"/>
                <param id="isdn" description="" command="hwinfo --isdn"/>
                <param id="memory" description="" command="hwinfo --memory"/>
                <param id="netcard" description="" command="hwinfo --netcard --nowpa"/>
                <param id="scsi" description="" command="hwinfo --scsi"/>
                <param id="sound" description="" command="hwinfo --sound"/>
                <param id="sys" description="" command="hwinfo --sys"/>
                <param id="tape" description="" command="hwinfo --tape"/>
        </param>
        <privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</needinfo>
]]></col>
  <col name="SERVICE"><![CDATA[<service xmlns="http://www.novell.com/xml/center/regsvc-1_0" id="${mirror:id}" description="${mirror:name}" type="${mirror:type}">
        <param id="url">${mirror:url}</param>
        <group-catalogs/>
</service>
]]></col>
  <col name="PRODUCT_LIST">Y</col>
</row>
</product>';


###############################################################################
## END TEST DATA
###############################################################################




# constructor
sub new
{
    my $pkgname = shift;
    my %opt   = @_;

    my $self  = {};

    #
    # FIXME: This is for testing without server!
    #
    $self->{TEST} = 1;
    



    $self->{URI}   = undef;
    $self->{DEBUG} = 0;
    # Do _NOT_ set env_proxy for LWP::UserAgent, this would break https proxy support
    $self->{USERAGENT}  = LWP::UserAgent->new(keep_alive => 1);
    push @{ $self->{USERAGENT}->requests_redirectable }, 'POST';
    # FIXME: remove http for production
    $self->{USERAGENT}->protocols_allowed( [ 'http', 'https'] );
    $self->{USERINFO} = "";

    $self->{TEMPDIR} = File::Temp::tempdir(CLEANUP => 1);

    $self->{ELEMENT} = "";
    $self->{TABLE}   = "";
    $self->{KEY}     = "";
    
    $self->{XML}->{ROWNUM}  = 0;
    $self->{XML}->{ROOT}    = undef;
    $self->{XML}->{CURELEM} = undef;
    $self->{XML}->{ATTR}    = undef;
    $self->{XML}->{DATA}    = {};
    
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

    if(exists $opt{key} && defined $opt{key} && $opt{key} ne "")
    {
        $self->{KEY} = $opt{key};
    }

    # get the URI from /etc/suseRegister.conf

    open(FH, "< /etc/suseRegister.conf") and do
    {
        while(<FH>)
        {
            if($_ =~ /^url\s*=\s*(\S*)\s*/ && defined $1 && $1 ne "")
            {
                $self->{URI} = $1;
                last;
            }
        }
        close FH;
    };

    # get the USERINFO - /etc/zmd/deviceid, /etc/zmd/secret

    open(FH, "< /etc/zmd/deviceid") and do
    {
        $self->{USERINFO} = <FH>;
        chomp($self->{USERINFO});
        close FH;
    };
    open(FH, "< /etc/zmd/secret") and do
    {
        my $s = <FH>;
        chomp($s);
        $self->{USERINFO} .= ":$s";
        close FH;
    };

    if(!defined $self->{URI} || $self->{URI} eq "")
    {
        die "URL not found.";
    }
    if(!defined $self->{USERINFO} || $self->{USERINFO} !~ /^.+:.+$/)
    {
        die "Invalid user informations .".$self->{USERINFO};
    }    
    
    bless($self);
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
    if (@_) { $self->{KEY} = shift }

    return $self->{KEY};
}


sub sync
{
    my $self = shift;
    

    my $xmlfile = $self->_requestData();
    if(!$xmlfile)
    {
        return 1;
    }
    
    $self->_parseXML($xmlfile);
    return $self->_updateDB();
}


sub _requestData
{
    my $self    = shift;

    my $uri = URI->new($self->{URI});
    $uri->userinfo($self->{USERINFO});
    $uri->query("command=regdata");
    
    my $content = "";
    my $writer = new XML::Writer(NEWLINES => 1, OUTPUT => \$content);
    $writer->xmlDecl();
    $writer->emptyTag($self->{ELEMENT}, xmlns => "http://www.novell.com/center/xml/regsvc10");
    
    if(!$self->{TEST})
    {
        my $response = $self->{USERAGENT}->post( $uri->as_string(), 
                                                 ':content_file' => $self->{TEMPDIR}."/".$self->{ELEMENT}.".xml",
                                                 'Content' => $content);

        if ( $response->is_redirect )
        {
            print "Redirected", "\n" if($self->{DEBUG});
            return undef;
        }
        
        if( $response->is_success )
        {
            return $self->{TEMPDIR}."/".$self->{ELEMENT}.".xml";
        }
        else
        {
            # FIXME: was 'die'; check if we should stop if a download failed
            print STDERR "Failed to POST '$uri->as_string()': ".$response->status_line."\n";
            return undef;
        }
    }
    else
    {
        # for TESTING only!
        print "SENDING POST to ".$uri->as_string()."\n";
        print "Content: $content\n";
        
        if($self->{ELEMENT} eq "product")
        {
            open(P, "> ".$self->{TEMPDIR}."/".$self->{ELEMENT}.".xml") or die "Cannot open file: $!";
            print P "$testdata_products \n";
            close P;
            print "Write file: ".$self->{TEMPDIR}."/".$self->{ELEMENT}.".xml\n";
            return $self->{TEMPDIR}."/".$self->{ELEMENT}.".xml";
        }
    }
}

sub _parseXML
{
    my $self    = shift;
    my $xmlfile = shift;

    if(! -e $xmlfile)
    {
        die "File '$xmlfile' does not exist.";
    }

    my $parser = XML::Parser->new( Handlers =>
                                   { Start => sub { handle_start_tag($self, @_) },
                                     End   => sub { handle_end_tag($self, @_) },
                                     Char  => sub { handle_char($self, @_) }
                                   });
 
    eval {
        $parser->parsefile( $xmlfile );
    };
    if($@) {
        # ignore the errors, but print them
        chomp($@);
        print STDERR "Error: $@\n";
    }
    return 0;
}

sub _updateDB
{
    my $self  = shift;

    my $table = $self->{TABLE};
    my $key   = $self->{KEY};
    
    if(!defined $table || $table eq "")
    {
        die "Invalid table name";
    }
    if(!defined $key || $key eq "")
    {
        die "Invalid key element";
    }
    
    if(! exists $self->{XML}->{DATA}->{$self->{ELEMENT}})
    {
        # data not available; no need to update the database
        print STDERR "WARNING: No content for $self->{ELEMENT}\n";
        return 1;
    }
    
    my $dbh = YEP::Utils::db_connect();
    if(!defined $dbh)
    {
        die "Cannot connect to database.";
    }
    
    my $sth_select = $dbh->prepare(sprintf("SELECT %s FROM %s WHERE %s=?", $key, $table, $key));
    
    foreach my $row (@{$self->{XML}->{DATA}->{$self->{ELEMENT}}})
    {
        # does the key exists in the db?
        $sth_select->execute( $row->{$key} );
        my $all = $sth_select->fetchall_arrayref;

        # if yes, do update
        if(@$all == 1)
        {
            my $statement = "UPDATE $table SET ";
            my @pairs = ();
            foreach my $cn (keys %$row)
            {
                next if( $cn eq $key );
                push @pairs, "$cn = ".$dbh->quote($row->{$cn});
            }
            $statement .= join(', ', @pairs);
            $statement .= " WHERE $key=".$dbh->quote($row->{$key});
            
            print "STATEMENT: $statement\n" if($self->{DEBUG});

            $dbh->do($statement);
            
        }
        # if no, do insert
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
            
            print "STATEMENT: $statement\n" if($self->{DEBUG});
            
            $dbh->do($statement);
        }
        else
        {
            # more then one element by selecting the keyvalue - evil
            print STDERR "ERROR: invalid key value '$key'\n";
        }
    }
    $dbh->disconnect;
    return 0;
}


sub handle_start_tag
{
    my $self = shift;
    my( $expat, $element, %attrs ) = @_;

    #print "Element '$element' Start: ".Data::Dumper->Dump([\%attrs])."\n";

    $self->{XML}->{CURELEM} = lc($element);

    if($self->{XML}->{CURELEM} eq "col" && exists $attrs{name} &&
       defined $attrs{name} && $attrs{name} ne "")
    {
        $self->{XML}->{ATTR} = $attrs{name};
        $self->{XML}->{DATA}->{$self->{XML}->{ROOT}}->[$self->{XML}->{ROWNUM}]->{$self->{XML}->{ATTR}} = undef;
    }
    elsif(lc($element) eq "row")
    {
        push @{$self->{XML}->{DATA}->{$self->{XML}->{ROOT}}}, {};
        $self->{XML}->{ROWNUM} = $#{$self->{XML}->{DATA}->{$self->{XML}->{ROOT}}};
    }
    elsif(!defined $self->{XML}->{ROOT})
    {
        $self->{XML}->{ROOT} = $self->{XML}->{CURELEM};
        $self->{XML}->{DATA}->{$self->{XML}->{ROOT}} = [];
        #print "ROOT: ".$self->{XML}->{ROOT}."\n";
    }

}

sub handle_end_tag
{
  my( $self, $expat, $element ) = @_;

  #print "End $element\n";
  $self->{XML}->{ATTR} = undef;

  if(lc($element) eq $self->{XML}->{ROOT})
  {
      $self->{XML}->{ROOT}= undef;
  }
}

sub handle_char
{
    my $self = shift;
    my( $expat, $string) = @_;

    #print "String: $string\n";

    if($self->{XML}->{CURELEM} eq "col" && defined $self->{XML}->{ATTR} && $self->{XML}->{ATTR} ne "")
    {
        if( !defined $self->{XML}->{DATA}->{$self->{XML}->{ROOT}}->[$self->{XML}->{ROWNUM}]->{$self->{XML}->{ATTR}} )
        {
            $self->{XML}->{DATA}->{$self->{XML}->{ROOT}}->[$self->{XML}->{ROWNUM}]->{$self->{XML}->{ATTR}} = $string;
        }
        else
        {
            $self->{XML}->{DATA}->{$self->{XML}->{ROOT}}->[$self->{XML}->{ROWNUM}]->{$self->{XML}->{ATTR}} .= $string;
        }
    }
}






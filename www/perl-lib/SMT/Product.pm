package SMT::Product;

use strict;
use warnings;
use XML::Simple;
use DBI qw(:sql_types);

use SMT::Utils;

use constant SERVERCLASSDEFAULT => {
              "AiO"=>"OS",
              "ATI"=>"ADDON",
              "Broadcom-Acer-Repo"=>"ADDON",
              "Broadcom-HP-BNB-Network"=>"ADDON",
              "Conexant-Acer-Modem"=>"ADDON",
              "DSMP"=>"ADDON",
              "HP-HWREF"=>"ADDON",
              "JBEAP"=>"OS",
              "jeos"=>"OS",
              "LSI"=>"ADDON",
              "MEEGO-1"=>"OS",
              "Moblin-2-Samsung"=>"OS",
              "Moblin-2.1-MSI"=>"OS",
              "MONO"=>"ADDON",
              "NAM-AGA"=>"OS",
              "NETIQ-AG4C"=>"ADDON",
              "nVidia"=>"ADDON",
              "OES2"=>"ADDON",
              "PUM"=>"OS",
              "RES"=>"OS",
              "SENTINEL_SERVER"=>"ADDON",
              "SLE-HAE-GEO"=>"ADDON",
              "SLE-HAE-IA"=>"ADDON",
              "SLE-HAE-PPC"=>"ADDON",
              "SLE-HAE-X86"=>"ADDON",
              "SLE-HAE-Z"=>"ADDON",
              "SLE-HAS"=>"ADDON",
              "SLE-SDK"=>"ADDON",
              "SLES-EC2"=>"OS",
              "SLES-IA"=>"OS",
              "SLESMT"=>"ADDON",
              "SLES-PPC"=>"OS",
              "SLES-X86-VMWARE"=>"OS",
              "SLES-Z"=>"OS",
              "SLE-TC"=>"ADDON",
              "SLM"=>"OS",
              "SLMS"=>"ADDON",
              "SM_ENT_MGM_S"=>"ADDON",
              "SM_ENT_MGM_V"=>"ADDON",
              "SM_ENT_MGM_Z"=>"ADDON",
              "SM_ENT_MON_S"=>"ADDON",
              "SM_ENT_MON_V"=>"ADDON",
              "SM_ENT_MON_Z"=>"ADDON",
              "SM_ENT_PROV_S"=>"ADDON",
              "SM_ENT_PROV_V"=>"ADDON",
              "SM_ENT_PROV_Z"=>"ADDON",
              "SMP"=>"OS",
              "SMS"=>"OS",
              #"STUDIOONSITE"=>"ADDON",  # old
              "STUDIOONSITE"=>"OS",
              "STUDIOONSITERUNNER"=>"OS",
              "SUSE"=>"OS",
              "Test"=>"ADDON",
              "VMDP"=>"ADDON",
              "WEBYAST"=>"ADDON",
              "WebYast-SLMS"=>"OS",
              "ZLM7"=>"ADDON",
              #"ZLM7"=>"OS",   # unknown
              "ZOS"=>"ADDON",
              "10040"=>"ADDON",
              "13319"=>"ADDON",
              #"13319"=>"OS",   # old
              "18962"=>"OS",
              "20082"=>"ADDON",
              "7260"=>"OS",
              "7261"=>"OS",
        };

sub new
{
    my $self = {
        dbid => undef,
        productdataid => undef,
        name => undef,
        version => undef,
        rel => undef,
        arch => undef,
        uiname => undef,
        prclass => undef,
        srvclass => undef
    };

    bless $self, __PACKAGE__;
    return $self;
}


sub dbId
{
    my ($self, $value) = @_;
    $self->{dbid} = $value if ($value);
    return $self->{dbid};
}

sub productDataId
{
    my ($self, $value) = @_;
    $self->{productdataid} = $value if ($value);
    return $self->{productdataid};
}

sub name
{
    my ($self, $value) = @_;
    $self->{name} = $value if ($value);
    return $self->{name};
}

sub version
{
    my ($self, $value) = @_;
    $self->{version} = $value if ($value);
    return $self->{version};
}

sub release
{
    my ($self, $value) = @_;
    $self->{rel} = $value if ($value);
    return $self->{rel};
}

sub arch
{
    my ($self, $value) = @_;
    $self->{arch} = $value if ($value);
    return $self->{arch};
}


sub uiName
{
    my ($self, $value) = @_;
    $self->{uiname} = $value if ($value);
    return $self->{uiname};
}


sub prclass
{
    my ($self, $value) = @_;
    $self->{prclass} = $value if ($value);
    return $self->{prclass};
}

sub srvclass
{
    my ($self, $value) = @_;
    $self->{srvclass} = $value if ($value);
    if( $self->{srvclass} )
    {
        return $self->{srvclass};
    }
    elsif(exists SERVERCLASSDEFAULT->{$self->{prclass}})
    {
        return SERVERCLASSDEFAULT->{$self->prclass};
    }
    return "";
}


sub findById
{
    my ($dbh, $id) = @_;

    my $sql = "select p.id,
                      p.productdataid,
                      p.product,
                      p.version,
                      p.rel,
                      p.arch,
                      p.friendly,
                      p.product_class,
                      (select distinct s.serverclass from Subscriptions s where s.product_class = p.product_class) as serverclass
                 from Products p
                where p.id = ?;";
    my $sth = $dbh->prepare($sql);
    $sth->bind_param(1, $id, SQL_INTEGER);
    $sth->execute();

    my $pdata = $sth->fetchrow_hashref();
    return undef if (not $pdata);

    my $p = new;
    $p->dbId($pdata->{id});
    $p->productDataId($pdata->{productdataid});
    $p->name($pdata->{product});
    $p->version($pdata->{version});
    $p->release($pdata->{rel});
    $p->arch($pdata->{arch});
    $p->uiName($pdata->{friendly});
    $p->prclass($pdata->{product_class});
    $p->srvclass($pdata->{serverclass});

    return $p;
}


sub asXML
{
    my $self = shift;
    my $xdata =
    {
        id => $self->dbId,
        productdataid => $self->productDataId,
        name => $self->name,
        version => $self->version,
        rel => $self->release,
        arch => $self->arch,
        uiname => $self->uiName,
        class => $self->prclass,
        serverclass => $self->srvclass
    };

    return XMLout($xdata,
        rootname => 'product',
        xmldecl => '<?xml version="1.0" encoding="UTF-8" ?>');
}


# returns XML for /products REST GET request
sub getAllAsXML
{
    my $dbh = shift;

    my $sql = "select p.id,
                      p.productdataid,
                      p.product,
                      p.version,
                      p.rel,
                      p.arch,
                      p.friendly,
                      p.product_class,
                      (select distinct s.serverclass from Subscriptions s where s.product_class = p.product_class) as serverclass,
                      p.description,
                      p.cpe,
                      p.eula_url
                 from Products p
             order by p.product, p.version, p.rel, p.arch;";

    my $sth = $dbh->prepare($sql);
    $sth->execute();
    my $data = { product => []};
    while (my $p = $sth->fetchrow_hashref())
    {
        # <product id="%s" name="%s" version="%s" rel="%s" arch="%s" uiname="%s" class="%s" serverclass="%s" cpe="%s", eulaurl="%s">
        # description
        # </product>
        my $entry = {
            id => $p->{id},
            productdataid => $p->{productdataid},
            name => $p->{product},
            version => $p->{version},
            rel => $p->{rel},
            arch => $p->{arch},
            uiname => $p->{friendly},
            class => $p->{product_class},
            serverclass => $p->{serverclass},
            cpe => $p->{cpe},
            eulaurl => $p->{eula_url},
            description => [$p->{description}]
            };
        if(! $entry->{serverclass} && exists SERVERCLASSDEFAULT->{$p->{product_class}})
        {
            $entry->{serverclass} = SERVERCLASSDEFAULT->{$p->{product_class}};
        }

        push @{$data->{product}}, $entry;
    }
    return XMLout($data,
        rootname => 'products',
        xmldecl => '<?xml version="1.0" encoding="UTF-8" ?>');
}

#
# Returns the default server class from a given product class
# or empty string if not found
#
sub defaultServerClass
{
    my $product_class = shift || return '';
    if(exists SERVERCLASSDEFAULT->{$product_class})
    {
        return SERVERCLASSDEFAULT->{$product_class};
    }
    return '';
}


1;

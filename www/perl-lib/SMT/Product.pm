package SMT::Product;

use strict;
use warnings;
use XML::Simple;
use SMT::DB;

use SMT::Utils;

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

sub findById
{
    my ($dbh, $id) = @_;

    my $sql = "SELECT p.id,
                      p.productdataid,
                      p.product,
                      p.version,
                      p.rel,
                      p.arch,
                      p.friendly,
                      p.product_class
                 FROM Products p
                WHERE p.id = ?;";
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
    };

    return XMLout($xdata,
        rootname => 'product',
        xmldecl => '<?xml version="1.0" encoding="UTF-8" ?>');
}


# returns XML for /products REST GET request
sub getAllAsXML
{
    my $dbh = shift;

    my $sql = "SELECT p.id,
                      p.productdataid,
                      p.product,
                      p.version,
                      p.rel,
                      p.arch,
                      p.friendly,
                      p.product_class,
                      p.description,
                      p.cpe,
                      p.eula_url
                 FROM Products p
             ORDER BY p.product, p.version, p.rel, p.arch;";

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
            cpe => $p->{cpe},
            eulaurl => $p->{eula_url},
            description => [$p->{description}]
            };

        push @{$data->{product}}, $entry;
    }
    return XMLout($data,
        rootname => 'products',
        xmldecl => '<?xml version="1.0" encoding="UTF-8" ?>');
}

1;

package SMT::Product;

use strict;
use warnings;
use XML::Simple;
use DBI qw(:sql_types);

use SMT::Utils;

sub new
{
    my $self = {
        dbid => undef,
        name => undef,
        version => undef,
        rel => undef,
        arch => undef,
        uiname => undef
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


sub findById
{
    my ($dbh, $id) = @_;

    my $sql = "select productdataid, product, version, rel, arch, friendly from Products where productdataid = ?;";
    my $sth = $dbh->prepare($sql);
    $sth->bind_param(1, $id, SQL_INTEGER);
    $sth->execute();

    my $pdata = $sth->fetchrow_hashref();
    return undef if (not $pdata);

    my $p = new;
    $p->dbId($pdata->{productdataid});
    $p->name($pdata->{product});
    $p->version($pdata->{version});
    $p->release($pdata->{rel});
    $p->arch($pdata->{arch});
    $p->uiName($pdata->{friendly});

    return $p;
}


sub asXML
{
    my $self = shift;
    my $xdata =
    {
        id => $self->dbId,
        name => $self->name,
        version => $self->version,
        rel => $self->release,
        arch => $self->arch,
        uiname => $self->uiName
    };

    return XMLout($xdata,
        rootname => 'product',
        xmldecl => '<?xml version="1.0" encoding="UTF-8" ?>');
}


# returns XML for /products REST GET request
sub getAllAsXML
{
    my $dbh = shift;

    my $sql = "select productdataid, product, version, rel, arch, friendly from Products;";
    my $sth = $dbh->prepare($sql);
    $sth->execute();
    my $data = { product => []};
    while (my $p = $sth->fetchrow_hashref())
    {
        # <product id="%s" name="%s" version="%s" rel="%s" arch="%s" uiname="%s"/>
        push @{$data->{product}}, {
            id => $p->{productdataid},
            name => $p->{product},
            version => $p->{version},
            rel => $p->{rel},
            arch => $p->{arch},
            uiname => $p->{friendly}
            };
    }
    return XMLout($data,
        rootname => 'products',
        xmldecl => '<?xml version="1.0" encoding="UTF-8" ?>');
}

1;

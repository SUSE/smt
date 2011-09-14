package SMT::Package;

use strict;
use warnings;
use DBI qw(:sql_types);

sub new
{
    my $data = shift;
    my $self = {
        dbid => undef,
        repoid => undef,
        patchid => undef,
        name => undef,
        epo => undef,
        ver => undef,
        rel => undef,
        arch => undef,
        DIRTY => 1
    };

    bless $self, __PACKAGE__;
    $self->setFromHash($data) if ($data);
    return $self;
}

sub dbId
{
    my ($self, $value) = @_;
    $self->{dbid} = $value if ($value);
    return $self->{dbid};
}

sub repoId
{
    my ($self, $value) = @_;
    if ($value)
    {
        $self->{DIRTY} = 1 if (defined $self->{repoid} && ! not $value eq $self->{repoid});
        $self->{repoid} = $value;
    }
    return $self->{repoid};
}

sub patchId
{
    my ($self, $value) = @_;
    if ($value)
    {
        $self->{DIRTY} = 1 if (defined $self->{patchid} && ! not $value eq $self->{patchid});
        $self->{patchid} = $value;
    }
    return $self->{patchid};
}

sub name
{
    my ($self, $value) = @_;
    if ($value)
    {
        $self->{DIRTY} = 1 if (defined $self->{name} && ! $value eq $self->{name});
        $self->{name} = $value;
    }
    return $self->{name};
}


sub epoch
{
    my ($self, $value) = @_;
    if ($value)
    {
        $self->{DIRTY} = 1 if (defined $self->{epo} && ! $value eq $self->{epo});
        $self->{epo} = $value;
    }
    return $self->{epo};
}

sub version
{
    my ($self, $value) = @_;
    if ($value)
    {
        $self->{DIRTY} = 1 if (defined $self->{ver} && ! $value eq $self->{ver});
        $self->{ver} = $value;
    }
    return $self->{ver};
}

sub release
{
    my ($self, $value) = @_;
    if ($value)
    {
        $self->{DIRTY} = 1 if (defined $self->{rel} && ! $value eq $self->{rel});
        $self->{rel} = $value;
    }
    return $self->{rel};
}

sub arch
{
    my ($self, $value) = @_;
    if ($value)
    {
        $self->{DIRTY} = 1 if (defined $self->{arch} && ! $value eq $self->{arch});
        $self->{arch} = $value;
    }
    return $self->{arch};
}


sub smtLocation
{
    my ($self, $value) = @_;
    if ($value)
    {
        $self->{DIRTY} = 1 if (defined $self->{loc} && ! $value eq $self->{loc});
        $self->{loc} = $value;
    }
    return $self->{loc};
}

sub extLocation
{
    my ($self, $value) = @_;
    if ($value)
    {
        $self->{DIRTY} = 1 if (defined $self->{extloc} && ! $value eq $self->{extloc});
        $self->{extloc} = $value;
    }
    return $self->{extloc};
}

sub NEVRA
{
    my ($self, $separator) = @_;

    return undef if (not $self->name() && $self->version() && $self->release() && $self->arch());

    $separator = ':' if (not $separator);
    my $nevra = $self->name();
    $nevra .= $separator . ($self->epoch() ? $self->epoch() : '');
    $nevra .= $separator . $self->version();
    $nevra .= $separator . $self->release();
    $nevra .= $separator . $self->arch();

    return $nevra;
}

sub setFromHash
{
    my ($self, $data) = @_;
    $self->name($data->{name});
    $self->epoch($data->{epo});
    $self->version($data->{ver});
    $self->release($data->{rel});
    $self->arch($data->{arch});
    $self->smtLocation($data->{loc});
    $self->extLocation($data->{extloc});
}


sub findById
{
    my ($dbh, $id) = @_;
}

sub findByPatchId
{
    my ($dbh, $patchid) = @_;

    my $sql = 'select * from Packages where patchid = ?';
    my $sth = $dbh->prepare($sql);
    $sth->bind_param(1, $patchid, SQL_INTEGER);
    $sth->execute();

    my $pkgs = {};

    while (my $pdata = $sth->fetchrow_hashref())
    {
        my $name = $pdata->{NAME};
        my $epo = $pdata->{EPOCH};
        my $ver = $pdata->{VER};
        my $rel = $pdata->{REL};
        my $arch = $pdata->{ARCH};

        my $p = new;
        $p->dbId($pdata->{ID});
        $p->repoId($pdata->{CATALOGID});
        $p->patchId($pdata->{PATCHID});
        $p->name($name);
        $p->epoch($epo);
        $p->version($ver);
        $p->release($rel);
        $p->arch($arch);
        $p->smtLocation($pdata->{LOCATION});
        $p->extLocation($pdata->{EXTLOCATION});
        $p->{DIRTY} = 0;

        $pkgs->{$p->NEVRA(':')} = $p;
    }

    return $pkgs;
}

sub save
{
    my ($self, $dbh) = @_;

    my $sql;
    if ($self->dbId())
    {
        $sql = 'update Packages set name=?, epoch=?, ver=?, rel=?,'
            . ' arch=?, location=?, extlocation=?, catalogid=?, patchid=?'
            . ' where id=?';
    }
    else
    {
        $sql = 'insert into Packages'
            . ' (name, epoch, ver, rel, arch, location, extlocation, catalogid, patchid)'
            . ' values (?,?,?,?,?,?,?,?,?)';
    }
    my $sth = $dbh->prepare($sql);
    $sth->bind_param(1, $self->name(), SQL_VARCHAR);
    $sth->bind_param(2, $self->epoch(), SQL_INTEGER);
    $sth->bind_param(3, $self->version(), SQL_VARCHAR);
    $sth->bind_param(4, $self->release(), SQL_VARCHAR);
    $sth->bind_param(5, $self->arch(), SQL_VARCHAR);
    $sth->bind_param(6, $self->smtLocation(), SQL_VARCHAR);
    $sth->bind_param(7, $self->extLocation(), SQL_VARCHAR);
    $sth->bind_param(8, $self->repoId(), SQL_INTEGER);
    $sth->bind_param(9, $self->patchId(), SQL_INTEGER);
    $sth->bind_param(10, $self->dbId(), SQL_INTEGER) if ($self->dbId());
    $sth->execute();

    $self->dbId($dbh->last_insert_id(undef, undef, undef, undef))
        if ( not $self->dbId());

    $self->{DIRTY} = 0;
}


sub delete
{
    my ($self, $dbh) = @_;
    return if (not $self->dbId());

    my $sql = 'delete from Packages where id=?';
    my $sth = $dbh->prepare($sql);
    $sth->bind_param(1, $self->dbId(), SQL_INTEGER);
    $sth->execute();
}

1;

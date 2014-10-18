package SMT::Package;

use strict;
use warnings;
use SMT::DB;

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
    if (defined $value)
    {
        $self->{DIRTY} = 1 if (defined $self->{ver} && ! $value eq $self->{ver});
        $self->{ver} = $value;
    }
    return $self->{ver};
}

sub release
{
    my ($self, $value) = @_;
    if (defined $value)
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

    # version or release can be "0"
    return undef if (not ($self->name() &&
                          defined $self->version() && $self->version() ne "" &&
                          defined $self->release() && $self->release() ne "" &&
                          $self->arch()));

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

    my $sth = $dbh->prepare('select * from Packages where patchid = :patchid');
    $sth->execute(patchid => $patchid);

    my $pkgs = {};

    while (my $pdata = $sth->fetchrow_hashref())
    {
        my $name = $pdata->{name};
        my $epo = $pdata->{epoch};
        my $ver = $pdata->{ver};
        my $rel = $pdata->{rel};
        my $arch = $pdata->{arch};

        my $p = new;
        $p->dbId($pdata->{id});
        $p->repoId($pdata->{repository_id});
        $p->patchId($pdata->{patch_id});
        $p->name($name);
        $p->epoch($epo);
        $p->version($ver);
        $p->release($rel);
        $p->arch($arch);
        $p->smtLocation($pdata->{location});
        $p->extLocation($pdata->{extlocation});
        $p->{DIRTY} = 0;

        $pkgs->{$p->NEVRA(':')} = $p;
    }

    return $pkgs;
}

sub save
{
    my ($self, $dbh) = @_;

    my $sth;
    if ($self->dbId())
    {
        $sth = $dbh->prepare('UPDATE Packages
                                 SET name=:name, epoch=:epoch, ver=:ver, rel=:rel,
                                     arch=:arch, location=:location, extlocation=:extlocation,
                                     repository_id=:rid, patch_id=:ptid
                              WHERE id=:pkgid');
    }
    else
    {
        $self->dbId($dbh->sequence_nextval('pkgs_id_seq'));
        $sth = $dbh->prepare('INSERT INTO Packages
                                          (id, name, epoch, ver, rel, arch,
                                           location, extlocation, repository_id, patch_id)
                                   VALUES (:pkgid, :name, :epoch, :ver, :rel, :arch,
                                           :location, :extlocation, :rid, :ptid)');
    }
    $sth->execute_h(pkgid => $self->dbId(), name => $self->name(), epoch => $self->epoch(),
                    ver => $self->version(), rel => $self->release(), arch => $self->arch(),
                    location => $self->smtLocation(), extlocation => $self->extLocation(),
                    rid => $self->repoId(), ptid => $self->patchId());
    # FIXME: make a commit at a central place ?
    $dbh->commit();
    $self->{DIRTY} = 0;
}


sub delete
{
    my ($self, $dbh) = @_;
    return if (not $self->dbId());

    my $sth = $dbh->prepare('DELETE FROM Packages where id=:id');
    $sth->execute_h(id => $self->dbId());
    # FIXME: make a commit at a central place ?
    $dbh->commit();
}

1;

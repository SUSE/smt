package SMT::PatchRef;

use strict;
use warnings;
use SMT::DB;

sub new
{
    my $data = shift;
    my $self = {
        dbid => undef,
        patchid => undef,
        id => undef,
        title => undef,
        url => undef,
        type => undef,
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

sub id
{
    my ($self, $value) = @_;
    if ($value)
    {
        $self->{DIRTY} = 1 if (defined $self->{id} && ! $value eq $self->{id});
        $self->{id} = $value;
    }
    return $self->{id};
}

sub title
{
    my ($self, $value) = @_;
    if ($value)
    {
        $self->{DIRTY} = 1 if (defined $self->{title} && ! $value eq $self->{title});
        $self->{title} = $value;
    }
    return $self->{title};
}

sub url
{
    my ($self, $value) = @_;
    if ($value)
    {
        $self->{DIRTY} = 1 if (defined $self->{url} && ! $value eq $self->{url});
        $self->{url} = $value;
    }
    return $self->{url};
}

sub type
{
    my ($self, $value) = @_;
    if ($value)
    {
        $self->{DIRTY} = 1 if (defined $self->{type} && ! $value eq $self->{type});
        $self->{type} = $value;
    }
    return $self->{type};
}


sub setFromHash
{
    my ($self, $data) = @_;
    $self->id($data->{id});
    $self->title($data->{title});
    $self->url($data->{href});
    $self->type($data->{type});
}


sub findByPatchId
{
    my ($dbh, $patchid) = @_;

    my $sth = $dbh->prepare('SELECT * FROM PatchRefs WHERE patch_id = :ptid');
    $sth->execute(ptid => $patchid);

    my $prs = {};

    while (my $pdata = $sth->fetchrow_hashref())
    {
        my $p = new;
        $p->dbId($pdata->{ID});
        $p->patchId($pdata->{PATCHID});
        $p->id($pdata->{REFID});
        $p->title($pdata->{TITLE});
        $p->type($pdata->{REFTYPE});
        $p->url($pdata->{URL});
        $p->{DIRTY} = 0;

        $prs->{$p->id()} = $p;
    }

    return $prs;
}


sub save
{
    my ($self, $dbh) = @_;

    my $sth;
    if ($self->dbId())
    {
        $sth = $dbh->prepare('UPDATE PatchRefs
                                 SET refid=:refid, reftype=:reftype, url=:url,
                                     title=:title, patch_id=:ptid
                               WHERE id=:prid');
    }
    else
    {
        $self->dbId($dbh->sequence_nextval('patchrefs_id_seq'));
        $sth = $dbh->prepare('INSERT INTO PatchRefs
                                          (id, refid, reftype, url, title, patch_id)
                                   VALUES (:prid, :refid, :reftype, :url, :title, :ptid)');
    }
    $sth->execute_h(prid => $self->dbId(), refid => $self->id(), reftype => $self->type(),
                    url => $self->url(), title => $self->title(), ptid => $self->patchId());

    # FIXME: make a commit at a central place ?
    $dbh->commit();
    $self->{DIRTY} = 0;
}


sub delete
{
    my ($self, $dbh) = @_;
    return if (not $self->dbId());

    my $sth = $dbh->prepare('DELETE FROM PatchRefs WHERE id=:prid');
    $sth->execute_h(prid => $self->dbId());
    # FIXME: make a commit at a central place ?
    $dbh->commit();
}

1;

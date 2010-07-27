package SMT::PatchRef;

use strict;
use warnings;
use DBI qw(:sql_types);

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

    my $sql = 'select * from PatchRefs where patchid = ?';
    my $sth = $dbh->prepare($sql);
    $sth->bind_param(1, $patchid, SQL_INTEGER);
    $sth->execute();

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

    my $sql;
    if ($self->dbId())
    {
        $sql = 'update PatchRefs set refid=?, reftype=?, url=?, title=?,'
            . ' patchid=? where id=?';
    }
    else
    {
        $sql = 'insert into PatchRefs'
            . ' (refid, reftype, url, title, patchid)'
            . ' values (?,?,?,?,?)';
    }
    my $sth = $dbh->prepare($sql);
    $sth->bind_param(1, $self->id(), SQL_VARCHAR);
    $sth->bind_param(2, $self->type(), SQL_VARCHAR);
    $sth->bind_param(3, $self->url(), SQL_VARCHAR);
    $sth->bind_param(4, $self->title(), SQL_VARCHAR);
    $sth->bind_param(5, $self->patchId(), SQL_INTEGER);
    $sth->bind_param(6, $self->dbId(), SQL_INTEGER) if ($self->dbId());
    $sth->execute();

    $self->dbId($dbh->last_insert_id(undef, undef, undef, undef))
        if ( not $self->dbId());

    $self->{DIRTY} = 0;
}


sub delete
{
    my ($self, $dbh) = @_;
    return if (not $self->dbId());

    my $sql = 'delete from PatchRefs where id=?';
    my $sth = $dbh->prepare($sql);
    $sth->bind_param(1, $self->dbId(), SQL_INTEGER);
    $sth->execute();
}

1;

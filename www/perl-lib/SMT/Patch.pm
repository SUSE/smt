package SMT::Patch;

use strict;
use warnings;
use DBI qw(:sql_types);
use Date::Parse;
use XML::Simple;

sub new
{
    my $data = shift;
    
    my $self = {
        dbid => undef,
        repoid => undef,
        name => undef,
        version => undef,
        summary => undef,
        desc => undef,
        category => undef,
        date => undef,
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

sub categoryAsInt
{
    my ($self, $value) = @_;
    if ($value)
    {
        $self->{DIRTY} = 1 if (defined $self->{category} && ! $value eq $self->{category});
        $self->{category} = $value;
    }
    return $self->{category};
}

sub category
{
    my ($self, $value) = @_;
    if (not $value)
    {
        if    ($self->{category} == 1) { return 'security'    }
        elsif ($self->{category} == 2) { return 'recommended' }
        elsif ($self->{category} == 3) { return 'mandatory'   }
        elsif ($self->{category} == 4) { return 'optional'    }
        else                           { return undef         }
    }
    elsif ($value eq 'security')    { $self->{category} = 1 }
    elsif ($value eq 'recommended') { $self->{category} = 2 }
    elsif ($value eq 'mandatory')   { $self->{category} = 3 }
    elsif ($value eq 'optional')    { $self->{category} = 4 }

    return undef;
}

sub summary
{
    my ($self, $value) = @_;
    if ($value)
    {
        $self->{DIRTY} = 1 if (defined $self->{summary} && ! $value eq $self->{summary});
        $self->{summary} = $value;
    }
    return $self->{summary};
}

sub description
{
    my ($self, $value) = @_;
    if ($value)
    {
        $self->{DIRTY} = 1 if (defined $self->{desc} && ! $value eq $self->{desc});
        $self->{desc} = $value;
    }
    return $self->{desc};
}

sub releaseDate
{
    my ($self, $value) = @_;
    if ($value)
    {
        $self->{DIRTY} = 1 if (defined $self->{date} && ! $value eq $self->{date});
        $self->{date} = $value;
    }
    return $self->{date};
}


sub setFromHash
{
    my ($self, $data) = @_; 
    $self->name($data->{name});
    $self->version($data->{version});
    $self->category($data->{type});
    $self->summary($data->{title});
    $self->description($data->{description});
    $self->releaseDate($data->{date});
}


sub findById
{
    my ($dbh, $id) = @_;
    
    my $sql = "select * from Patches where id = ?;";
    my $sth = $dbh->prepare($sql);
    $sth->bind_param(1, $id, SQL_INTEGER);
    $sth->execute();

    my $pdata = $sth->fetchrow_hashref();
    return undef if (not $pdata);

    my $p = new;
    $p->dbId($pdata->{ID});
    $p->repoId($pdata->{CATALOGID});
    $p->name($pdata->{NAME});
    $p->version($pdata->{VERSION});
    $p->categoryAsInt($pdata->{CATEGORY});
    $p->summary($pdata->{SUMMARY});
    $p->description($pdata->{DESCRIPTION});
    $p->releaseDate(str2time($pdata->{RELDATE}));
    $p->{DIRTY} = 0;

    return $p;
}


sub findByRepoId
{
    my ($dbh, $repoid) = @_;
    
    my $sql = 'select * from Patches where catalogid = ?';
    my $sth = $dbh->prepare($sql);
    $sth->bind_param(1, $repoid, SQL_INTEGER);
    $sth->execute();

    my $patches = {};

    while (my $pdata = $sth->fetchrow_hashref())
    {
      my $name = $pdata->{NAME};
      my $version = $pdata->{VERSION};

      my $p = new;
      $p->dbId($pdata->{ID});
      $p->repoId($pdata->{CATALOGID});
      $p->name($name);
      $p->version($version);
      $p->categoryAsInt($pdata->{CATEGORY});
      $p->summary($pdata->{SUMMARY});
      $p->description($pdata->{DESCRIPTION});
      $p->releaseDate(str2time($pdata->{RELDATE}));
      $p->{DIRTY} = 0;

      $patches->{"$name:$version"} = $p;
    }

    return $patches;
}


sub save
{
    my ($self, $dbh) = @_;

    my $sql;
    if ($self->dbId())
    {
        $sql = 'update Patches set name=?, version=?, category=?, summary=?,'
            . ' description=?, reldate=?, catalogid=?'
            . ' where id=?';
    }
    else
    {
        $sql = 'insert into Patches'
            . ' (name, version, category, summary, description, reldate, catalogid)'
            . ' values (?,?,?,?,?,?,?)';
    }
    my $sth = $dbh->prepare($sql);
    $sth->bind_param(1, $self->name(), SQL_VARCHAR);
    $sth->bind_param(2, $self->version(), SQL_VARCHAR);
    $sth->bind_param(3, $self->categoryAsInt(), SQL_INTEGER);
    $sth->bind_param(4, $self->summary(), SQL_VARCHAR);
    $sth->bind_param(5, $self->description(), SQL_VARCHAR);
    $sth->bind_param(6, POSIX::strftime("%Y-%m-%d %H:%M", localtime($self->releaseDate())), SQL_TIMESTAMP);
    $sth->bind_param(7, $self->repoId(), SQL_INTEGER);
    $sth->bind_param(8, $self->dbId(), SQL_INTEGER) if ($self->dbId());
    $sth->execute();

    $self->dbId($dbh->last_insert_id(undef, undef, undef, undef))
        if ( not $self->dbId());

    $self->{DIRTY} = 0;
}


sub delete
{
    my ($self, $dbh) = @_;
    return if (not $self->dbId());

    my $sql = 'delete from Patches where id=?';
    my $sth = $dbh->prepare($sql);
    $sth->bind_param(1, $self->dbId(), SQL_INTEGER);
    $sth->execute();
}


sub getRepoPatchesAsXML
{
    my ($dbh, $repoid) = @_;
    
    my $patches = findByRepoId($dbh, $repoid);
    my $xdata = {'patch' => []};
    
    foreach my $patch (values %$patches)
    {
      my $pdata = {};
      $pdata->{id} = $patch->dbId();
      $pdata->{category} = $patch->category();
      $pdata->{name} = $patch->name();
      $pdata->{version} = $patch->version();
      push @{$xdata->{patch}}, $pdata;
    }

    return XMLout($xdata,
        rootname => 'patches',
        xmldecl => '<?xml version="1.0" encoding="UTF-8" ?>');
}

sub asXML
{
    my $self = shift;

    my $xdata = {
        id => $self->dbId(),
        category => $self->category(),
        name => $self->name(),
        version => $self->version(),
        title => [$self->summary()],
        description => [$self->description()]
    };

    return XMLout($xdata,
        rootname => 'patch',
        xmldecl => '<?xml version="1.0" encoding="UTF-8" ?>');
}


1;

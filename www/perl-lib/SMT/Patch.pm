package SMT::Patch;

use strict;
use warnings;
use SMT::DB;
use Date::Parse;
use XML::Simple;

use SMT::Package;
use SMT::PatchRef;

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
        pkgs => {},
        refs => {},
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
        $self->{DIRTY} = 1 if (defined $self->{version} && ! $value eq $self->{version});
        $self->{version} = $value;
    }

    # make sure the returned value is a string. A 0 would case DBI to insert
    # NULL into the DB query, which would cause an error
    return '' if (not defined $self->{version});
    return $self->{version};
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
        elsif ($self->{category} == 5) { return 'feature'     }
        else                           { return undef         }
    }
    else
    {
      my $oldcat = $self->{category} || 0;
      if    ($value eq 'security')    { $self->{category} = 1 }
      elsif ($value eq 'recommended') { $self->{category} = 2 }
      elsif ($value eq 'bugfix')      { $self->{category} = 2 }
      elsif ($value eq 'mandatory')   { $self->{category} = 3 }
      elsif ($value eq 'optional')    { $self->{category} = 4 }
      elsif ($value eq 'feature')     { $self->{category} = 5 }
      elsif ($value eq 'enhancement') { $self->{category} = 5 }
      else
      {
        $self->{category} = 4; # default to 'optional'
        # FIXME enable logging here and log this
      }
      $self->{DIRTY} = 1 if ($oldcat != $self->{category});
    }

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
    return '' if (not defined $self->{summary});
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
    return '' if (not defined $self->{desc});
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

sub packages
{
    my $self = shift;
    return $self->{pkgs};
}

sub setPackages
{
    my ($self, $pkgs) = @_;

    # first remove all Patch's packages not found in given $pkgs
    foreach my $nevra (keys %{$self->{pkgs}})
    {
        delete $self->{pkgs}->{$nevra} if (not defined $pkgs->{$nevra});
    }

    # replace existing with those given, keeping dbId, and add new ones
    foreach my $nevra (keys %$pkgs)
    {
        my $p = $pkgs->{$nevra};
        if (defined $self->{pkgs}->{$nevra})
        {
            $p->dbId($self->{pkgs}->{$nevra}->dbId()) if ($self->{pkgs}->{$nevra}->dbId());
        }
        $self->{pkgs}->{$nevra} = $p;
    }

    # if new set of packages is empty, set also Patch's packages to empty
    $self->{pkgs} = {} if (not keys %$pkgs);
}

sub references
{
    my $self = shift;
    return $self->{refs};
}

sub setReferences
{
    my ($self, $refs) = @_;

    # first remove all Patch's references not found in given $refs
    foreach my $refid (keys %{$self->{refs}})
    {
        delete $self->{refs}->{$refid} if (not defined $refs->{$refid});
    }

    # replace existing with those given, keeping dbId, and add new ones
    foreach my $refid (keys %$refs)
    {
        my $r = $refs->{$refid};
        if (defined $self->{refs}->{$refid})
        {
            $r->dbId($self->{refs}->{$refid}->dbId()) if ($self->{refs}->{$refid}->dbId());
        }
        $self->{refs}->{$refid} = $r;
    }

    # if new set of references is empty, set also Patch's references to empty
    $self->{refs} = {} if (not keys %$refs);
}



=item
Expects data in the form as in the following example:

 $data = {
      'pkgs' => [
            {
              'rel' => '1.3',
              'epo' => undef,
              'arch' => 'i586',
              'ver' => '11',
              'name' => 'sle-smt-release'
            },
            {
              'rel' => '1.3',
              'epo' => undef,
              'arch' => 'i586',
              'ver' => '11',
              'name' => 'sle-smt-release-cd'
            }
          ],
      'date' => '1267545307',
      'version' => '2095',
      'name' => 'slesmtsp0-sle-smt-release',
      'description' => 'Long description of the patch',
      'targetrel' => 'Subscription Management Tool 11',
      'refs' => [
            {
              'href' => 'https://bugzilla.novell.com/show_bug.cgi?id=570637',
              'type' => 'bugzilla',
              'title' => 'bug number 570637',
              'id' => '570637'
            },
            {
              'href' => 'https://bugzilla.novell.com/show_bug.cgi?id=558871',
              'type' => 'bugzilla',
              'title' => 'bug number 558871',
              'id' => '558871'
            }
          ],
      'type' => 'recommended',
      'title' => 'Recommended update for Subscription Management Tool (SMT)'
    };

=cut
sub setFromHash
{
    my ($self, $data) = @_;
    $self->name($data->{name});
    $self->version($data->{version});
    $self->category($data->{type});
    $self->summary($data->{title});
    $self->description($data->{description});
    $self->releaseDate($data->{date});

    my $pkgs = {};
    foreach my $pdata (@{$data->{pkgs}})
    {
        my $pkg = SMT::Package::new($pdata);
        $pkgs->{$pkg->NEVRA()} = $pkg;
    };
    $self->setPackages($pkgs);

    my $refs = {};
    foreach my $rdata (@{$data->{refs}})
    {
        my $r = SMT::PatchRef::new($rdata);
        $refs->{$r->id()} = $r;
    };
    $self->setReferences($refs);
}


sub findById
{
    my ($dbh, $id) = @_;

    my $sth = $dbh->prepare("SELECT * FROM Patches WHERE id = :id");
    $sth->execute_h(id => $id);

    my $pdata = $sth->fetchrow_hashref();
    return undef if (not $pdata);

    my $p = new;
    $p->dbId($pdata->{id});
    $p->repoId($pdata->{repository_id});
    $p->name($pdata->{name});
    $p->version($pdata->{version});
    $p->categoryAsInt($pdata->{category});
    $p->summary($pdata->{summary});
    $p->description($pdata->{description});
    $p->releaseDate(str2time($pdata->{reldate}));
    $p->setPackages(SMT::Package::findByPatchId($dbh, $p->dbId()));
    $p->setReferences(SMT::PatchRef::findByPatchId($dbh, $p->dbId()));
    $p->{DIRTY} = 0;

    return $p;
}


sub findByRepoId
{
    my ($dbh, $repoid) = @_;

    my $sth = $dbh->prepare('SELECT * FROM Patches WHERE repository_id = :id');
    $sth->execute_h(id => $repoid);

    my $patches = {};

    while (my $pdata = $sth->fetchrow_hashref())
    {
      my $name = $pdata->{name};
      my $version = $pdata->{version};

      my $p = new;
      $p->dbId($pdata->{id});
      $p->repoId($pdata->{repository_id});
      $p->name($name);
      $p->version($version);
      $p->categoryAsInt($pdata->{category});
      $p->summary($pdata->{summary});
      $p->description($pdata->{description});
      $p->releaseDate(str2time($pdata->{reldate}));
      $p->setPackages(SMT::Package::findByPatchId($dbh, $p->dbId()));
      $p->setReferences(SMT::PatchRef::findByPatchId($dbh, $p->dbId()));
      $p->{DIRTY} = 0;

      $patches->{"$name:$version"} = $p;
    }

    return $patches;
}


sub save
{
    my ($self, $dbh) = @_;

    my $sth;
    if ($self->dbId())
    {
        $sth = $dbh->prepare('UPDATE Patches
                                 SET name=:name, version=:version, category=:cat,
                                     summary=:sum, description=:desc, reldate=:rdate,
                                     repository_id=:rid
                               WHERE id=:ptid');
    }
    else
    {
        $self->dbId($dbh->sequence_nextval('patches_id_seq'));
        $sth = $dbh->prepare('INSERT INTO Patches
                                          (id, name, version, category, summary,
                                           description, reldate, repository_id)
                                   VALUES (:ptid, :name, :version, :cat, :sum,
                                           :desc, :rdate, :rid)');
    }
    $sth->execute_h(ptid => $self->dbId(), name => $self->name(), version => $self->version(),
                    cat => $self->categoryAsInt(), sum => $self->summary(),
                    desc => $self->description(),
                    rdate => POSIX::strftime("%Y-%m-%d %H:%M", localtime($self->releaseDate())),
                    rid => $self->repoId());
    # FIXME: make a commit at a central place ?
    $dbh->commit();
    #$sth->bind_param(1, $self->name(), SQL_VARCHAR);
    #$sth->bind_param(2, $self->version(), SQL_VARCHAR);
    #$sth->bind_param(3, $self->categoryAsInt(), SQL_INTEGER);
    #$sth->bind_param(4, $self->summary(), SQL_VARCHAR);
    # bnc#723571 - Description in the DB is only a varchar(1024)
    #              So it does not make sense to put more into it.
    #$sth->bind_param(5, substr($self->description(), 0, 1024), SQL_VARCHAR);
    #$sth->bind_param(6, POSIX::strftime("%Y-%m-%d %H:%M", localtime($self->releaseDate())), SQL_TIMESTAMP);
    #$sth->bind_param(7, $self->repoId(), SQL_INTEGER);
    #$sth->bind_param(8, $self->dbId(), SQL_INTEGER) if ($self->dbId());

    # load old packages
    my $oldpkgs = SMT::Package::findByPatchId($dbh, $self->dbId());
    # save current packages
    foreach my $pkg (values %{$self->packages()})
    {
        $pkg->patchId($self->dbId());
        $pkg->repoId($self->repoId());
        $pkg->dbId($oldpkgs->{$pkg->NEVRA()}->dbId()) if (defined $oldpkgs->{$pkg->NEVRA()});
        $pkg->save($dbh);
        delete $oldpkgs->{$pkg->NEVRA()} if (defined $oldpkgs->{$pkg->NEVRA()});
    }
    # delete the olds which are not among current
    foreach my $pkg (values %$oldpkgs) { $pkg->delete($dbh); }

    # load old references
    my $oldrefs = SMT::PatchRef::findByPatchId($dbh, $self->dbId());
    # save current refs
    foreach my $ref (values %{$self->references()})
    {
        $ref->patchId($self->dbId());
        $ref->dbId($oldrefs->{$ref->id()}->dbId()) if (defined $oldrefs->{$ref->id()});
        $ref->save($dbh);
        delete $oldrefs->{$ref->id()} if (defined $oldrefs->{$ref->id()});
    }
    # delete the olds which are not among current
    foreach my $ref (values %$oldrefs) { $ref->delete($dbh); }

    $self->{DIRTY} = 0;
}


sub delete
{
    my ($self, $dbh) = @_;
    return if (not $self->dbId());

    foreach my $ref (values %{$self->references()}) { $ref->delete($dbh); }
    foreach my $pkg (values %{$self->packages()}  ) { $pkg->delete($dbh); }

    my $sth = $dbh->prepare('DELETE FROM Patches WHERE id=:id');
    $sth->execute_h(id => $self->dbId());
    # FIXME: make a commit at a central place ?
    $dbh->commit();
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
        issued => [{date => $self->releaseDate()}],
        title => [$self->summary()],
        description => [$self->description()],
        packages => {package=>[]},
        references => {reference=>[]}
    };

    foreach my $p (values %{$self->packages()})
    {
        my $pdata = {
            name => $p->name(),
            epoch => $p->epoch(),
            version => $p->version(),
            release => $p->release(),
            arch => $p->arch(),
            smtlocation => [$p->smtLocation()],
            origlocation => [$p->extLocation()]
        };
        push @{$xdata->{packages}->{package}}, $pdata;
    }

    foreach my $r (values %{$self->references()})
    {
        my $rdata = {
            id => $r->id(),
            title => $r->title(),
            href => $r->url(),
            type => $r->type()
        };
        push @{$xdata->{references}->{reference}}, $rdata;
    }

    return XMLout($xdata,
        rootname => 'patch',
        xmldecl => '<?xml version="1.0" encoding="UTF-8" ?>');
}


1;

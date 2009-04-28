package SMT::Filter;

use strict;
use warnings "all";

use SMT::Utils;        # for db_connect
use DBI;               # for save/load
use DBI qw(:sql_types);

=head1 NAME

SMT::Filter - reads/stores patch filters for catalogs and tells whether
  a patch matches the filter.
  
=head1 SYNOPSIS

  # to get a filter object
  my $filter = SMT::Filter->new();
  my $filter = SMT::Filte->load($dbh, $catalogid);

  # to store into db
  $filter->save($dbh, $catalogid);

  # to edit existing filter
  $filter->add($filtertype, $value);
  $filter->remove($filtertype, $value);
  $filter->removeall();

  # the core subroutine :O)
  $filter->matches($patchdata);

=head1 DESCRIPTION

TODO
=cut

=head1 CONSTANTS

=over 4

=item Filter Types
TYPE_NAME_EXACT
    matches if the patch name is the same as the filter value     
TYPE_NAME_REGEX
    matches if the patch name matches the perl regex in filter value
TYPE_NAME_VERSION
    matches if the patch ID ("$name-$version") is the same as the filter value 
TYPE_SECURITY_LEVEL 
    matches if the patch category string is the same as the filter value
=cut
use constant {
    TYPE_NAME_EXACT     => 1,
    TYPE_NAME_REGEX     => 2,
    TYPE_NAME_VERSION   => 3,
    TYPE_SECURITY_LEVEL => 4
};

sub is_whole_number { $_[0] =~ /^\d+$/ }

=back

=head1 METHODS

=over 4

=item new()

Constructor.

=cut
sub new
{
    my $class = shift;
    my %opt   = @_;
    my $self  = {};

    $self->{FILTERS} = [];
    $self->{DIRTY} = 0;

    # set up logger

    $self->{VBLEVEL} = 0;
    $self->{LOG} = undef;

    if(exists $opt{vblevel} && defined $opt{vblevel})
    {
        $self->{VBLEVEL} = $opt{vblevel};
    }

    if(exists $opt{log} && defined $opt{log} && $opt{log})
    {
        $self->{LOG} = $opt{log};
    }
    else
    {
        $self->{LOG} = SMT::Utils::openLog();
    }

    bless($self, $class);
    return $self;
}

=item load()

Loads filters for give $catalogid from database.

Discards any existing filters before loading.

=cut
sub load
{
    my ($self, $dbh, $catalog) = @_;

    if (@{$self->{FILTERS}}) { $self->{FILTERS} = []; }

    eval
    {    
        my $query = "select Filters.type, Filters.value from Filters, Catalogs where Filters.CATALOG_ID = Catalogs.ID and Catalogs.CATALOGID = '$catalog'";
        my $array = $dbh->selectall_arrayref($query, { Slice => {} } );
        foreach my $f (@{$array})
        {
            push @{$self->{FILTERS}}, [$f->{type}, $f->{value}];
        }
    };

    if ($@)
    {
        printLog($self->{LOG}, $self->vblevel(), LOG_ERROR, "DBERROR: ".$dbh->errstr, 0);
    }

    $self->{DIRTY} = 0;
}

=item save()

Saves current filter set to database.

=cut
sub save
{
    my ($self, $dbh, $catalog) = @_;

    if (!$self->{DIRTY}) { return }
    
    my $query = "select ID from Catalogs where CATALOGID = '$catalog'";
    my $array = $dbh->selectall_arrayref($query, { Slice => {} } );
    my $cid = $array->[0]->{ID};
    print "got catalog id '$cid'\n";

    # no filters - remove all records for this catalog
    if (@{$self->{FILTERS}} == 0)
    {
        eval
        {
            my $st = $dbh->prepare("delete from Filters where CATALOG_ID = ?");
            $st->bind_param(1, $cid, SQL_INTEGER);
            my $cnt = $st->execute;

            print $st->{Statement}."\n";
            print "deleted $cnt rows\n";

            $self->{DIRTY} = 0;
        };

        if($@)
        {
            printLog($self->{LOG}, $self->vblevel(), LOG_ERROR, "DBERROR: ".$dbh->errstr, 0);
        }

        return;
    }

    # TODO delete first and then add all the filters unconditionally, all in one transaction

    # insert the filters one by one
    foreach my $f (@{$self->{FILTERS}})
    {
        eval
        {
            # check for duplicate record
            my $st = $dbh->prepare("select ID from Filters where CATALOG_ID = ? and TYPE = ? and VALUE = ?");
            $st->bind_param(1, $cid, SQL_INTEGER);
            $st->bind_param(2, $f->[0], SQL_INTEGER);
            $st->bind_param(3, $f->[1]); # value
            $st->execute(); 
            my $row = $st->fetchrow_arrayref();

            if (!defined $row)
            {
                # insert new subfilter
                $st = $dbh->prepare(
                    "insert into Filters (CATALOG_ID, TYPE, VALUE) values(?,?,?)");
                $st->bind_param(1, $cid, SQL_INTEGER);
                $st->bind_param(2, $f->[0], SQL_INTEGER);
                $st->bind_param(3, $f->[1]); # value
                my $cnt = $st->execute;
            }
        };

        if($@)
        {
            printLog($self->{LOG}, $self->vblevel(), LOG_ERROR, "DBERROR: ".$dbh->errstr, 0);
        }
    }
    $self->{DIRTY} = 0;
}

=item add()

Whether a filter element of given $type and $value already exists in this filter
object.

Example:
$found = $filter->contains(TYPE_NAME_EXACT, 'kernel'); 

=cut
sub contains
{
    my ($self, $type, $value) = @_;

    # check for duplicate
    foreach my $f (@{$self->{FILTERS}})
    {
        # is there a way to compare two arrays more ellegantly?
        if ($f->[0] == $type &&
            $f->[1] eq $value)
        {
            return 1;
        }
    }

    return 0;
}

=item add()

Adds a filter element (subfilter) to current filter. Does not affect database.

=cut
sub add
{
    my $self = shift;
    my $type = shift;
    my $value = shift;

    if (defined $type && is_whole_number($type))
    {
        if (!$self->contains($type, $value))
        {
            push @{$self->{FILTERS}}, [$type, $value];
            $self->{DIRTY} = 1;
        }
    }
    else
    {
        printLog($self->{LOG}, $self->vblevel(), LOG_ERROR, "Invalid arguments. Expecting a (number, string), got ($type, $value).");
    }
}

=item clean()

Removes all filters. Does not affect database.

=cut
sub clean
{
    my $self = shift;
    if ($self->{FILTERS})
    {
        $self->{DIRTY} = 1;
        $self->{FILTERS} = [];
    }
}

=item match()

Whether given patch matches this filter.

Expects a hash argument with patch data:

$patch =
{
    name => 'dbus-1',
    version => '99',
    category => 'security',
    title => 'patch for dbus',   # not used in match() so far
    description => 'loong one'   # not used in match() so far
};

$filter->match($patch);

Returns 0 if no subfilter matches the patch data, 1 if any
subfilter matches.

=cut
sub matches
{
    my ($self, $patch) = @_;

    foreach my $f (@{$self->{FILTERS}})
    {
        if ($f->[0] == TYPE_NAME_VERSION
            && $f->[1] eq "$patch->{name}-$patch->{version}")
        {
            return 1;
        }
        elsif ($f->[0] == TYPE_SECURITY_LEVEL
            && $f->[1] eq "$patch->{category}")
        {
            return 1;
        }
        elsif ($f->[0] == TYPE_NAME_EXACT
            && $f->[1] eq "$patch->{name}")
        {
            return 1;
        }
        elsif ($f->[0] == TYPE_NAME_REGEX
            && "$patch->{name}" =~ $f->[1])
        {
            return 1;
        }
    }

    return 0;
}

=item vblevel()
Get or set log verbosity level.
=cut
sub vblevel
{
    my $self = shift;
    if (@_) { $self->{VBLEVEL} = shift }

    return $self->{VBLEVEL};
}

=back

=head1 NOTES

This module is intended for filtering of patches. Can be extended to work also
with packages, patterns, or products if needed. 

=head1 AUTHOR

jkupec@suse.cz

=head1 COPYRIGHT

Copyright 2009 SUSE LINUX Products GmbH, Nuernberg, Germany.

=cut

1;
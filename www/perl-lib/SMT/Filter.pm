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
  my $success = SMT::Filte->load($dbh, $catalogid);

  # to store into db
  my $success = $filter->save($dbh, $catalogid);

  # to edit existing filter
  $filter->add($filtertype, $value);
  $filter->remove($filtertype, $value);
  $filter->clean();

  # the core subroutine :O)
  $bool = $filter->matches($patchdata);
  
  # check if the filter element is already there
  $bool = $filter->contains($filtertype, $value);

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
=back
=cut

use constant {
    TYPE_NAME_EXACT     => 1,
    TYPE_NAME_REGEX     => 2,
    TYPE_NAME_VERSION   => 3,
    TYPE_SECURITY_LEVEL => 4
};

sub is_whole_number { $_[0] =~ /^\d+$/ }

=head1 METHODS

=over 4

=item new([%params])

Constructor.

Arguments are an anonymous hash array of parameters:

=over 4

=item vblevel <level>

Set the verbose level. 

=item log

Logfile handle

=back
=cut
sub new
{
    my $class = shift;
    my %opt   = @_;
    my $self  = {};

    $self->{FILTERS} = {};
    # whether there are any changes to save
    # default: true, since calling save() after constructing an empty Filter
    # should result in cleaning up the filters for give repo
    $self->{DIRTY} = 1;

    # set up logger

    $self->{VBLEVEL} = LOG_ERROR;
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

=item load($dbh, $repoid)

Loads filters for given $repoid from database using the $dbh DB connection
handle.

Discards any existing filters before loading.

Returns false in case of error, true otherwise.

=cut
sub load
{
    my ($self, $dbh, $catalog) = @_;

    if (%{$self->{FILTERS}}) { $self->{FILTERS} = {}; }

    eval
    {
        my $query = "select Filters.type, Filters.value from Filters, Catalogs where Filters.CATALOG_ID = Catalogs.ID and Catalogs.CATALOGID = '$catalog'";
        my $array = $dbh->selectall_arrayref($query, { Slice => {} } );
        foreach my $f (@{$array})
        {
            $self->{FILTERS}->{"$f->{type}$f->{value}"} = [$f->{type}, $f->{value}];
        }
    };

    if ($@)
    {
        printLog($self->{LOG}, $self->vblevel(), LOG_ERROR, "DBERROR: ".$@, 0);
        return 0;
    }

    $self->{DIRTY} = 0;
    return 1;
}

=item save($dbh, $repoid)

Saves current filter set to database and associates them to given $repoid.
The $dbh argument is the DB connection handle.

Returns false in case of error, true otherwise.

=cut
sub save
{
    my ($self, $dbh, $catalog) = @_;

    if (!$self->{DIRTY}) { return 1; }
    
    my $query = "select ID from Catalogs where CATALOGID = '$catalog'";
    my $array = $dbh->selectall_arrayref($query, { Slice => {} } );
    my $cid = $array->[0]->{ID};

    printLog($self->{LOG}, $self->vblevel(), LOG_DEBUG, "got catalog id '$cid'", 0);

    my $dbfilters = {};
    eval
    {
        my $query = "select ID, TYPE, VALUE from Filters where CATALOG_ID = '$cid'";
        my $array = $dbh->selectall_arrayref($query, { Slice => {} } );
        foreach my $f (@{$array})
        {
            $dbfilters->{"$f->{TYPE}$f->{VALUE}"} = [$f->{TYPE}, $f->{VALUE}, $f->{ID}];
        }
    };
    if ($@)
    {
        printLog($self->{LOG}, $self->vblevel(), LOG_ERROR, "DBERROR: ".$@, 0);
        return 0;
    }

    # no filters - remove all records for this catalog
    if (!%{$self->{FILTERS}})
    {
        eval
        {
            my $st = $dbh->prepare("delete from Filters where CATALOG_ID = ?");
            $st->bind_param(1, $cid, SQL_INTEGER);
            my $cnt = $st->execute;

            printLog($self->{LOG}, $self->vblevel(), LOG_DEBUG, "$st->{Statement}\nRemoved all ($cnt) filters.", 0);

            $self->{DIRTY} = 0;
        };

        if($@)
        {
            printLog($self->{LOG}, $self->vblevel(), LOG_ERROR, "DBERROR: ".$@, 0);
            return 0;
        }

        return 1;
    }

    # insert the filters one by one
    foreach my $f (values %{$self->{FILTERS}})
    {
        # if the filter is not already in the DB
        if (!(%$dbfilters && defined $dbfilters->{"$f->[0]$f->[1]"}))
        {
            eval
            {
                # insert new subfilter
                my $st = $dbh->prepare(
                    "insert into Filters (CATALOG_ID, TYPE, VALUE) values(?,?,?)");
                $st->bind_param(1, $cid, SQL_INTEGER);
                $st->bind_param(2, $f->[0], SQL_INTEGER);
                $st->bind_param(3, $f->[1]); # value
                my $cnt = $st->execute;
            };
            if($@)
            {
                printLog($self->{LOG}, $self->vblevel(), LOG_ERROR, "DBERROR: ".$@, 0);
                return 0;
            }
        }
    }

    # delete those which are not here anymore
    foreach my $f (values %$dbfilters)
    {
        # if the filter is not in our list 
        if (!$self->contains($f->[0], $f->[1]))
        {
            eval
            {
                # delete it from DB
                my $st = $dbh->prepare("delete from Filters where ID = ?");
                $st->bind_param(1, $f->[2], SQL_INTEGER);
                my $cnt = $st->execute;
            };
            if($@)
            {
                printLog($self->{LOG}, $self->vblevel(), LOG_ERROR, "DBERROR: ".$@, 0);
                return 0;
            }
        }
    }

    $self->{DIRTY} = 0;
    return 1;
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
    return defined $self->{FILTERS}->{"$type$value"};
}

=item add()

Adds a filter element (subfilter) to current filter. Does not affect database.

Returns true if the subfilter already existed or was successfully added, false otherwise.
=cut
sub add
{
    my ($self, $type, @values) = @_;

    if (defined $type && is_whole_number($type))
    {
        foreach my $value (@values)
        {
            if (!$self->contains($type, $value))
            {
                $self->{FILTERS}->{"$type$value"} = [$type, $value];
                $self->{DIRTY} = 1;
            }
        }
        return 1;
    }

    printLog($self->{LOG}, $self->vblevel(), LOG_ERROR, "Invalid arguments. Expecting a number as the first argument, got '$type'.");

    return 0;
}

=item remove()

Removes a filter element (subfilter) from current filter. Does not affect database.

Returns true if the subfilter existed and was successfully removed, false otherwise.

=cut
sub remove
{
    my ($self, $type, $value) = @_;

    if (defined $type && is_whole_number($type))
    {
        if (defined delete($self->{FILTERS}->{"$type$value"}))
        {
          $self->{DIRTY} = 1;
          return 1;
        }
    }
    else
    {
        printLog($self->{LOG}, $self->vblevel(), LOG_ERROR,
            "Invalid arguments. Expecting a (number, string), got ($type, $value).");
    }
    
    return 0;
}

=item clean()

Removes all filters. Does not affect database.

=cut
sub clean
{
    my $self = shift;
    if (%{$self->{FILTERS}})
    {
        $self->{DIRTY} = 1;
        $self->{FILTERS} = {};
    }
}

=item matches()

Whether given patch matches this filter.

Expects a hash argument with patch data:

$patch =
{
    name => 'dbus-1',
    version => '99',
    type => 'security',          # patch category (aka patch level)
    title => 'patch for dbus',   # not used in match() so far
    description => 'loong one'   # not used in match() so far
};

$filter->matches($patch);

Returns 0 if no subfilter matches the patch data, 1 if any
subfilter matches.

=cut
sub matches
{
    my ($self, $patch) = @_;

    foreach my $f (values %{$self->{FILTERS}})
    {
        if ($f->[0] == TYPE_NAME_VERSION
            && $f->[1] eq "$patch->{name}-$patch->{version}")
        {
            return 1;
        }
        elsif ($f->[0] == TYPE_SECURITY_LEVEL
            && $f->[1] eq "$patch->{type}")
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
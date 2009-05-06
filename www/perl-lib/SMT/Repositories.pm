# SMT::Repositories AKA SMT::Catalogs
package SMT::Repositories;

use strict;
use warnings;

use constant {
    # Repository can be mirrored
    MIRRORABLE		=> 'MIRRORABLE',
    MIRRORABLE_TRUE	=> 'Y',
    MIRRORABLE_FALSE	=> 'N',

    # Repository is being mirrored
    MIRRORING		=> 'DOMIRROR',
    MIRRORING_TRUE	=> 'Y',
    MIRRORING_FALSE	=> 'N',

    # Repository has Staging feature enabled
    STAGING		=> 'STAGING',
    STAGING_TRUE	=> 'Y',
    STAGING_FALSE	=> 'N',

    CATALOGID		=> 'CATALOGID',
};

sub new ($) {
    my $dbh = shift;

    my $new = {
	'dbh' => $dbh,
	'error_message' => '',
    };

    bless $new;
    return $new;
}

sub NewErrorMessage ($$) {
    my $self = shift;
    my $new_error = shift || '';

    $self->{'error_message'} .= (length ($self->{'error_message'}) > 0 ? "\n":"").$new_error;
}

sub GetAndClearErrorMessage () {
    my $self = shift;

    my $ret = $self->{'error_message'} || '';
    $self->{'error_message'} = '';

    return $ret;
}

sub GetAllCatalogs ($$) {
    my $self = shift;
    my $filter = shift || {};

    my $sql_filter = '';

    # Constructing the 'WHERE' part of the SQL query
    foreach my $filter_key (keys %{$filter}) {
	$sql_filter .=
	    (length ($sql_filter) > 0 ? ' AND ':'').
	    $filter_key.'='.$self->{'dbh'}->quote($filter->{$filter_key});
    }

    my $sth = $self->{'dbh'}->prepare ('SELECT * FROM Catalogs'.
	# Use the 'WHERE' part if defined
	(length ($sql_filter) > 0 ? ' WHERE '.$sql_filter:'')
    );
    $sth->execute();

    my $ret = [];
    my $row = {};

    while ($row = $sth->fetchrow_hashref()) {
	$row->{'TARGET'} = '' if (not defined $row->{'TARGET'});
	push @{$ret}, $row;
    }

    return $ret;
}

sub GetCatalogPath ($$) {
    my $self = shift;

    my $catalogid = shift || '';

    if ($catalogid eq '') {
	y2error ("CatalogID must be defined");
	return undef;
    }
 
    my $catalogs = $self->GetAllCatalogs({CATALOGID => $catalogid});
    my $catalog_local_path = '';
    my $catalog = @{$catalogs}[0] || {};

    if (defined $catalog->{'LOCALPATH'}) {
	$catalog_local_path = $catalog->{'LOCALPATH'};
    } else {
	$self->NewErrorMessage ("Catalog ".$catalogid." matches but no 'LOCALPATH' is defined");
    }

    return $catalog_local_path;
}

1;

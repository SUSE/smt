package SMT;

use strict;
use warnings;

use vars qw($SCHEMA_VERSION $FILTER_DBATTRS $MIRROR_CFG);

$SCHEMA_VERSION = 0.17;

# Filters table name and attribute names for RPMMD::Filter::dbsave/dbload
$FILTER_DBATTRS = {
    TABLE_NAME => 'Filters',
    PK         => 'id',
    TYPE       => 'type',
    VALUE      => 'value',
    FK         => 'catalog_id'};

# RepositoryContentData table name and attributes
# TODO could follow $FILTER_DBATTRS structure as $CONTENT_DATA_DBATTRS
$MIRROR_CFG = {
    'content_cache' => {
        'table_name'        => 'RepositoryContentData',
        'col_fullpath'      => 'localpath',
        'col_filename'      => 'name',
        'col_checksum'      => 'checksum',
        'col_checksum_type' => 'checksum_type'}};

1;

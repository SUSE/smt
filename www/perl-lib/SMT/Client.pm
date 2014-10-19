package SMT::Client;

use strict;
use warnings;

use XML::Simple;
use SMT::Utils;

use Locale::gettext();
use POSIX();

POSIX::setlocale(&POSIX::LC_MESSAGES, "");

=pod
=head1 Client.pm - SMT Client API

=over Query the SMT database for client information

=item Usage

All getClient[^s]* (except the '_internal' one) can be used to query the SMT database
for client information. The parameter for functions ending with "ByID" or "ByGUID"
is the "ID" resp. the "GUID".

For queries on all clients ( getClients* ) the parameter is a filter hash. This hash
may contain the the keys that should be selected. If a value is assinged to the key,
the result will be filtered. Only DB entries with the fieldname matching the value
will be selected.

Query Example: getClientsInfo({ 'GUID'        => '',
                                'TARGET'      => 'foobar'
                                'LASTCONTACT' => '' })
  This queries all clients for their GUID, TARGET and LASTCONTACT information where
  the TARGET equals 'foobar'.

Possible query keys are:
  ID GUID HOSTNAME TARGET DESCRIPTION LASTCONTACT NAMESPACE



The return value for all functions is a hash of hashes. The key is always the client ID
(not GUID) and the value-hash is a hash similar to the filter hash. This is also valid for
the functions that only select information about one client.

The return value is empty for empty search results and it is undef for invaild
search queries.

The return value for the above example might look like this:
$hashOfHashes =  {
    '42' => {
                'ID'   => '42',
                'GUID' => 'guid42',
                'TARGET' => 'foobar',
                'LASTCONTACT' => '2009-05-25 16:43:07'
            },
    '83' => {
                'ID'   => '83',
                'GUID' => 'guid83',
                'TARGET' => 'foobar',
                'LASTCONTACT' => '2009-05-26 17:32:52'
            }
  }




All current functions are:
* new($$)                         -  constructor
* getClientsInfo_internal($)      -  only internal usage
* getClientsInfo($)               -  query all clients, filter the result; most generic function
* getClientInfoByGUID($)          -  get one client's by GUID
* getClientInfoByID($)            -  get one client's info by ID
* getAllClientsInfo()             -  return all clients with all information
* getClientGUIDByID($)            -  get the client's GUID by its ID (returns only the GUID)
* getClientIDByGUID($)            -  get the client's ID by its GUID (returns only the ID)
* authenticateByGUIDAndSecret     -  authenticate a user via its GUID and SECRET (returns {} on error, and info hash on success)
* authenticateByIDAndSecret       -  authenticate a user via its ID and SECRET (returns {} on error, and info hash on success)

=back

=cut

#
# constructor
#
sub new ($$)
{
    my $class = shift;
    my $params = shift || {};

    my $self = {};

    $self->{'dbh'} = $params->{'dbh'} || do {
        # TODO: log error: print "Database handle missing or not defined.";
        return undef;
    };

    bless($self, $class);
    return $self;
}

#
# small internal function to check if a string is in an array
#
sub in_Array($$)
{
    my $str = shift || "";
    my $arr = shift || ();

    foreach my $one (@{$arr})
    {
        return 1 if $one =~ /^$str$/;
    }
    return 0;
}

#
# create the SQL statement according to the filter
# this is an internal function
#
sub createSQLStatement($$)
{
    my $self = shift;

    my $filter = shift || return undef;
    return undef unless (ref($filter) eq 'HASH');

    my @PROPS = qw(id guid hostname target description lastcontact);
    my @ALLPROPS = @PROPS;
    my $asXML = ( exists ${$filter}{'asXML'}  &&  defined ${$filter}{'asXML'} ) ? 1 : 0;


    # fillup the filter if needed or filter empty
    if ( scalar( keys %{$filter} ) == 0 ||
         ( exists ${$filter}{'selectAll'}  &&  defined ${$filter}{'selectAll'} )  )
    {
        foreach my $prop (@ALLPROPS)
        {
            ${$filter}{$prop} = '' unless (exists ${$filter}{$prop}  &&  defined ${$filter}{$prop} );
        }
    }

    my @select = ();
    my @PSselect = ();
    my @where = ();
    my $fromstr  = ' Clients cl ';

    # parse the filter hash
    # collect the select and where statements and quote the input strings
    foreach my $prop ( @PROPS )
    {
        if ( exists ${$filter}{$prop} )
        {
            push (@select, "$prop" );
            if ( defined ${$filter}{$prop}  &&  ${$filter}{$prop} !~ /^$/ )
            {
                push( @where, " cl.$prop LIKE " . $self->{'dbh'}->quote(${$filter}{$prop}) . ' ' );
            }
        }
    }

    # special handling for the SECRET - only add to where filter, but not to select
    if ( exists ${$filter}{'secret'}  &&  defined ${$filter}{'secret'} )
    {
        push( @where, ' cl.secret = '. $self->{'dbh'}->quote(${$filter}{secret}) .' ' );
    }

    # make sure the ID is in the select statement in any case
    push( @select, "id" ) unless ( in_Array("id", \@select) );
    # if XML gets exported then switch to lower case attributes
    my @selectExpand = ();
    foreach my $sel (@select)
    {
        push (@selectExpand,  "  cl.$sel as ".( $asXML ? lc($sel):$sel ).'  ' );
    }

    my $selectstr = join(', ', @selectExpand) || return undef;
    if ( @PSselect > 0 )
    {
        $selectstr   .= ' ,  '.join(', ', @PSselect);
    }

    $fromstr      = $fromstr || return undef;
    my $wherestr  = join(' AND ', @where) || ' 1 '; # create 'where 1' if $wherestr is empty

    return " select  $selectstr  from  $fromstr  where  $wherestr ";
}


#
# perform a select for client information - internal function
#
sub getClientsInfo_internal($)
{
    my $self = shift;

    my $filter = shift || {};
    return undef unless ( ref($filter) eq 'HASH');

    # let create the SQL statement
    my $sql = $self->createSQLStatement($filter);
    return undef unless defined $sql;

    my $asXML = ( exists ${$filter}{'asXML'} &&  defined ${$filter}{'asXML'} ) ? 1:0;

    ## NOTE: This can be used for testing/debugging
    ## NOTE: will only return the generated SQL statement but not evaluate it
    #return $sql;

    my $refKey = $asXML ? 'id':'ID';
    my $result = $self->{'dbh'}->selectall_hashref($sql, 'id');

    if ( $asXML )
    {
        if ( keys %{$result} == 1  &&  ${$filter}{'asXML'} eq 'one' )
        {
            my @keys = keys %{$result};
            return XMLout( ${$result}{$keys[0]}
                      , rootname => "client"
                      , xmldecl => '<?xml version="1.0" encoding="UTF-8" ?>' );
        }
        else
        {
            my @clientsList = ();
            foreach my $key ( keys %{$result} )
            {
                push ( @clientsList, ${$result}{$key} );
            }

            my $clientsHash = {  'client' => [@clientsList]  };
            return XMLout( $clientsHash
                          , rootname => "clients"
                          , xmldecl => '<?xml version="1.0" encoding="UTF-8" ?>' );
        }
    }
    else
    {
        return $result;
    }
}


#
# authenticateByGUIDAndSecret
#   authenticate a user via its GUID and Secret
#   returns an info hash on success with ID and GUID on success or {} on failure
#
sub authenticateByGUIDAndSecret($$$)
{
   my $self = shift;
   my $guid = shift || return undef;
   my $secret = shift || '';

   return $self->getClientsInfo_internal({ 'id'     => '',
                                           'guid'   => $guid,
                                           'secret' => $secret });
}


#
# authenticateByIDAndSecret
#   authenticate a user via its GUID and Secret
#   returns an info hash on success with ID and GUID on success or {} on failure
#
sub authenticateByIDAndSecret($$$)
{
   my $self = shift;
   my $id = shift || return undef;
   my $secret = shift || '';

   return $self->getClientsInfo_internal({ 'id'     => $id,
                                           'guid'   => '',
                                           'secret' => $secret });
}


#
# getClientsInfo
#   query all clients about information, filtered by filter
#   this is the mose generic function to query clients (besides the internal one)
#   parameters
#    $self
#    $filter (hash) : filter for the query
#
sub getClientsInfo($$)
{
    my $self = shift;
    my $filter = shift || {};

    return undef unless ( ref($filter) eq 'HASH');
    return $self->getClientsInfo_internal($filter);
}


#
# getClientInfoByGUID
#   get detailled information about one client via his GUID
#   For future compatibility there are both functions available ~ByID and ~ByGUID, as
#   we will move to IDs as primary key in a later version.
#   parameters:
#    self
#    guid (string)
#
sub getClientInfoByGUID($$)
{
    my $self = shift;
    my $guid = shift || "";

    return undef unless (defined $guid && $guid !~ /^$/);
    return $self->getClientsInfo_internal({'guid' => $guid,
                                           'selectAll' => ''});
}


#
# getClientDetailsByID
#   get detailled information about one client via his ID (internal SMT client ID)
#   For future compatibility there are both functions available ~ByID and ~ByGUID, as
#   we will move to IDs as primary key in a later version.
#   parameters:
#    self
#    id (integer)
#
sub getClientInfoByID($$)
{
    my $self = shift;
    my $id = shift || '';

    return undef unless (defined $id && $id !~ /^$/);
    return $self->getClientsInfo_internal({'id' => $id,
                                           'selectAll' => ''});
}


#
# getAllClientsInfo
#   get detailled information about all clients with all information
#   parameter
#    self
#
sub getAllClientsInfo($)
{
    my $self = shift;

    # emtpy filter means: select all information
    return $self->getClientsInfo_internal({});
}


#
# getAllClientsInfoAsXML
#   get detailled information about all clients with all information as XML
#   parameter
#    self
sub getAllClientsInfoAsXML($)
{
    my $self = shift;

    # emtpy filter means: select all information
    return $self->getClientsInfo_internal({ 'asXML' => '', 'selectAll' => '' });
}


#
# getClientGUIDByID
#   get a client's GUID via its ID
#
sub getClientGUIDByID($$)
{
    my $self = shift;
    my $id = shift || "";
    my $guid = undef;

    return undef unless (defined $id && $id !~ /^$/);
    my $res = $self->getClientsInfo_internal({ 'id' => $id,
                                               'guid' => ''  });
    if ( keys %{$res} == 1 )
    {
        foreach my $key (keys %{$res})
        {
            return ${$res}{$key}{'guid'} if ( ${$res}{$key}{'id'} eq $id )
        }
    }
    return undef;
}


#
# getClientIDByGUID
#   get a client's ID via its GUID
#
sub getClientIDByGUID($$)
{
    my $self = shift;
    my $guid = shift || "";

    return undef unless (defined $guid && $guid !~ /^$/);
    my $res = $self->getClientsInfo_internal({ 'guid' => $guid,
                                               'id' => ''  });
    if ( keys %{$res} == 1 )
    {
        foreach my $key (keys %{$res})
        {
            return ${$res}{$key}{'id'} if ( ${$res}{$key}{'guid'} eq $guid )
        }
    }
    return undef;
}

#
# updateLastContact
#   update the LASTCONTACT field in Clients
#
sub updateLastContact($)
{
    my $self = shift;
    my $guid = shift || return undef;

    my $sql = sprintf( "UPDATE Clients SET lastcontact = CURRENT_TIMESTAMP WHERE guid = %s", $self->{'dbh'}->quote($guid) );
    my $res = $self->{'dbh'}->do($sql);
    $self->{'dbh'}->commit();

    return 0 if ( defined $res  &&  $res =~ /^0E0$/ );
    return  $res ? 1:0;
}

1;

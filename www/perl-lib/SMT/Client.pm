package SMT::Client;

use strict;
use warnings;

use XML::Simple;
use UNIVERSAL 'isa';


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

The patchstatus query string is different. It is a set of 4 values separated by one
colon. Each value may be an exact number to query or an empty string if it should
not be filtered by that value. Or it may be a string like "<100" or ">0", so its
value will be checked if it is lower than or greater that the given number.
The 4 sets represent the pending patches for 1. the packagemanager, 2. security 
updates, 3. recommended updates, 4. optional updates, in this order.
If a string does not match a valid search pattern, undef will be returned.

Patchstatus Query String Example:  ":>0::<100"
  This queries for clients that have more than 0 security patches and less than
  100 optional patches.


Query Example: getClientsInfo({ 'GUID'        => '',
                                'TARGET'      => 'foobar'
                                'LASTCONTACT' => '' })
  This queries all clients for their GUID, TARGET and LASTCONTACT information where
  the TARGET equals 'foobar'.

Possible query keys are:
  ID GUID HOSTNAME TARGET DESCRIPTION LASTCONTACT NAMESPACE PATCHSTATUS



The return value for all functions is a hash of hashes. The key is always the client ID 
(not GUID) and the value-hash is a hash similar to the filter hash. This is also valid for
the functions that only select information about one client. Only the patchstatus information
is split into 4 separate keys: PATCHSTATUS_P for packagemanager, PATCHSTATUS_S for security
updates, PATCHSTATUS_R for recommended updates and PATCHSTATUS_O for optional patches.

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
* getClientPatchstatusByID($)     -  get one client's patchstatus by ID
* getClientPatchstatusByGUID($)   -  get one client's patchstatus by GUID
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
# parse Patchstatus Query String
#
sub createPatchstatusQuery($$)
{
    my $self = shift;
    my $q = shift || '';

    # these are the hardcoded keys for the MachineData table for the patchstatus (where TYPE is 1)
    my @KEYS = qw[PKGMGR SECURITY RECOMMENDED OPTIONAL];
    my @fields = ();
    my @whereClause = ();

    # check query string
    if ( $q =~ /^$/ )
    {
        # allow empty query string
        @fields = ('', '', '', '');
    }
    elsif ( $q =~ /^([^:]*):([^:]*):([^:]*):([^:]*)$/ )
    {
        # check if general pattern matches: set of 4 strings separated by colon (empty string is ok)
        @fields = ( defined $1 ? "$1":'',
                    defined $2 ? "$2":'',
                    defined $3 ? "$3":'',
                    defined $4 ? "$4":'',  );
    }
    else
    {
        # TODO log error: print filter pattern wrong
        return undef;
    }

    # if there are 4 fields continue parsing
    if ( scalar(@fields) == 4 )
    {
        for (my $i=0 ; $i<4 ; $i++)
        {
            # match valid query string and empty string (skip if empty)
            if ( $fields[$i] =~ /^([<>])?(\d+)?$/ )
            {
                # if no number is given skip to next
                next unless defined $2;
                # if not lower or greater is defined it means equal
                # $op should not be $self->{'dbh'}->quote~d so make sure only  <, >, = are possible 
                my $op = (defined $1) ?  ($1 eq '>' ? '>':'<' ) : '=';
                # create where statement snippet
                push(@whereClause, sprintf(" ps.$KEYS[$i] $op %s ", $self->{'dbh'}->quote($2) ));
            }
            elsif ( defined $fields[$i] )
            {
                # TODO log error: print "error in patchstatus query filter\n";
                return undef;
            }
        }
    }
    else
    {   # with the code above this else block will never be accessed
        # TODO log error: print "error in creating the patchstatus query\n";
        return undef;
    }

    # create where statement snippet for the patchstatus values
    return join(' AND ', @whereClause);
}


#
# create the SQL statement according to the filter
# this is an internal function
#
sub createSQLStatement($$)
{
    my $self = shift;

    my $filter = shift || return undef;
    return undef unless isa($filter, 'HASH');

    my %PSmap = ( 'PKGMGR' => 'PATCHSTATUS_P',
                  'SECURITY' => 'PATCHSTATUS_S',
                  'RECOMMENDED' => 'PATCHSTATUS_R',
                  'OPTIONAL' => 'PATCHSTATUS_O'   );

    my @PROPS = qw(ID GUID HOSTNAME TARGET DESCRIPTION LASTCONTACT NAMESPACE);
    my @ALLPROPS = @PROPS;
    push( @ALLPROPS, 'PATCHSTATUS' );
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
    if ( exists ${$filter}{'SECRET'}  &&  defined ${$filter}{'SECRET'} )
    {
        push( @where, ' cl.SECRET = '. $self->{'dbh'}->quote(${$filter}{SECRET}) .' ' );
    }

    # add query for patchstatus if defined
    if ( exists ${$filter}{'PATCHSTATUS'}  &&  defined ${$filter}{'PATCHSTATUS'} )
    {
        # parse and create the patchstatus query
        my $patchstatusQuery = $self->createPatchstatusQuery(${$filter}{'PATCHSTATUS'});
        return undef unless defined $patchstatusQuery;

        $fromstr .= ' LEFT JOIN Patchstatus ps ON ( cl.ID = ps.CLIENT_ID ) ';
        foreach my $PSkey (keys %PSmap)
        {
            # if XML gets exported then switch to lower case attributes
            push( @PSselect, "  ps.$PSkey as  ".( $asXML ?  lc($PSmap{$PSkey}):$PSmap{$PSkey}).'  '  );
        }
        push( @where, $patchstatusQuery) unless ( $patchstatusQuery eq '');
    }
 
    # make sure the ID is in the select statement in any case
    push( @select, "ID" ) unless ( in_Array("ID", \@select) );
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
    return undef unless ( isa($filter, 'HASH') );

    # let create the SQL statement
    my $sql = $self->createSQLStatement($filter);
    return undef unless defined $sql;

    my $asXML = ( exists ${$filter}{'asXML'} &&  defined ${$filter}{'asXML'} ) ? 1:0;

    ## NOTE: This can be used for testing/debugging
    ## NOTE: will only return the generated SQL statement but not evaluate it
    #return $sql;

    my $refKey = $asXML ? 'id':'ID';
    my $result = $self->{'dbh'}->selectall_hashref($sql, $refKey);

    if ( $asXML )
    {
        if ( keys %{$result} == 1  &&  ${$filter}{'asXML'} eq 'one' )
        {
            my @keys = keys %{$result};
            return XMLout( ${$result}{@keys[0]}
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

   return $self->getClientsInfo_internal({ 'ID'     => '',
                                           'GUID'   => $guid,
                                           'SECRET' => $secret });
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

   return $self->getClientsInfo_internal({ 'ID'     => $id,
                                           'GUID'   => '',
                                           'SECRET' => $secret });
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

    return undef unless ( isa($filter, 'HASH') );  
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
    return $self->getClientsInfo_internal({'GUID' => $guid,
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
    return $self->getClientsInfo_internal({'ID' => $id,
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
    my $res = $self->getClientsInfo_internal({ 'ID' => $id,
                                        'GUID' => ''  });
    if ( keys %{$res} == 1 )
    {
        foreach my $key (keys %{$res})
        {
            return ${$res}{$key}{'GUID'} if ( ${$res}{$key}{'ID'} eq $id )
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
    my $res = $self->getClientsInfo_internal({ 'GUID' => $guid, 
                                        'ID' => ''  });
    if ( keys %{$res} == 1 )
    {
        foreach my $key (keys %{$res})
        {
            return ${$res}{$key}{'ID'} if ( ${$res}{$key}{'GUID'} eq $guid )
        }
    }
    return undef;
}


#
# getPatchstatusByID
#   get a client's patchstatus via its ID
#   parameters:
#    self
#    ID
#
sub getClientPatchstatusByID($$)
{
    my $self = shift;
    my $id = shift || '';

    return undef unless (defined $id && $id !~ /^$/);
    return $self->getClientsInfo_internal({'ID' => $id,
                                    'PATCHSTATUS' => '' });
}


#
# getPatchstatusByGUID
#   get a client's patchstatus via its GUID
#   parameters:
#    self
#    GUID
sub getClientPatchstatusByGUID($$)
{
    my $self = shift;
    my $guid = shift || '';

    return undef unless (defined $guid && $guid !~ /^$/);
    return $self->getClientsInfo_internal({'GUID' => $guid,
                                    'PATCHSTATUS' => '' });
}

sub updatePatchstatus($$)
{
    my $self = shift;
    my $guid = shift || return undef;
    my $pInfo = shift || return undef;

    # get Client id
    my $cid = $self->getClientIDByGUID($guid) || return undef;

    # crop spaces and comment information
    $pInfo =~ s/^\s+//;
    $pInfo =~ s/\s*#.*$//;

    # check if exists PS
    my $sql = ' INSERT INTO Patchstatus (CLIENT_ID, PKGMGR, SECURITY, RECOMMENDED, OPTIONAL) VALUES ';
    if ( $pInfo =~ /^(\d+):(\d+):(\d+):(\d+)$/  )
    {
        my $PSp = $self->{'dbh'}->quote($1) || 'NULL';
        my $PSs = $self->{'dbh'}->quote($2) || 'NULL';
        my $PSr = $self->{'dbh'}->quote($3) || 'NULL';
        my $PSo = $self->{'dbh'}->quote($4) || 'NULL';
 
        $sql .= " ( $cid, $PSp, $PSs, $PSr, $PSo ) ";     
        $sql .= ' ON DUPLICATE KEY UPDATE ';
        $sql .= " PKGMGR = $PSp , SECURITY = $PSs , RECOMMENDED = $PSr , OPTIONAL = $PSo ";
    }
    else
    {
        return undef;
    }

    return $self->{'dbh'}->do($sql);
}


1;
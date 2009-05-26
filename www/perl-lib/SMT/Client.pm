package SMT::Client;

use strict;
use warnings;

use UNIVERSAL 'isa';
use SMT::Utils;


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


All current functions are:
* getClientsInfo_internal($)      -  only internal usage
* getClientsInfo($)               -  query all clients, filter the result; most generic function
* getClientInfoByGUID($)          -  get one client's by GUID
* getClientInfoByID($)            -  get one client's info by ID
* getAllClientsInfo()             -  return all clients with all information
* getClientGUIDByID($)            -  get the client's GUID by its ID
* getClientIDByGUID($)            -  get the client's ID by its GUID
* getClientPatchstatusByID($)     -  get one client's patchstatus by ID
* getClientPatchstatusByGUID($)   -  get one client's patchstatus by GUID


=back

=cut





#
# small internal function to check if a string is in an array
#
sub in_Array($$)
{
    my $str = shift || "";
    my $arr = shift || ();
    my $one = "";

    while ( $one = shift(@{$arr}) )
    {
        return 1 if $one =~ /^$str$/;
    }
    return 0;
}


#
# parse Patchstatus Query String
#
sub parsePatchstatusQuery($)
{
    my $q = shift || return undef;

    # these are the hardcoded keys for the MachineData table for the patchstatus (where TYPE is 1)
    @KEYS = qw[PSp PSs PSr PSo];
    my @fields = ();
    my @whereClause = ();

    # check if general pattern matches: 4 strings separated by colon (empty string is ok)
    if ($q =~ /^([^:]*):([^:]*):([^:]*):([^:]*)$/)
    {
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
        for ($i=0 ; $i<4 ; $i++)
        {
            if ( $fields[$i] =~ /^([<>])?(\d+)?$/ )
            {
                # if no number is given skip to next
                next unless defined $2;
                # if not lower or greater is defined it means equal
                $op = (defined $1) ? "$1":"=";
                # create where statement snippet
# FIXME adapt to database changes
                push(@whereClause, " ( md.KEYNAME = \"$KEYS[$i]\" AND md.VALUE  $op $2 ) ");
            }
            elsif ( defined $fields[$i] )
            {
                # TODO log error: print "error on filter $STAT[$i]: $cut[$i]\n";
                return undef;
            }
        }
    }
# FIXME adapt to database changes
    return " md.TYPE = 1 AND ( " . join(" OR ", @whereClause) . " ) ";

}


#
# create the SQL statement according to the filter
# this is an internal function
#
sub createSQLStatement($$)
{
    my $filter = shift || return undef;
    return undef unless isa($filter, 'HASH');

    # get dbh handle for the quoting function
    my $dbh = shift || return undef;

    # assign default filter if filter is empty
    # default is: get all properties witout a filter
    $filter = {
        ID => '',
        GUID => '',
        HOSTNAME => '',
        TARGET => '',
        DESCRIPTION => '',
        LASTCONTACT => '',
        NAMESPACE => '',
        PATCHSTATUS => ''
    } if $filter == {}; 

    my @select = ();
    my @where = ();
    my @PROPS = qw(ID GUID HOSTNAME TARGET DESCRIPTION LASTCONTACT NAMESPACE);

    # parse the filter hash
    # collect the select and where statements and quote the input strings
    foreach my $prop ( @PROPS )
    {
        if ( exists ${$filter}{$prop} )
        {
            push (@select, "$prop as cl.$prop");
            if ( defined ${$filter}{$prop}  &&  ${$filter}{$prop} ne '' )
            {
                push (@where, " cl.$prop LIKE \"" . $dbh->quote(${$filter}{$prop}) . "\" ");
            }        
        }
    }

#####################

    if ( exists ${$filter}{'PATCHSTATUS'} && defined ${$filter}{'PATCHSTATUS'} )
    {
        my $patchstatusQuery = parsePatchstatusQuery(${$filter}{'PATCHSTATUS'});
        if ( defined $patchstatusQuery )
        {
## FIXME adapt to database changes
            $patchstatusSelect = '';
            $patchstatusFrom = " , MachineData md ";
            push(@wherestr, " md.GUID = cl.GUID ");
            push(@wherestr, $patchstatusQuery);
        

            foreach my $res (${$result})
            {
            ###  TODO
            
            }
        }
    }

#####################
 
    if ( exists ${$filter}{'selectOnly'}  &&  defined ${$filter}{'selectOnly'} )
    {
        @select = $dbh->quote(${$filter}{'selectOnly'}) if ( in_Array(${$filter}{'selectOnly'}, \@PROPS) );
        push (@select, 'ID') unless ( in_Array('ID', \@select) );
    }

    my $selectstr = join(', ', @select);
    my $wherestr  = join(' AND ', @where);

    my $sqlstatement = " select $selectstr from Clients cl $patchstatusFrom where $wherestr ";

    return $sqlstatement;
}


#
# perform a select for client information - internal function
#
sub getClientsInfo_internal($)
{
    my $dbh = my $dbh = SMT::Utils::db_connect();
    if ( !$dbh )
    {
        # TODO  log error: "Cannot connect to database";
        die "Please contact your administrator.";
    }

    my $filter = shift || {};
    return undef unless ( isa($filter, 'HASH') );

    # let create the SQL statement
    my $sql = createSQLStatement($filter, $dbh);
    return undef unless defined $sql;


    my $result = $dbh->selectall_hashref($sql, 'ID');
    return undef unless defined $result;

    # TODO integrate patchstatus information

    return $result;
}


#
# getClientsInfo
#   query all clients about information, filtered by filter
#   this is the mose generic function to query clients (besides the internal one)
#   parameters
#    $filter (hash) : filter for the query
#
sub getClientsInfo($)
{
    my $filter = shift || {};
    return undef unless ( isa($filter, 'HASH') );  
    return getClientsInfo_internal($filter);
}


#
# getClientInfoByGUID
#   get detailled information about one client via his GUID
#   For future compatibility there are both functions available ~ByID and ~ByGUID, as 
#   we will move to IDs as primary key in a later version.
#   parameter: guid (string)
#
sub getClientInfoByGUID($)
{
    my $guid = shift || "";
    return undef unless (defined $guid && $guid !~ //);
    return getClientsInfo_internal({'GUID' => $guid});
}


#
# getClientDetailsByID
#   get detailled information about one client via his ID (internal SMT client ID)
#   For future compatibility there are both functions available ~ByID and ~ByGUID, as 
#   we will move to IDs as primary key in a later version.
#   parameter: id (integer)
#
sub getClientInfoByID($)
{
    my $id = shift || '';
    return undef unless (defined $id && $id !~ //);
    return getClientsInfo_internal({'ID' => $id});
}


#
# getAllClientsInfo
#   get detailled information about all clients with all information
#   no parameters
#
sub getAllClientsInfo()
{
    return getClientsInfo_internal({});
}


#
# getClientGUIDByID
#   get a client's GUID via its ID
#
sub getClientGUIDByID($)
{
    my $id = shift || "";
    return undef unless (defined $id && $id !~ //);
    return getClientsInfo_internal({ 'ID' => $id,
                                        'selectOnly' => 'GUID'  });
}


#
# getClientIDByGUID
#   get a client's ID via its GUID
#
sub getClientIDByGUID($)
{
    my $guid = shift || "";
    return undef unless (defined $guid && $guid !~ //);
    return getClientsInfo_internal({ 'GUID' => $guid,
                                        'selectOnly' => 'ID'  });
}


#
# getPatchstatusByID
#   get a client's patchstatus via its ID
#   parameter: ID
#
sub getClientPatchstatusByID($)
{
    # TODO redirect to internal function with fitting filter
}


#
# getPatchstatusByGUID
#   get a client's patchstatus via its GUID
#   parameter: GUID
sub getClientPatchstatusByGUID($)
{
    # TODO redirect to internal function with fitting filter
}


1;


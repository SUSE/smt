package SMT::Client;

use strict;
use warnings;

use UNIVERSAL 'isa';
use SMT::Utils;



#
# small internal function to see if a string is in an array
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
        @fields = ( defined $1 ? "$1":"",
                    defined $2 ? "$2":"",
                    defined $3 ? "$3":"",
                    defined $4 ? "$4":"",  );
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
                push(@whereClause, " ( md.KEYNAME = \"$KEYS[$i]\" AND md.VALUE  $op $2 ) ");
            }
            elsif ( defined $fields[$i] )
            {
                # TODO log error: print "error on filter $STAT[$i]: $cut[$i]\n";
                return undef;
            }
        }
    }

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
sub getAllClients_internal($)
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

    if ( exists ${$filter}{'PATCHSTATUS'} && defined ${$filter}{'PATCHSTATUS'} )
    {
        my $patchstatusQuery = parsePatchstatusQuery(${$filter}{'PATCHSTATUS'});
        if ( defined $patchstatusQuery )
        {
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
    return getAllClientsInfo_internal($filter);
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
    return getAllClientsInfo_internal({'GUID' => $guid});
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
    return getAllClientsInfo_internal({'ID' => $id});
}


#
# getClientsInfo
#   query all clients for information filtered by filter
#   parameters
#    $filter (hash) : filter for the query
#
sub getClientsInfo($)
{
    my $filter = shift || {};
    return undef unless ( isa($filter, 'HASH') );  
    return getAllClientsInfo_internal($filter);
}


#
# getAllClientsInfo
#   get detailled information about all clients with all information
#   no parameters
#
sub getAllClientsInfo()
{
    return getAllClientsInfo_internal({});
}

#
# getClientGUIDByID
#   get a client's GUID via its ID
#
sub getClientGUIDByID($)
{
    my $id = shift || "";
    return undef unless (defined $id && $id !~ //);
    return getAllClientsInfo_internal({ 'ID' => $id,
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
    return getAllClientsInfo_internal({ 'GUID' => $guid,
                                        'selectOnly' => 'ID'  });
}




1;


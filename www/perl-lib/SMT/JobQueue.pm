package SMT::JobQueue;

use strict;
use warnings;
use XML::Simple;
use UNIVERSAL 'isa';
use SMT::Job;
use SMT::Client;
use SMT::Utils;
use Data::Dumper;

sub new ($$)
{
    my $class = shift;
    my $params = shift || {};

    my $self = {};

    if (defined $params->{dbh})
    {
	$self->{dbh} = $params->{dbh};
    }

    if (defined $params->{LOG})
    {
	$self->{LOG} = SMT::Utils::openLog ($params->{LOG});
    }

    bless $self, $class;
    return $self;
}

###############################################################################
# retriveJob 
# returns the job description for job $id either in xml format and stets the
# retrived date
# or in hash structure
# args: jobid 
# args: guid
#       xmlformat (default false)
sub retrieveJob($$$$)
{
  my $self      = shift;

  my $guid      = shift;
  my $jobid     = shift;
  my $xmlformat = shift || 0;

  my $job = SMT::Job->new({ 'dbh' => $self->{dbh} });
  $job->readJobFromDatabase( $jobid, $guid );

  if ( ! $job->isValid() )
  {
    return $xmlformat ? "<job/>" : undef;
  }

  $job->retrieved( SMT::Utils::getDBTimestamp() );
  $job->save();

  return $xmlformat ? $job->asXML() : $job;
}

###############################################################################
# getJob 
# returns the job description for job $id either in xml format
# or in hash structure
# args: jobid 
# args: guid
#       xmlformat (default false)
sub getJob($$$$)
{
  my $self      = shift;

  my $guid      = shift;
  my $jobid     = shift;
  my $xmlformat = shift || 0;

  my $job = SMT::Job->new({ 'dbh' => $self->{dbh} });
  $job->readJobFromDatabase( $jobid, $guid );

  if ( ! $job->isValid() )
  {
    return $xmlformat ? "<job/>" : undef;
  }

  return $xmlformat ? $job->asXML() : $job;
}


###############################################################################
# getNextJob
# returns the next job either in xml format
# or in hash structure
# if no guid is passed jobs for all clients are taken
#
# args: guid 
#       xmlformat (default false)
sub getNextJob($$$)
{
  my $self      = shift;

  my $guid      = shift;
  my $xmlformat = shift || 0;

  return getJob($self, $guid, getNextJobID($self, $guid, 0), $xmlformat );
}

###############################################################################
# retrieveNextJob
# returns the next job either in xml format
# or in hash structure and stets the retrived date
# if no guid is passed jobs for all clients are taken
#
# args: guid 
#       xmlformat (default false)
sub retrieveNextJob($$$)
{
  my $self      = shift;

  my $guid      = shift;
  my $xmlformat = shift || 0;

  return retrieveJob($self, $guid, getNextJobID($self, $guid, 0), $xmlformat );
}





###############################################################################
# getNextJobID 
# returns the jobid of the next job either in xml format
# or in hash structure
# if no guid is passed jobs for all clients are taken
#
# args: guid 
#       xmlformat (default false)
sub getNextJobID($$$)
{
  my $self      = shift;

  my $guid      = shift;
  my $xmlformat = shift || 0;

  my $sql = 'select JobQueue.ID jid from JobQueue inner join Clients on ( JobQueue.GUID_ID = Clients.ID ) '; 
     $sql .= ' where STATUS  = ' . 0				 ;          #( 0 = not yet worked on)
     $sql .= " and ";
     $sql .= " ( TARGETED <= \"". SMT::Utils::getDBTimestamp() . "\"";
     $sql .= "  OR TARGETED IS NULL ) ";
     $sql .= " and ";
     $sql .= " ( EXPIRES > \"". SMT::Utils::getDBTimestamp() . "\"";
     $sql .= "  OR EXPIRES IS NULL ) ";
     $sql .= " and ";
     $sql .= "  PARENT_ID IS NULL ";
     $sql .= ' and Clients.GUID='.$self->{dbh}->quote($guid) if (defined $guid);
     $sql .= " ORDER BY jid ";
     $sql .= ' limit 1';

  my $id = $self->{dbh}->selectall_arrayref($sql)->[0]->[0];

  if ( defined $id)
  {
    return $xmlformat ? '<job id="'.$id.'">' : $id;
  }
  else
  {
    return $xmlformat ? '<job/>' : undef;
  }

}


###############################################################################
# returns a list of next jobs either in xml format
# or in hash structure
# if no guid is passed jobs for all clients are taken
sub getJobList($$)
{
  my $self      = shift;
  my $guid      = shift || return undef;
  my $xmlformat = shift || 0;

  #TODO: retrieve job list from database
  #TODO: test GUID

  # just create some test jobs
  my @joblist = (44);
  my @jobListCollect = ();
 

  if ( $xmlformat == 1 )
  {
     foreach my $jobid (@joblist)
     {
        push( @jobListCollect,  $self->getJob($guid, $jobid, 0) );
     }
     my $allJobs = {  'job' => [@jobListCollect]  };
     return XMLout( $allJobs 
                    , rootname => "jobs"
                    # , noattr => 1
                   , xmldecl => '<?xml version="1.0" encoding="UTF-8" ?>'
           );
  }
  else
  {
    return "@joblist";
  }
}


###############################################################################
# add a job to the database (arg = jobobject)
sub addJob($$)
{
  my $self = shift;
  my $job = shift;

  return $job->save();
}


# add jobs for multiple guids
# args: jobobject, guidlist
sub addJobForMultipleGUIDs
{
  my $self = shift;
  my $job = shift;
  my @guids = @_;

  foreach my $guid (@guids)
  {
    $job->guid($guid);
    $job->save() || return undef;
  }
  return 1;
}



sub calcNextTargeted
{
  my $self  = shift;
  my $guid  = shift || return undef;
  my $jobid = shift || return undef;

  my $client = SMT::Client->new({ 'dbh' => $self->{dbh} });
  my $guidid = $client->getClientIDByGUID($guid) || return undef;

  my $sql = 'select ADDTIME("'.SMT::Utils::getDBTimestamp().'", TIMELAG ) from JobQueue '; 
     $sql .= ' where GUID_ID  = '. $self->{dbh}->quote($guidid) ;
     $sql .= ' AND ID  = '. $self->{dbh}->quote($jobid) ;

  my $time = $self->{dbh}->selectall_arrayref($sql)->[0]->[0];

  return $time;

}


sub parentFinished
{
  my $self      = shift;

  my $guid      = shift;	
  my $jobid     = shift; 	#jobid of parent job
 
  my $client = SMT::Client->new({ 'dbh' => $self->{dbh} });
  my $guidid = $client->getClientIDByGUID($guid) || return undef;


  my $sql = 'update JobQueue'.
  ' set PARENT_ID  = NULL '.
  ' where PARENT_ID = '.$self->{dbh}->quote($jobid).
  ' and GUID_ID = '.$self->{dbh}->quote($guidid);

  $self->{dbh}->do($sql) || return undef;


}


###############################################################################
sub finishJob($)
{
  my $self = shift;
  my $guid      = shift || return undef;
  my $jobxml = shift;

  my $xmljob = SMT::Job->new({ 'dbh' => $self->{dbh} });
  $xmljob->readJobFromXML( $guid, $jobxml );

  my $job = SMT::Job->new({ 'dbh' => $self->{dbh} });
  $job->readJobFromDatabase( $xmljob->{id}, $xmljob->{guid} );

  return undef unless ( $job->{retrieved} );


  if ( $job->type() eq "patchstatus" )
  {
      my $client = SMT::Client->new( {'dbh' => $self->{'dbh'} });
      $client->updatePatchstatus( $guid, $xmljob->message() );
  }


  $job->stderr  ( $xmljob->stderr()   );
  $job->stdout  ( $xmljob->stdout()   );
  $job->exitcode( $xmljob->exitcode() );
  $job->message ( $xmljob->message()  );
  $job->status  ( $xmljob->status()   );
  $job->finished( SMT::Utils::getDBTimestamp );

  if ( $job->persistent() )
  {
    $job->targeted( calcNextTargeted($self, $guid, $job->{id}) );
    $job->status( 0 );
  }


  parentFinished($self, $guid, $job->{id} );

  return $job->save();

};

sub deleteJob($)
{
  my $self = shift;
  my $jobid = shift || return undef;
  my $guid = shift || return undef;

  #TODO: delete job from database

  return 1;
};



#
# the following api functions are similar to Client's api.
# 
# 
# Query Example: 
#
#  getJobsInfo({ 'ID'      => undef,
#                'STATUS'  => 0,
#                'TYPE>'   => 1 });
#
# The suffix '>' after 'TYPE' indicates to search for values that are greater then 1.
#
# Possible suffixes are:
#  >	greater
#  <    less
#  =    equal  (same as no suffix)
#  !    not equal
#  ~    like
#  +    NOT NULL
#  -    IS NULL

#
# Possible query keys are:
#   ID PARENT_ID NAME DESCRIPTION TYPE ARGUMENTS STATUS STDOUT 
#   STDERR EXITCODE MESSAGE CREATED TARGETED EXPIRES RETRIEVED FINISHED 
#   PERSISTENT VERBOSE TIMELAG GUID
#
# Note: GUID doesn't support suffixes.



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
#
# create the SQL statement according to the filter
# this is an internal function
#
sub createSQLStatement($$)
{
    my $self = shift;

    my $filter = shift || return undef;
    return undef unless isa($filter, 'HASH');

    my @PROPS = qw(ID PARENT_ID NAME DESCRIPTION TYPE ARGUMENTS STATUS STDOUT STDERR EXITCODE MESSAGE CREATED TARGETED EXPIRES RETRIEVED FINISHED PERSISTENT VERBOSE TIMELAG);    
    my @ALLPROPS = @PROPS;

    # add > and < properties 
    my @TMPPROPS = @PROPS;
    foreach my $prop ( @TMPPROPS )
    {
      push (@PROPS, $prop.">");
      push (@PROPS, $prop."<");
      push (@PROPS, $prop."+");
      push (@PROPS, $prop."-");
      push (@PROPS, $prop."=");
      push (@PROPS, $prop."!");
      push (@PROPS, $prop."~");
    }

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
    my $fromstr  = ' JobQueue jq ';

    # parse the filter hash
    # collect the select and where statements and quote the input strings
    foreach my $prop ( @PROPS )
    {
        if ( exists ${$filter}{$prop} )
        {
	    my $p = $prop;
	    $p =~ s/\>$//;
	    $p =~ s/\<$//;
	    $p =~ s/\+$//;
	    $p =~ s/\-$//;
	    $p =~ s/\=$//;
	    $p =~ s/\!$//;
	    $p =~ s/\~$//;
            push (@select, "$p" );
            if ( defined ${$filter}{$prop}  &&  ${$filter}{$prop} !~ /^$/ )
            {
		if    ( $prop =~ /.*\>/ ) { push( @where, " jq.$p > " . $self->{'dbh'}->quote(${$filter}{$prop}) . ' ' ); }
		elsif ( $prop =~ /.*\</ ) { push( @where, " jq.$p < " . $self->{'dbh'}->quote(${$filter}{$prop}) . ' ' ); }
		elsif ( $prop =~ /.*\+/ ) { push( @where, " jq.$p IS NOT NULL" ); }
		elsif ( $prop =~ /.*\-/ )  { push( @where, " jq.$p IS NULL " ); }
		elsif ( $prop =~ /.*\=/ )  { push( @where, " jq.$p =  " . $self->{'dbh'}->quote(${$filter}{$prop}) . ' ' ); }
		elsif ( $prop =~ /.*\!/ )  { push( @where, " jq.$p <> " . $self->{'dbh'}->quote(${$filter}{$prop}) . ' ' ); }
		elsif ( $prop =~ /.*\~/ )  { push( @where, " jq.$p LIKE " . $self->{'dbh'}->quote(${$filter}{$prop}) . ' ' ); }
		else
		{
                  push( @where, " jq.$prop = " . $self->{'dbh'}->quote(${$filter}{$prop}) . ' ' );
		}
            }        
        }
    }

    # add query for guid if defined
    if ( exists ${$filter}{'GUID'} )
    {
        $fromstr .= ' LEFT JOIN Clients cl ON ( jq.GUID_ID = cl.ID ) ';
        push (@select, "cl.GUID" );
      
	if ( defined ${$filter}{'GUID'}  &&  ${$filter}{'GUID'} !~ /^$/ )
	{
                push( @where, " cl.GUID LIKE " . $self->{'dbh'}->quote(${$filter}{'GUID'}) . ' ' );
	}
    }

 
    # make sure the primary key is in the select statement in any case
    push( @select, "ID" ) unless ( in_Array("ID", \@select) );
    push( @select, "GUID_ID" ) unless ( in_Array("GUID_ID", \@select) );
    # if XML gets exported then switch to lower case attributes
    my @selectExpand = ();
    foreach my $sel (@select)
    {
	if ( $sel =~ /\./ )
	{
	  my $s = $sel;
	  $s =~ s/^.*\.//;
          push (@selectExpand,  "  $sel as ".( $asXML ? lc($s):$s ).'  ' );
	}
	else
	{
          push (@selectExpand,  "  jq.$sel as ".( $asXML ? lc($sel):$sel ).'  ' );
	}
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
# perform a select for job information - internal function
#
sub getJobsInfo_internal($)
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

    my @refKeys = $asXML ? ( 'guid_id', 'id' ) : ( 'GUID_ID', 'ID' );
    my $result = $self->{'dbh'}->selectall_hashref($sql, \@refKeys );

    my $argArg = $asXML ? 'arguments':'ARGUMENTS';

    foreach my $xguid ( keys %{$result} )
    {
	foreach my $xjobid ( keys %{${$result}{$xguid}} )
	{
	   if ( defined ${$result}{$xguid}{$xjobid}{$argArg} )
	   {
	    eval { ${$result}{$xguid}{$xjobid}{$argArg} = XMLin( ${$result}{$xguid}{$xjobid}{$argArg} , forcearray => 1 ) } ;
	   } 
	}
    }

    if ( $asXML )
    {

        if ( keys %{$result} == 1  &&  ${$filter}{'asXML'} eq 'one' )
        {
            my @keys = keys %{$result};
            return XMLout( ${$result}{$keys[0]}
                      , rootname => "job"
                      , xmldecl => '<?xml version="1.0" encoding="UTF-8" ?>' );
        }
        else
        {
            my @jobList = ();
            foreach my $key ( keys %{$result} )
            {
                push ( @jobList, ${$result}{$key} );
            }

            my $jobsHash = {  'job' => [@jobList]  };
            return XMLout( $jobsHash
                          , rootname => "jobs"
                          , xmldecl => '<?xml version="1.0" encoding="UTF-8" ?>' );
        }
    }
    else
    {
        return $result;
    }
}




#
# getClientsInfo
#   query all jobs about information, filtered by filter
#   this is the mose generic function to query jobs (besides the internal one)
#   parameters
#    $self
#    $filter (hash) : filter for the query
#
sub getJobsInfo($$)
{
    my $self = shift;
    my $filter = shift || {};

    return undef unless ( isa($filter, 'HASH') );  
    return $self->getJobsInfo_internal($filter);
}


#
# getAllJobInfo
#   get detailled information about all jobs with all information
#   parameter
#    self
#
sub getAllJobsInfo($)
{
    my $self = shift;

    # emtpy filter means: select all information
    return $self->getJobsInfo_internal({});
}


#
# getAllJobsInfoAsXML
#   get detailled information about all jobs with all information as XML
#   parameter
#    self
sub getAllJobsInfoAsXML($)
{
    my $self = shift;

    # emtpy filter means: select all information
    return $self->getJobsInfo_internal({ 'asXML' => '', 'selectAll' => '' });
}


1;

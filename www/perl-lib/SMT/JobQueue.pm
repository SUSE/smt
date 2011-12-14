package SMT::JobQueue;

use strict;
use warnings;
use XML::Writer;
use UNIVERSAL 'isa';
use SMT::Job;
use SMT::Job::Result;
use SMT::Client;
use SMT::Utils;
use Data::Dumper;
use SMT::Job::Constants;

sub new ($;$)
{
    my $class  = shift || return undef;
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
#  like getJob but flags the job as retrieved
#  kept for backward compatibility
# args: see getJob
sub retrieveJob($;$)
{
  my $self      = shift || return undef;
  my $config    = shift || {};
  $config->{retrieve} = 1;

  return $self->getJob($config);
}

###############################################################################
# getJob
#  returns the job description either in xml format or as hash
#  returned structure may be configured by a config hash as first parameter
#
# args: config hash containing one or many of the following
#   *  all job properties (name of the DB fields in upper case) like: "GUID", "ID"
#      if set to '' they act as a request to query that data, if set to a value they act as a filter
#      See createSQLStatement() for more defails.
#   * "asXML" : will return the result as XML.
#      true if defined and != 0 ; false otherwise ; all these are true: 1, '1', '', 'yes', 'one'
#      if set to 'one' only a single result will be returned
#   * "short" : filter out internal job metadata, only outputs data that the smt-client needs to process the job
#      true if set to 1, false otherwise
#   * "retrieve" : flag the job as retrieved
#      true if set to 1, false otherwise ; only supported in getJob()
#   * "selectAll" : fetch all data of that job, not only the queried from the config hash
#
sub getJob($;$)
{
  my $self      = shift || return undef;
  my $config    = shift || {};

  my $guid      = $config->{GUID} || undef;
  my $jobid     = $config->{ID}   || undef;
  my $xmlformat = (defined $config->{asXML}    && $config->{asXML} !~ /^0$/) ? 1 : 0;
  my $short     = (defined $config->{short}    && $config->{short}    == 1)  ? 1 : 0;
  my $retrieve  = (defined $config->{retrieve} && $config->{retrieve} == 1)  ? 1 : 0;

  return ($xmlformat ? "<job />" : undef) unless (defined $guid && defined $jobid);

  my $job = SMT::Job->new({ 'dbh' => $self->{dbh} });
  return undef unless defined $job;
  $job->readJobFromDatabase( $jobid, $guid );

  return ($xmlformat ? "<job />" : undef) unless ($job->isValid());

  if ($retrieve)
  {
      $job->retrieved( SMT::Utils::getDBTimestamp() );
      $job->save();
  }

  return $xmlformat ? $job->asXML({short => $short}) : $job;
}


###############################################################################
# getNextJob
#  returns the next job either in xml format or as hash
#  like getJob but does not require an id (read jobID), it will query the next ID automatically
#
# args: config hash: see getJob
sub getNextJob($;$)
{
  my $self      = shift || return undef;
  my $config    = shift || {};
  my $guid      = $config->{guid} || undef;
  return undef unless defined ($guid);
  $config->{id} = $self->getNextJobID({ guid => $guid }) || undef;

  return $self->getJob( $config );
}

###############################################################################
# retrieveNextJob
#  returns the next job either in xml format or as hash
#  like getJob but does not require an id (read jobID), it will query the next ID automatically
#  and the job will be flagged as retrieved
#
# args: config hash: see getJob
sub retrieveNextJob($;$)
{
  my $self      = shift || return undef;
  my $config    = shift || {};
  $config->{retrieve} = 1;

  return $self->getNextJob( $config );
}



###############################################################################
# getNextJobID
# returns the jobid of the next job either in xml format
# or in hash structure
# if no guid is passed jobs for all clients are taken
#
# args: guid
#       xmlformat (default false)
sub getNextJobID($;$)
{
  my $self      = shift || return undef;
  my $config    = shift || {};
  my $guid      = $config->{GUID} || undef;
  my $xmlformat = (defined $config->{asXML} && $config->{asXML} !~ /^0$/) ? 1 : 0;
  return undef unless defined ($guid);

  my $sql = 'select JobQueue.ID jid from JobQueue inner join Clients on ( JobQueue.GUID_ID = Clients.ID ) ';
     $sql .= ' where STATUS  = 0';          #( 0 = not yet worked on)
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

  my $sel = $self->{dbh}->selectrow_arrayref($sql);
  my $id  = ( isa($sel, 'ARRAY') && defined $sel->[0] ) ? $sel->[0] : undef;

  if ( defined $id )
  {
    return $xmlformat ? '<job id="'.$id.'">' : $id;
  }
  else
  {
    return $xmlformat ? '<job />' : undef;
  }

}


###############################################################################
# returns a list of all following jobs either in xml format or as hash
#
# configured via a config hash, see getJob
sub getJobList($;$)
{
  my $self      = shift || return undef;
  my $config    = shift || {};
  return $self->getJobsInfo($config);
}


###############################################################################
# add a job to the database (arg = jobobject)
sub addJob($$)
{
  my $self = shift || return undef;
  my $job  = shift || return undef;

  return $job->save();
}


# add jobs for multiple guids
# args: jobobject, guidlist
sub addJobForMultipleGUIDs($$@)
{
  my $self  = shift || return undef;
  my $job   = shift || return undef;
  my @guids = @_;

  my $newjobid = undef;
  my $error = 0;
  foreach my $guid (@guids)
  {
    $job->guid($guid);
    $newjobid = $job->save();
    $error = 1 if (not defined $newjobid);
  }

  return $error ? undef:$newjobid;
}



sub calcNextTargeted($;$)
{
  my $self   = shift || return undef;
  my $config = shift || {};
  my $guid   = $config->{GUID} || undef;
  my $jobid  = $config->{ID}   || undef;
  return undef unless (defined $guid && defined $jobid);

  my $client = SMT::Client->new({ 'dbh' => $self->{dbh} });
  return undef unless defined ($client);
  my $guidid = $client->getClientIDByGUID($guid) || return undef;

  my $sql = 'select ADDTIME("'.SMT::Utils::getDBTimestamp().'", TIMELAG ) from JobQueue ';
     $sql .= ' where GUID_ID  = '. $self->{dbh}->quote($guidid) ;
     $sql .= ' AND ID  = '. $self->{dbh}->quote($jobid) ;

  my $time = $self->{dbh}->selectall_arrayref($sql)->[0]->[0];

  return $time;

}


sub parentFinished($;$)
{
  my $self  = shift || return undef;
  my $config = shift || {};
  my $guid   = $config->{GUID} || undef;
  my $jobid  = $config->{ID}   || undef;  #jobid of parent job
  return undef unless (defined $guid && defined $jobid);

  my $client = SMT::Client->new({ 'dbh' => $self->{dbh} });
  return undef unless defined ($client);
  my $guidid = $client->getClientIDByGUID($guid) || return undef;

  my $sql = 'update JobQueue'.
  ' set PARENT_ID  = NULL '.
  ' where PARENT_ID = '.$self->{dbh}->quote($jobid).
  ' and GUID_ID = '.$self->{dbh}->quote($guidid);

  $self->{dbh}->do($sql) || return undef;
}


###############################################################################
sub finishJob($;$)
{
  my $self   = shift || return undef;
  my $config = shift || {};
  my $guid   = $config->{GUID}    || undef;
  my $jobxml = $config->{xmldata} || undef;
  return undef unless (defined $guid && defined $jobxml);

  my $xmljob = SMT::Job->new({ 'dbh' => $self->{dbh} });
  return undef unless $xmljob;
  $xmljob->readJobFromXML( $jobxml );
  # do not allow to update foreign job
  my $sentguid = $xmljob->guid();
  if ($sentguid)
  {
      return undef unless ( "$sentguid" eq "$guid" );
  }
  else
  {
      # set the guid from the config hash if not present in job XML
      # backward compatibility for old clients (bnc#723583)
      $xmljob->guid($guid);
      # LATER: add a warning to the client status, to help admins find and update old smt clients that do not include their guid in XML
      # this is needed for consistent use of the new job types that send data upstream to a cascaded SMT server
  }

  my $job = SMT::Job->new({ 'dbh' => $self->{dbh} });
  return undef unless $job;
  $job->readJobFromDatabase( $xmljob->id(), $guid );
  return undef unless ( $job->retrieved() );

  # special handling for patchstatus job
  my $jobtype = $job->type();
  $jobtype = ($jobtype =~ /^\d+$/) ? SMT::Job::Constants::JOB_TYPE->{$jobtype} : $jobtype;
  if ( $jobtype eq "patchstatus" )
  {
      my $client = SMT::Client->new( {'dbh' => $self->{'dbh'} });
      return undef unless defined $client;
      my $msg = $xmljob->message();
      $msg = 'failed' if ( $xmljob->status() =~ /^2$/ );
      $msg = 'denied' if ( $xmljob->status() =~ /^3$/ );
      $client->updatePatchstatus( $guid, $msg );
  }

  # special handling for job with cacheresult flag
  if ( $job->cacheresult() )
  {
      my $client = SMT::Client->new({ 'dbh' => $self->{dbh} });
      return undef unless defined $client;
      my $client_id = $client->getClientIDByGUID( $xmljob->guid() );

      my $res = SMT::Job::Result->new({ 'dbh' => $self->{dbh} });
      return undef unless defined $res;
      $res->saveResult( $client_id, $xmljob->{id}, $jobxml );
  }

  $job->stderr( (defined $xmljob->stderr()) ? $xmljob->stderr() : '' );
  $job->stdout( (defined $xmljob->stdout()) ? $xmljob->stdout() : '' );

  $job->exitcode( $xmljob->exitcode() );
  $job->message ( $xmljob->message()  );
  $job->status  ( $xmljob->status()   );
  $job->finished( SMT::Utils::getDBTimestamp );

  if ( $job->persistent() )
  {
    $job->targeted( $self->calcNextTargeted({ GUID => $guid, ID => $job->{id} }) );
    $job->message( sprintf("Last run failed # %s", $xmljob->message() ) )           if ( $xmljob->status() =~ /^2$/ );
    $job->message( sprintf("Last run denied by client # %s", $xmljob->message() ) ) if ( $xmljob->status() =~ /^3$/ );
    $job->status( 0 );
  }

  # get smt.conf to find out what job status values are allowed to unblock a chain; feature (bnc#730469)
  my %successIDs=( 1 => '',   # successful
                   4 => '' ); # warning
  my $cfg;
  eval {  $cfg = SMT::Utils::getSMTConfig();  };
  if ( (! $@) && defined $cfg )
  {
      my $sval = $cfg->val('JOBQUEUE', 'jobStatusIsSuccess');
      if (defined $sval)
      {
          $sval =~ s/[^\d,]+//g;
          %successIDs = map {$_ => ''} (split (",", $sval)) if ($sval != /^$/);
      }
  }
  # ID 0 is reserved for "queued" jobs - they can not be finished before retrieval
  delete($successIDs{0});

  # only activate the client jobs if this job was successful (bnc#520700)
  $self->parentFinished({ GUID => $guid, ID => $job->{id} }) if ( exists $successIDs{ $xmljob->status() } );

  return $job->save();
};

sub deleteJob($$$)
{
  my $self  = shift || return undef;
  my $jobid = shift || return undef;
  my $guid  = shift || return undef;

  # do not allow to delete all jobs of all clients
  return undef if ($jobid eq 'ALL'  &&  $guid eq 'ALL');

  my $guidid = undef;
  if ($guid ne 'ALL')
  {
      my $client = SMT::Client->new({ 'dbh' => $self->{dbh} });
      $guidid = $client->getClientIDByGUID($guid) || return undef;
  }

  my $sql = 'delete from JobQueue where ';
  if ($jobid ne 'ALL')
  {
      $sql .= ' ID = '.$self->{dbh}->quote($jobid);
      # 'and' must be added inside this block
      if ($guid ne 'ALL')
      {
          $sql .= ' and ';
      }
  }

  if ($guid ne 'ALL')
  {
      $sql .= ' GUID_ID  = '.$self->{dbh}->quote($guidid);
  }

  my $result = $self->{dbh}->do($sql);

  # if parentFinished fails it will be corrected via a cleanup cron script
  $self->parentFinished({ GUID => $guid, ID => $jobid });

  return $result;
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
#  >    greater
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
#   UPSTREAM CACHERESULT PERSISTENT VERBOSE TIMELAG GUID
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
    my $self   = shift || return undef;
    my $filter = shift || return undef;
    return undef unless isa($filter, 'HASH');

    my @PROPS = ();
    my @createDBprops = ('id', 'parent_id', SMT::Job::Constants::JOB_DATA_ATTRIBUTES, SMT::Job::Constants::JOB_DATA_ELEMENTS);
    foreach my $_p (@createDBprops)
    {
        push (@PROPS, uc($_p));
    }
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
         ( exists ${$filter}{'selectAll'}  &&  defined ${$filter}{'selectAll'} ) ||
         ( exists $filter->{short} && defined $filter->{short} && $filter->{short} !~ /^1$/ )   )
    {
        foreach my $prop (@ALLPROPS)
        {
            ${$filter}{$prop} = '' unless (exists ${$filter}{$prop}  &&  defined ${$filter}{$prop} );
        }
    }

    my @select = ();
    my @JQselect = ();
    my @where = ();
    my $fromstr  = ' JobQueue jq ';

    # parse the filter hash
    # collect the select and where statements and quote the input strings
    foreach my $prop ( @PROPS )
    {
        if ( exists ${$filter}{$prop} )
        {
            my $p = $prop;
            $p =~ s/[<>+-=!~]+//;
            push (@JQselect, "$p");
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

    # make sure all jobs have the GUID of the client
    # in the database the primaray key of a job is the jobid and the guid_id, but logically its the jobid and the guid
    ${$filter}{'GUID'} = '' if ( not exists ${$filter}{'GUID'} );

    # add query for guid
    $fromstr .= ' LEFT JOIN Clients cl ON ( jq.GUID_ID = cl.ID ) ';
    push (@select, "GUID" );

    if ( defined ${$filter}{'GUID'}  &&  ${$filter}{'GUID'} !~ /^$/ )
    {
        push( @where, " cl.GUID = " . $self->{'dbh'}->quote(${$filter}{'GUID'}) . ' ' );
    }

    # make sure the primary key is in the select statement in any case
    push( @JQselect, "ID" ) unless ( in_Array("ID", \@JQselect) );
    push( @JQselect, "GUID_ID" ) unless ( in_Array("GUID_ID", \@JQselect) );
    # if XML gets exported then switch to lower case attributes
    my @selectExpand = ();

    foreach my $sel (@select)
    {
        push (@selectExpand,  "  cl.$sel as ".( $asXML ? lc($sel):$sel ).'  ' );
    }

    my $selectstr = join(', ', @selectExpand) || return undef;
    if ( @JQselect > 0 )
    {
        foreach my $jqsel (@JQselect)
        {
            $selectstr   .= " , jq.$jqsel as  ".( $asXML ? lc($jqsel):$jqsel ).'  ';
        }
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
    my $self = shift || return undef;
    my $filter = shift || {};
    return undef unless ( isa($filter, 'HASH') );

    # let create the SQL statement
    my $sql = $self->createSQLStatement($filter);
    return undef unless defined $sql;

    my $asXML = (defined $filter->{asXML} && $filter->{asXML} !~ /^0$/) ? 1:0;

    ## NOTE: This can be used for testing/debugging
    ## NOTE: will only return the generated SQL statement but not evaluate it
    #return $sql;

    my @refKeys = $asXML ? ( 'guid_id', 'id' ) : ( 'GUID_ID', 'ID' );
    my $result = $self->{'dbh'}->selectall_hashref($sql, \@refKeys );

    if ( $asXML )
    {
        my $Job = SMT::Job->new({ 'dbh' => $self->{dbh} });
        return undef unless defined $Job;

        if ($filter->{asXML} eq 'one')
        {
            foreach my $_g (keys %{$result})
            {
                foreach my $_j (keys %{$result->{$_g}})
                {
                    $Job->readJobFromHash( $result->{$_g}->{$_j} );
                    last;
                }
            }
            return $Job->asXML($filter) || '<job />';
        }
        else
        {
            $filter->{xmldecl} = 0;
            my $w = undef;
            my $output = '';
            $w = new XML::Writer( OUTPUT => \$output, DATA_MODE => 1, DATA_INDENT => 2, UNSAFE => 1 );
            return undef unless ($w);
            $w->startTag('jobs');

            foreach my $_g ( keys %{$result} )
            {
                next unless defined $_g;
                foreach my $_j ( keys %{$result->{$_g}} )
                {
                    next unless defined $_j;
                    $Job->readJobFromHash( $result->{$_g}->{$_j} );
                    $w->raw( $Job->asXML($filter) );
                }
            }
            $w->endTag('jobs');
            $w->end();
            return $output;
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
sub getJobsInfo($;$)
{
    my $self   = shift || return undef;
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
    my $self = shift || return undef;

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
    my $self = shift || return undef;

    # emtpy filter means: select all information
    return $self->getJobsInfo_internal({ 'asXML' => '', 'selectAll' => '' });
}


1;

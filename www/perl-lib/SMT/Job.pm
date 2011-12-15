package SMT::Job;

use SMT::Utils;
use SMT::Job::Constants;
use strict;
use warnings;
use XML::Writer;
use XML::Parser;
use XML::XPath;
use UNIVERSAL 'isa';

use constant VBLEVEL => LOG_ERROR|LOG_WARN|LOG_INFO1|LOG_INFO2;


#
# a real constructor
#
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


#
# reads job specified by jobid and guid from database
#
sub readJobFromDatabase
{
  my $self = shift;
  my $jobid = shift || return undef;
  my $guid  = shift || return undef;

  my $client = SMT::Client->new({ 'dbh' => $self->{dbh} });
  return undef unless defined $client;
  my $guidid = $client->getClientIDByGUID($guid) || return undef;

  my $sql = 'select * from JobQueue '
          . 'where ID      = ' . $self->{'dbh'}->quote($jobid)
          . 'and   GUID_ID = ' . $self->{'dbh'}->quote($guidid);

  my $result = $self->{'dbh'}->selectall_hashref($sql, 'ID')->{$jobid};
  return undef unless defined $result;

  foreach my $att ( SMT::Job::Constants::JOB_DATA_BASIC, SMT::Job::Constants::JOB_DATA_ATTRIBUTES, SMT::Job::Constants::JOB_DATA_ELEMENTS )
  {
      if ( lc($att) eq 'guid' )
      {
          next; # set after this loop
      }
      elsif ( lc($att) eq 'type' )
      {
          $self->{type} = $self->jobTypeToID( $result->{TYPE} );
      }
      else
      {
          $self->{lc($att)} = $result->{uc($att)} if ( defined $result->{uc($att)} );
      }
  }
  $self->{guid} = $guid;
}


sub isValid
{
  my $self = shift || return undef;
  return ( defined $self->jobTypeToID($self->{type}) );
}


sub readJobFromHash($$)
{
  my $self = shift || return undef;
  my $attribs = shift || return undef;
  return undef unless isa($attribs, 'HASH');

  foreach my $att ( SMT::Job::Constants::JOB_DATA_BASIC, SMT::Job::Constants::JOB_DATA_ATTRIBUTES, SMT::Job::Constants::JOB_DATA_ELEMENTS )
  {
      if ( lc($att) eq 'guid' )
      {
          my $client = SMT::Client->new({ 'dbh' => $self->{dbh} });
          return undef unless defined $client;
          $self->{guid_id} = $client->getClientIDByGUID($attribs->{guid}) || undef;
          $self->{guid} = $attribs->{guid} || undef;
      }
      elsif ( lc($att) eq 'type' )
      {
          $self->{type} = $self->jobTypeToID( $attribs->{type} );
      }
      else
      {
          # check for exists instead of defined - maybe someone wants to reset a value
          $self->{lc($att)} = ( exists $attribs->{lc($att)} ) ? $attribs->{lc($att)} : undef;
      }
  }
}


#
# read tags from xml and sets job attributes
#
sub readJobFromXML
{
  my $self = shift || return undef;
  my $xmldata = shift || undef;
  return $self->error("unable to create job. xml does not contain a job description") unless ($xmldata);

  my $xpQuery = XML::XPath->new(xml => $xmldata);
  eval { return $self->error("could not parse the job xml") unless ( $xpQuery->exists('/job[1]')); };

  my $jobSet;
  eval { $jobSet = $xpQuery->find("/job[1]"); };
  return undef if ( $@ || ($jobSet->size() != 1) );
  my $oneJob = $jobSet->pop();
  return undef unless (defined $oneJob);

  my $attribNodes = $oneJob->getAttributeNodes();
  my %attribs = map { $_->getName() => $_->string_value() } (@$attribNodes);
  foreach my $att (SMT::Job::Constants::JOB_DATA_BASIC, SMT::Job::Constants::JOB_DATA_ATTRIBUTES, SMT::Job::Constants::JOB_DATA_ELEMENTS) {
      # only write values that exist in $attribs, because it must be possible to update a job via this function
      next unless (exists $attribs{lc($att)});
      # JOB_DATA_ELEMENTS could be stdout/err (support old XML style), but arguments must be filtered
      next if ($att =~ /^arguments$/);
      $self->{lc($att)} = $attribs{lc($att)};
      $self->{type} = $self->jobTypeToID($attribs{type}) if (lc($att) eq 'type');
      if ( lc($att) eq 'verbose' || lc($att) eq 'persistent' || lc($att) eq 'cacheresult' || lc($att) eq 'upstream' )
      {
          # set all boolean flags to 1 or 0
          $self->{lc($att)} = ( defined $attribs{lc($att)} && ( $attribs{lc($att)} =~ /^1$/  || $attribs{lc($att)} =~ /^true$/ ) ) ? 1:0;
      }
  }

  my $elementNodes = $oneJob->getChildNodes();
  my %elements;
  foreach my $elm (@$elementNodes) {
      next unless defined $elm;
      my $name = $elm->getName();
      next unless defined $name;
      # special handling for arguments: plain XML
      $elements{lc($name)} = ( lc($name) eq 'arguments' ) ? XML::XPath::XMLParser::as_string($elm) : $elm->string_value();
  }
  foreach my $elm (SMT::Job::Constants::JOB_DATA_ELEMENTS) {
      # only write values that exist in $elements, because it must be possible to update a job via this function
      $self->{lc($elm)} = $elements{lc($elm)} if (exists $elements{lc($elm)});
  }
}

#
# test whether a specific parent job exists
#
sub checkparentisvalid
{
  my $self = shift;
  my $parentid = shift;
  my $guidid = shift;

  my $sql = 'select * from JobQueue '
    . ' where ID      = ' . $self->{'dbh'}->quote($parentid)
    . ' and   GUID_ID = ' . $self->{'dbh'}->quote($guidid)
    . ' and   STATUS  =  0 ' ;

  my $result = $self->{'dbh'}->selectall_hashref($sql, 'ID')->{$parentid};
  return ( defined $result->{ID} ) ? 1 : 0;
}

#
# writes job to database
#
sub save
{
  my $self = shift || return undef;
  my $cookie = undef;

  # on every save the guid_id must be queried again, as the guid might have been changed
  # so this call is a must!
  return undef unless defined $self->guid_id();

  return undef if ( defined $self->{parent_id} && defined $self->{id} &&
       $self->{parent_id}  =~ /^\d+$/ &&  $self->{id} =~ /^\d+$/ &&
       $self->{parent_id}  == $self->{id} );

  if ( defined $self->parent_id() )
  {
      $self->checkparentisvalid( $self->parent_id(), $self->guid_id() ) || return undef;
  }

  # retrieve next job id from database if no id is known
  if ( not defined $self->{id})
  {
      (my $id, $cookie) = $self->getNextAvailableJobID();
      return undef unless ( defined $id && defined $cookie );
      $self->{id} = $id;
  }

  my $sql = "insert into JobQueue ";
  my @sqlkeys = ();
  my @sqlvalues = ();
  my @updatesql = ();

  foreach my $att ( SMT::Job::Constants::JOB_DATA_BASIC, SMT::Job::Constants::JOB_DATA_ATTRIBUTES, SMT::Job::Constants::JOB_DATA_ELEMENTS )
  {
      if ( lc($att) eq 'guid' || lc($att) eq 'arguments' )
      {
          # conversion of guid to guid_id at the top of this function
          # arguments set after this loop
          next;
      }
      elsif ( lc($att) eq 'status' )
      {
          # status may not be undef aka. NULL
          next unless (defined $self->{status});
      }
      elsif ( lc($att) eq 'type' )
      {
          $self->{type} = $self->jobTypeToID( $self->{type} );
      }
      elsif ( lc($att) eq 'verbose' || lc($att) eq 'persistent' || lc($att) eq 'cacheresult' || lc($att) eq 'upstream' )
      {
          # set all boolean flags to 1 or 0
          $self->{lc($att)} = ( defined $self->{lc($att)} && ( $self->{lc($att)} =~ /^1$/  || $self->{lc($att)} =~ /^true$/ ) ) ? 1:0;
      }
      elsif (lc($att) eq 'name')
      {
          # prevent that name is set to NULL, which is not allowed
          $self->{name} ||= '';
      }

      # no else section - all values need to be set
      push (@sqlkeys, uc($att));
      push (@sqlvalues, $self->{dbh}->quote( $self->{lc($att)} ));
      push (@updatesql, uc($att).' = '.$self->{dbh}->quote( $self->{lc($att)} ));
  }

  push (@sqlkeys, "GUID_ID");
  push (@sqlvalues, $self->guid_id());

  push (@sqlkeys, "ARGUMENTS" );
  push (@sqlvalues, $self->{dbh}->quote( $self->getArgumentsXML() ) ); # convert hash to xml
  push (@updatesql, 'ARGUMENTS = '.$self->{dbh}->quote( $self->getArgumentsXML() ));

  $sql .= " (". join  (", ", @sqlkeys ) .") " ;
  $sql .= " values (". join  (", ", @sqlvalues ) .") " ;
  $sql .= " on duplicate key update ". join (", ", @updatesql );

  $self->{dbh}->do($sql) || return undef ;
  $self->deleteJobIDCookie($self->{id}, $cookie) if defined $cookie;

  return $self->{id};
}


#
# return the job as XML data structure
#
sub asXML($;$)
{
  my $self = shift || return  undef;
  my $config = shift || {};
  my $short = (exists $config->{short} && $config->{short} == 1) ? 1:0;
  $config->{stdout} = 0 if ($short);
  $config->{stderr} = 0 if ($short);
  return undef unless $self->isValid();

  # create the XML output
  my $w = undef;
  my $xmlout = '';
  $w = new XML::Writer( OUTPUT => \$xmlout, DATA_MODE => 1, DATA_INDENT => 2, UNSAFE => 1);
  return undef if ( ! $w || $@ );
  $w->xmlDecl( 'UTF-8' ) unless (exists $config->{xmldecl} && $config->{xmldecl} == 0);

  my @jobattributes = ();
  my %optatt = map {$_ => 1} (SMT::Job::Constants::JOB_DATA_ATTRIBUTES);
  foreach my $att ( SMT::Job::Constants::JOB_DATA_BASIC, SMT::Job::Constants::JOB_DATA_ATTRIBUTES )
  {
      if ( lc($att) eq 'guid_id' )
      {
          next;
          # guid_id does not go to out - only internal usage
      }
      elsif ( lc($att) eq 'type' )
      {
          # always set the type
          push @jobattributes, ( type => $self->jobTypeToName($self->{type}) );
      }
      elsif ( lc($att) eq 'verbose' || lc($att) eq 'persistent' || lc($att) eq 'cacheresult' || lc($att) eq 'upstream' )
      {
          # keep back the internal flags in short mode (except verbose)
          next if ( (lc($att) ne 'verbose') && ( $short || not defined $self->{lc($att)} ) );
          push @jobattributes, ( lc($att) => ( defined $self->{lc($att)} && ( $self->{lc($att)} =~ /^1$/  || $self->{lc($att)} =~ /^true$/ ) ) ? 1:0 );
      }
      else
      {
          # keep back optional metadata (in short mode) that is not required to process the job
          next if ($short && exists $optatt{$att});
          push @jobattributes, ( lc($att) => $self->{lc($att)} ) if defined $self->{lc($att)};
      }
  }

  $w->startTag('job', @jobattributes );
  # special handling for the 3 JOB_DATA_ELEMENTS types
  $w->cdataElement('stdout', $self->{stdout} )  if ( defined $self->{stdout}    && not (exists $config->{stdout}    && $config->{stdout}    == 0) );
  $w->cdataElement('stderr', $self->{stderr} )  if ( defined $self->{stderr}    && not (exists $config->{stderr}    && $config->{stderr}    == 0) );
  ## LATER: the following line should be used in the long term (instead of the one below)
  ##        this requires the latest smt-client package on the client systems, that are tolerant to missing XML elements
  ## $w->raw( $self->{arguments} ) if ( defined $self->{arguments} && not (exists $config->{arguments} && $config->{arguments} == 0) );
  # for backward compatibility return empty arguments element
  $w->raw( (defined $self->{arguments}) ? $self->{arguments} : "<arguments></arguments>" ) unless (exists $config->{arguments} && $config->{arguments} == 0);
  $w->endTag('job');
  $w->end();

  # only check if well formed, meaning: no handles and no styles for parser
  my $parser = new XML::Parser();
  eval { $parser->parse($xmlout) };
  if ($@) {
      my $_id = $self->{id};
      my $_guid = $self->{guid};
      SMT::Utils::printLog($self->{LOG}, VBLEVEL, LOG_ERROR, "Error: The job with ID ($_id) for the client with GUID ($_guid) rendered and error when the client tried to retrieve it");
      # return an undefined job type, will result in an error in the client and thus be reported
      $xmlout = '<job id="'.$_id.'" guid="'.$_guid.'" type="servererror" />';
  }

  return $xmlout;
}


##
## getters and setters
##

sub arguments
{
    my ( $self, $arguments ) = @_;
    $self->{arguments} = $arguments if defined( $arguments );
    return $self->{arguments};
}

#
# getArgumentsXML
#   kept for compatibility
#   please use arguments() directly and only write plain XML to arguments($xml)
#
sub getArgumentsXML
{
    my $self = shift;
    return $self->arguments();
}


sub id
{
      my ( $self, $id ) = @_;
      $self->{id} = $id if defined( $id );
      return $self->{id};
}

sub guid
{
      my ( $self, $guid ) = @_;
      $self->{guid} = $guid if defined( $guid );
      return $self->{guid};
}

sub guid_id
{
      my ( $self, $guid_id ) = @_;
      $self->{guid_id} = $guid_id if defined( $guid_id );

      # always query the guid_id, the guid might have changed in the meanwhile
      my $client = SMT::Client->new({ 'dbh' => $self->{dbh} });
      return undef unless defined $client;
      $self->{guid_id} = $client->getClientIDByGUID( $self->{guid} || undef );

      return $self->{guid_id};
}

sub parent_id
{
      my ( $self, $parent_id ) = @_;
      $self->{parent_id} = $parent_id if defined( $parent_id );
      return $self->{parent_id};
}

sub name
{
      my ( $self, $name ) = @_;
      $self->{name} = $name if defined( $name );
      return $self->{name};
}

sub description
{
      my ( $self, $description ) = @_;
      $self->{description} = $description if defined( $description );
      return $self->{description};
}

sub type
{
      my ( $self, $type ) = @_;
      $self->{type} = $type if defined( $type );
      return $self->{type};
}

sub status
{
      my ( $self, $status ) = @_;
      $self->{status} = $status if defined( $status );
      return $self->{status};
}

sub stdout
{
      my ( $self, $stdout ) = @_;
      $self->{stdout} = $stdout if defined( $stdout );
      return $self->{stdout};
}

sub stderr
{
      my ( $self, $stderr ) = @_;
      $self->{stderr} = $stderr if defined( $stderr );
      return $self->{stderr};
}

sub exitcode
{
      my ( $self, $exitcode ) = @_;
      $self->{exitcode} = $exitcode if defined( $exitcode );
      return $self->{exitcode};
}

sub created
{
      my ( $self, $created ) = @_;
      $self->{created} = $created if defined( $created );
      return $self->{created};
}

sub targeted
{
      my ( $self, $targeted ) = @_;
      $self->{targeted} = $targeted if defined( $targeted );
      return $self->{targeted};
}

sub expires
{
      my ( $self, $expires ) = @_;
      $self->{expires} = $expires if defined( $expires );
      return $self->{expires};
}

sub retrieved
{
      my ( $self, $retrieved ) = @_;
      $self->{retrieved} = $retrieved if defined( $retrieved );
      return $self->{retrieved};
}


sub finished
{
      my ( $self, $finished ) = @_;
      $self->{finished} = $finished if defined( $finished );
      return $self->{finished};
}

sub upstream
{
      my ( $self, $upstream ) = @_;
      $self->{upstream} = $upstream if defined( $upstream );
      return $self->{upstream};
}

sub cacheresult
{
      my ( $self, $cacheresult ) = @_;
      $self->{cacheresult} = $cacheresult if defined( $cacheresult );
      return $self->{cacheresult};
}

sub persistent
{
      my ( $self, $persistent ) = @_;
      $self->{persistent} = $persistent if defined( $persistent );
      return $self->{persistent};
}

sub verbose
{
      my ( $self, $verbose ) = @_;
      $self->{verbose} = $verbose if defined( $verbose );
      return $self->{verbose};
}

sub timelag
{
      my ( $self, $timelag ) = @_;
      $self->{timelag} = $timelag if defined( $timelag );
      return $self->{timelag};
}

sub message
{
      my ( $self, $message ) = @_;
      $self->{message} = $message if defined( $message );
      return $self->{message};
}

sub success
{
      my ( $self, $success ) = @_;
      $self->{success} = $success if defined( $success );
      return $self->{success};
}









###############################################################################
# writes error line to log
# returns undef because that is passed to the caller
sub error
{
    my $self = shift;
    my $message = shift;

    printLog( $self->{LOG}, VBLEVEL, LOG_ERROR, $message );

    return undef;
}


sub getNextAvailableJobID()
{
  my $self = shift;

  my $cookie = SMT::Utils::getDBTimestamp()." - ".rand(1024);

  my $sql1 = 'insert into JobQueue ( DESCRIPTION ) values ("'.$cookie.'")' ;
  $self->{dbh}->do($sql1) || return ( undef, $cookie);

  my $sql2 = 'select ID from JobQueue ';
     $sql2 .= ' where DESCRIPTION  = "'.$cookie.'"';

  my $id = $self->{dbh}->selectall_arrayref($sql2)->[0]->[0];

  return ($id, $cookie);

}

sub deleteJobIDCookie()
{
  my $self   = shift;
  my $id     = shift;
  my $cookie = shift;

  my $sql = "delete from JobQueue where ID = '$id' and DESCRIPTION = '$cookie'" ;
  return $self->{dbh}->do($sql);
}



sub resolveJobType
{
  my $self   = shift || return undef;
  my $type   = shift || return undef;

  return SMT::Job::Constants::JOB_TYPE->{ $type };
}

#
# jobTypeToName
#
#   Successor of the old "resolveJobType" function, that just toggled ID and Name
#
sub jobTypeToName
{
  my $self = shift || return undef;
  my $type = shift || return undef;

  return SMT::Job::Constants::JOB_TYPE->{$type} if $type =~ /^\d+$/;
  return ( exists SMT::Job::Constants::JOB_TYPE->{$type} ) ? $type : undef;
}

#
# jobTypeToID
#   Successor of the old "resolveJobType" function, that just toggled ID and Name
# argument: job type name or id
# returns the ID of the job type or "undef" if the job type does not exist
#
sub jobTypeToID
{
  my $self = shift || return undef;
  my $type = shift || return undef;

  return SMT::Job::Constants::JOB_TYPE->{$type} if $type !~ /^\d+$/;
  return ( exists SMT::Job::Constants::JOB_TYPE->{$type} ) ? $type : undef;
}

#
# jobStatusToName
#
#   return string representation of a job status
#   input can be ID or string
#
sub jobStatusToName
{
  my $self   = shift || return undef;
  my $status = shift || return undef;

  return SMT::Job::Constants::JOB_STATUS->{$status} if $status =~ /^\d+$/;
  return ( exists SMT::Job::Constants::JOB_STATUS->{$status} ) ? $status : undef;
}

#
# jobStatusToID
#
#   return ID of a job status
#   input can be ID or string
#
sub jobStatusToID
{
  my $self   = shift || return undef;
  my $status = shift || return undef;

  return SMT::Job::Constants::JOB_STATUS->{$status} if $status !~ /^\d+$/;
  return ( exists SMT::Job::Constants::JOB_STATUS->{$status} ) ? $status : undef;
}


1;

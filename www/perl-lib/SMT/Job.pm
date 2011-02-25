package SMT::Job;

use SMT::Utils;
use strict;
use warnings;
use XML::Simple;
use UNIVERSAL 'isa';

use constant
{
  VBLEVEL     => LOG_ERROR|LOG_WARN|LOG_INFO1|LOG_INFO2,

  JOB_STATUS =>
  {
      0  =>  'not yet worked on',
      1  =>  'successful',
      2  =>  'failed',
      3  =>  'denied by client',

      'not yet worked on' => 0,
      'successful' 	  => 1,
      'failed'            => 2,
      'denied by client'  => 3,
  },


  JOB_TYPE    =>
  {
    # Maps JOB_TYPE ID to JOB_TYPE NAME
    1       => 'patchstatus',
    2       => 'softwarepush',
    3       => 'update',
    4       => 'execute',
    5       => 'reboot',
    6       => 'configure',
    7       => 'wait',
    8       => 'eject',

    # Maps JOB_TYPE NAME to JOB_TYPE ID
    'patchstatus'   =>      1,
    'softwarepush'  =>      2,
    'update'        =>      3,
    'execute'       =>      4,
    'reboot'        =>      5,
    'configure'     =>      6,
    'wait'          =>      7,
    'eject'         =>      8,
  },
};




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
# creates a new job (for compatibility)
# please use if possible: readJobFromXML, readJobFromDatabase
#
sub newJob
{
    my $self = shift;
    my @params = @_;

    my $guid;
    my $id;
    my $type;
    my $arguments;

    my $message;
    my $exitcode;
    my $stdout;
    my $stderr;
    my $success;
    my $status;

    # Perl-only
    if ( defined ( $params[2] ) )
    {
        $guid = $params[0];
	$id   = $params[1];
	$type = $params[2];
	$arguments = $params[3];

	if ( ! ( isa ( $arguments, 'HASH' )))
        {
          eval { $arguments = XMLin( $arguments, forcearray => 1 ) };	# no arguments provided => use empty argument list
	  if ( $@ ) { $arguments = XMLin ( "<arguments></arguments>", forcearray => 1 ); }	
        }
    }
    elsif (! defined ( $params[1] ) )
    {
      # empty constructor
    }
    else
    {
	my $xmldata = $params[1];

	return error( $self, "unable to create job. xml does not contain a job description" ) unless ( defined ( $xmldata ) );
	return error( $self, "unable to create job. xml does not contain a job description" ) if ( length( $xmldata ) <= 0 );

	my $j;

	# parse xml
	eval { $j = XMLin( $xmldata,  forcearray => 1 ) };
	return error( $self, "unable to create job. unable to parse xml: $@" ) if ( $@ );
	return error( $self, "job description contains invalid xml" ) unless ( isa ($j, 'HASH' ) );

	# retrieve variables
	$id   	     = $j->{id}           if ( defined ( $j->{id} ) && ( $j->{id} =~ /^[0-9]+$/ ) );
	$type	     = $j->{type}         if ( defined ( $j->{type} ) );
	$arguments   = $j->{arguments}    if ( defined ( $j->{arguments} ) );
	$exitcode    = $j->{exitcode}     if ( defined ( $j->{exitcode} ) && ( $j->{exitcode} =~ /^[0-9]+$/ ) );
	$stdout	     = $j->{stdout}       if ( defined ( $j->{stdout} ) );
	$stderr      = $j->{stderr}       if ( defined ( $j->{stderr} ) );
	$message     = $j->{message}      if ( defined ( $j->{message} ) );
	$success     = $j->{success}      if ( defined ( $j->{success} ) );
	$status      = $j->{status}       if ( defined ( $j->{status} ) && ( $j->{status} =~ /^[0-9]+$/ ) );


	if ( defined $stdout  ) { $stdout =~ s/[\"\']//g;  }
	if ( defined $stderr  ) { $stderr =~ s/[\"\']//g;  }
	if ( defined $message ) { $message =~ s/[\"\']//g; }
	if ( defined $success ) { $success =~ s/[\"\']//g; }

    }

    $self->{id}   = $id;
    $self->{guid} = $guid;
    $self->{type} = $type;
    $self->{arguments} = $arguments;
    $self->{exitcode} = $exitcode;
    $self->{stdout} = $stdout;
    $self->{stderr} = $stderr;
    $self->{message} = $message;
    $self->{success} = $success;
    $self->{status} = $status;
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
  my $guidid = $client->getClientIDByGUID($guid) || return undef;

  my $sql = 'select * from JobQueue '
          . 'where ID      = ' . $self->{'dbh'}->quote($jobid)
          . 'and   GUID_ID = ' . $self->{'dbh'}->quote($guidid);

  my $result = $self->{'dbh'}->selectall_hashref($sql, 'ID')->{$jobid};
  return undef unless defined $result;

  $self->{id}        = $jobid;
  $self->{guid}      = $guid;

  $self->{type}      = SMT::Job::JOB_TYPE->{ $result->{TYPE} } if defined SMT::Job::JOB_TYPE->{$result->{TYPE}};

  if (exists $result->{ARGUMENTS} && defined $result->{ARGUMENTS})
  {
      $self->{arguments} = $self->arguments( $result->{ARGUMENTS} ); # convert xml to hash
  }

  my @attribs = qw(id parent_id name description status stdout stderr exitcode created targeted expires retrieved finished upstream cacheresult verbose timelag message success persistent);

  foreach my $attrib (@attribs)
  {
    $self->{$attrib} = $result->{uc($attrib) }  if ( defined $result->{uc($attrib)} );
  }
}


sub isValid
{
  my $self = shift;

  return (defined $self->{type} );
}


sub readJobFromHash
{
  my $self = shift || return undef;
  my $attribs = shift || return undef;

  foreach my $key (keys %$attribs)
  {
    $self->{$key} = $attribs->{$key};
  }
}


#
# read tags from xml and sets job attributes
#
sub readJobFromXML
{
  my $self = shift || return undef;
  my $guid = shift || return undef;
  my $xmldata = shift || return undef;

  return error( $self, "unable to create job. xml does not contain a job description" ) unless ( defined ( $xmldata ) );
  return error( $self, "unable to create job. xml does not contain a job description" ) if ( length( $xmldata ) <= 0 );

  my $j;

  # parse xml
  eval { $j = XMLin( $xmldata,  forcearray => 1 ) };
  return error( $self, "unable to create job. unable to parse xml: $@" ) if ( $@ );
  return error( $self, "job description contains invalid xml" ) unless ( isa ($j, 'HASH' ) );

  my @attribs = qw(id guid parent_id name description status stdout stderr exitcode created targeted expires retrieved finished upstream cacheresult verbose timelag message success persistent);

  foreach my $attrib (@attribs)
  {
    $self->{$attrib} = $j->{$attrib}  if ( defined $j->{$attrib} );
  }

  return error ( $self, "guid from xml does not match client's guid.") if ( defined $self->{guid} && $self->{guid} ne $guid );

  $self->{guid} = $guid;
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
  my $self = shift;
  my $cookie = undef;

  return undef unless defined $self->{guid};


  if ( defined $self->{parent_id} && defined $self->{id} && 
   $self->{parent_id}  =~ /^\d+$/ &&  $self->{id} =~ /^\d+$/ && 
   $self->{parent_id}  == $self->{id} )
  {
    return undef;
  }
  
  my $client = SMT::Client->new({ 'dbh' => $self->{dbh} });
  my $guidid = $client->getClientIDByGUID($self->{guid}) || return undef;

  if ( defined $self->{parent_id} )
  {
    $self->checkparentisvalid($self->{parent_id}, $guidid ) || return undef;
  }

  # retrieve next job id from database if no id is known
  if (!defined $self->{id})
  {
    (my $id, $cookie) = $self->getNextAvailableJobID();
    return undef unless defined $id and defined $cookie;
    $self->{id} = $id;
  }

  my $sql = "insert into JobQueue ";
  my @sqlkeys = ();
  my @sqlvalues = ();
  my @updatesql = ();
 
  my @attribs = qw(id parent_id name description status stdout stderr exitcode created targeted expires retrieved finished upstream cacheresult timelag message success);
 
  # VERBOSE
  push ( @sqlkeys, "VERBOSE" );
  push ( @sqlvalues,  ( defined $self->{verbose} && ( $self->{verbose} =~ /^1$/  || $self->{verbose} =~ /^true$/ ) ) ? '1':'0' );

  # PERSISTENT
  push ( @sqlkeys, "PERSISTENT" );
  push ( @sqlvalues,  ( defined $self->{persistent} && ( $self->{persistent} =~ /^1$/  || $self->{persistent} =~ /^true$/ ) ) ? '1':'0' );

  # TYPE
  push ( @sqlkeys, "TYPE" );
  push ( @sqlvalues,  $self->{type} =~ /^\d+$/ ? $self->{type} : SMT::Job::JOB_TYPE->{ $self->{type} } );

  # GUID
  push ( @sqlkeys, "GUID_ID" );
  push ( @sqlvalues, $self->{dbh}->quote($guidid) );

  # arguments
  push ( @sqlkeys, "ARGUMENTS" );
  push ( @sqlvalues, $self->{dbh}->quote( $self->getArgumentsXML() ) ); # hash to xml

  foreach my $attrib (@attribs)
  {
    if ( defined $self->{$attrib} )
    {
      push ( @sqlkeys, uc($attrib) );
      push ( @sqlvalues, $self->{dbh}->quote( $self->{$attrib} ));
      push ( @updatesql, uc($attrib) . " = " .  $self->{dbh}->quote( $self->{$attrib} ));
    }
  }
  $sql .= " (". join  (", ", @sqlkeys ) .") " ;
  $sql .= " values (". join  (", ", @sqlvalues ) .") " ;
  $sql .= " on duplicate key update ". join (", ", @updatesql );

  $self->{dbh}->do($sql) || return undef ;

  deleteJobIDCookie($self, $self->{id}, $cookie) if defined $cookie;

  return $self->{id};
}


#
# returns job in xml
#
sub asXML
{
    my ( $self ) = @_;

    return "<job/>" unless isValid( $self );

    my $job =
    {
      'id'        => $self->{id},
      'guid'      => $self->{guid},
      'type'      => $self->{type},
      'arguments' => $self->{arguments},
      'verbose'   => ( defined $self->{verbose} && $self->{verbose} eq "1" ) ? "true" : "false"

    };

    return XMLout($job, rootname => "job"
                     # , noattr => 1
                     , xmldecl => '<?xml version="1.0" encoding="UTF-8" ?>'
                 );
}




## 
## getters and setters
##

sub arguments
{
    my ( $self, $arguments ) = @_;
    $self->{arguments} = $arguments if defined( $arguments );

    # convert arguments given in xml to hash
    if ( ! ( isa ($self->{arguments}, 'HASH' )))
    {
	eval { $self->{arguments} = XMLin( $self->{arguments}, forcearray => 1 ) };
	return error( $self, "unable to set arguments. unable to parse xml argument list: $@" ) if ( $@ );
    }

    return $self->{arguments};
}


sub getArgumentsXML
{
    my ( $self ) = @_;
    return XMLout($self->{arguments}, rootname => "arguments");
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

  return JOB_TYPE->{ $type };
}

sub resolveJobStatus
{
  my $self   = shift || return undef;
  my $status = shift || return undef;

  return JOB_STATUS->{ $status };
}



1;

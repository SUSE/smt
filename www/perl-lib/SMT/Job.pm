package SMT::Job;

use SMT::Utils;
use strict;
use warnings;
use XML::Simple;
use UNIVERSAL 'isa';

use constant
{
  VBLEVEL     => LOG_ERROR|LOG_WARN|LOG_INFO1|LOG_INFO2,

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

    # Maps JOB_TYPE NAME to JOB_TYPE ID
    'patchstatus'   =>      1,
    'softwarepush'  =>      2,
    'update'        =>      3,
    'execute'       =>      4,
    'reboot'        =>      5,
    'configure'     =>      6,
    'wait'          =>      7,
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

# constructs a job
#
# new object:
#  my $job = Job->new ({ dbh => $dbh, LOG => '/var/log/smt/jobs.log' });
#
# perl arguments:
#  $job->newJob ( 'guid3', 42, 'softwarepush',
#    { 'packages' => [ { 'package' => [ 'xterm', 'yast2', 'firefox' ] } ], 'force' => [ 'true' ] } );
#
# xml only:
#  $job->newJob ( 'guid3', '<job id="42" type="softwarepush"><arguments><force>true</force></arguments></job>' );
#
# mixed perl and xml:
#  $job->newJob ( 'guid3', 42, 'softwarepush', '<arguments><force>true</force></arguments>' );

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

	return error( "2unable to create job. xml does not contain a job description" ) unless ( defined ( $xmldata ) );
	return error( "3unable to create job. xml does not contain a job description" ) if ( length( $xmldata ) <= 0 );

	my $j;

	# parse xml
	eval { $j = XMLin( $xmldata,  forcearray => 1 ) };
	return error( "4unable to create job. unable to parse xml: $@" ) if ( $@ );
	return error( "job description contains invalid xml" ) unless ( isa ($j, 'HASH' ) );

	# retrieve variables
	$id   	     = $j->{id}           if ( defined ( $j->{id} ) && ( $j->{id} =~ /^[0-9]+$/ ) );
	$type	     = $j->{type}         if ( defined ( $j->{type} ) );
	$arguments	     = $j->{arguments}    if ( defined ( $j->{arguments} ) );
	$exitcode    = $j->{exitcode}     if ( defined ( $j->{exitcode} ) && ( $j->{exitcode} =~ /^[0-9]+$/ ) );
	$stdout	     = $j->{stdout}       if ( defined ( $j->{stdout} ) );
	$stderr      = $j->{stderr}       if ( defined ( $j->{stderr} ) );
	$message     = $j->{message}      if ( defined ( $j->{message} ) );
	$success     = $j->{success}      if ( defined ( $j->{success} ) );


	$stdout =~ s/[\"\']//g;
	$stderr =~ s/[\"\']//g;
	$message =~ s/[\"\']//g;
	$success =~ s/[\"\']//g;

	# check variables
#	return error( "unable to create job. id unknown or invalid." )        unless defined( $id );
#	return error( "unable to create job. type unknown or invalid." )      unless defined( $type );
#	return error( "unable to create job. arguments unknown or invalid." ) unless defined( $arguments );
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
}

sub asXML
{
    my ( $self ) = @_;

    my $job =
    {
      'id'        => $self->{id},
      'guid'      => $self->{guid},
      'type'      => $self->{type},
      'arguments' => $self->{arguments}

    #TODO: add outher attributes

    };

    return XMLout($job, rootname => "job"
                     # , noattr => 1
                     , xmldecl => '<?xml version="1.0" encoding="UTF-8" ?>'
                 );
}




sub arguments
{
    my ( $self, $arguments ) = @_;
    $self->{arguments} = $arguments if defined( $arguments );

    # convert arguments given in xml to hash
    if ( ! ( isa ($self->{arguments}, 'HASH' )))
    {
	eval { $self->{arguments} = XMLin( $self->{arguments}, forcearray => 1 ) };
	return error( "unable to set arguments. unable to parse xml argument list: $@" ) if ( $@ );
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

sub parentid
{
      my ( $self, $parentid ) = @_;
      $self->{parentid} = $parentid if defined( $parentid );
      return $self->{guid};
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



1;


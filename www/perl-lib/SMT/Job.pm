package SMT::Job;

use SMT::Utils;
use strict;
use warnings;
use XML::Simple;
use UNIVERSAL 'isa';

use constant
{
    VBLEVEL	=> LOG_ERROR|LOG_WARN|LOG_INFO1|LOG_INFO2,

    JOB_TYPE	=>
    {
	# Maps JOB_TYPE ID to JOB_TYPE NAME
	1	=> 'patchstatus',
	2	=> 'softwarepush',
	3	=> 'update',
	4	=> 'execute',
	5	=> 'reboot',
	6	=> 'configure',
	7	=> 'wait',

	# Maps JOB_TYPE NAME to JOB_TYPE ID
	'patchstatus'	=>	1,
	'softwarepush'	=>	2,
	'update'	=>	3,
	'execute'	=>	4,
	'reboot'	=>	5,
	'configure'	=>	6,
	'wait'		=>	7,
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
    my $args;

    my $message;
    my $returnvalue;
    my $stdout;
    my $stderr;
    my $success;

    # Perl-only
    if ( defined ( $params[2] ) )
    {
        $guid = $params[0];
	$id   = $params[1];
	$type = $params[2];
	$args = $params[3];

	if ( ! ( isa ( $args, 'HASH' )))
        {
          eval { $args = XMLin( $args, forcearray => 1 ) };
	  return error( "unable to create job. unable to parse xml argument list: $@" ) if ( $@ );
        }
    }
    else
    {
	my $xmldata = $params[1];

	return error( "unable to create job. xml doesn't contain a job description" ) unless ( defined ( $xmldata ) );
	return error( "unable to create job. xml doesn't contain a job description" ) if ( length( $xmldata ) <= 0 );

	my $j;

	# parse xml
	eval { $j = XMLin( $xmldata,  forcearray => 1 ) };
	return error( "unable to create job. unable to parse xml: $@" ) if ( $@ );
	return error( "job description contains invalid xml" ) unless ( isa ($j, 'HASH' ) );

	#TODO: check values in order to prevent sql injection

	# retrieve variables
	$id   = $j->{id}        if ( defined ( $j->{id} ) && ( $j->{id} =~ /^[0-9]+$/ ) );
	$type = $j->{type}      if ( defined ( $j->{type} ) );
	$args = $j->{arguments} if ( defined ( $j->{arguments} ) );
	$returnvalue   = $j->{returnvalue} if ( defined ( $j->{returnvalue} ) && ( $j->{returnvalue} =~ /^[0-9]+$/ ) );
	$stdout = $j->{stdout}      if ( defined ( $j->{stdout} ) );
	$stderr = $j->{stderr}      if ( defined ( $j->{stderr} ) );
	$message = $j->{message}      if ( defined ( $j->{message} ) );
	$success = $j->{success}      if ( defined ( $j->{success} ) );


	$stdout =~ s/[\"\']//g;
	$stderr =~ s/[\"\']//g;
	$message =~ s/[\"\']//g;
	$success =~ s/[\"\']//g;
#
	# check variables
	return error( "unable to create job. id unknown or invalid." )        unless defined( $id );
#	return error( "unable to create job. type unknown or invalid." )      unless defined( $type );
#	return error( "unable to create job. arguments unknown or invalid." ) unless defined( $args );
    }

    $self->{id}   = $id;
    $self->{guid} = $guid;
    $self->{type} = $type;
    $self->{args} = $args;
    $self->{returnvalue} = $returnvalue;
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
      'arguments' => $self->{args}

    #TODO: add outher attributes

    };

    return XMLout($job, rootname => "job"
                     # , noattr => 1
                     , xmldecl => '<?xml version="1.0" encoding="UTF-8" ?>'
                 );
}

sub setId 
{
    my ( $self, $id ) = @_;
    $self->{id} = $id if defined( $id );
    return $self->{id};
}


sub getId
{
    my ( $self ) = @_;
    return $self->{id};
}


sub setType 
{
    my ( $self, $type ) = @_;
    $self->{type} = $type if defined( $type );
    return $self->{type};
}


sub getType
{
    my ( $self ) = @_;
    return $self->{type};
}


sub setArguments
{
    my ( $self, $args ) = @_;
    $self->{args} = $args if defined( $args );

    # convert args given in xml to hash
    if ( ! ( isa ($self->{args}, 'HASH' )))
    {
	eval { $self->{args} = XMLin( $self->{args}, forcearray => 1 ) };
	return error( "unable to set arguments. unable to parse xml argument list: $@" ) if ( $@ );
    }

    return $self->{args};
}


sub getArguments
{
    my ( $self ) = @_;
    return $self->{args};
}

sub getReturnValue
{
    my ( $self ) = @_;
    return $self->{returnvalue};
}

sub getStdout
{
    my ( $self ) = @_;
    return $self->{stdout};
}

sub getStderr
{
    my ( $self ) = @_;
    return $self->{stderr};
}

sub getMessage
{
    my ( $self ) = @_;
    return $self->{message};
}

sub getSuccess
{
    my ( $self ) = @_;
    return $self->{success};
}

sub getArgumentsXML
{
    my ( $self ) = @_;
    return XMLout($self->{args}, rootname => "arguments");
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


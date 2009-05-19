package SMT::Job;

use SMT::Utils;
use strict;
use warnings;
use XML::Simple;
use UNIVERSAL 'isa';

# constructs a job
#
# perl arguments:
#  my $job = new Job ( 42, "softwarepush", { 'packages' => [ { 'package' => [ 'xterm', 'yast2', 'firefox' ] } ], 'force' => [ 'true' ] } );
#
# xml only:
#  my $job = new Job ( <job id="42" type="softwarepush"><arguments><force>true</force></arguments></job>" );
#
# mixed perl and xml:
#  my $job = new Job ( 42, "softwarepush", "<arguments><force>true</force></arguments>" );

sub new
{
    my $class = shift;

    my $arg0 = shift;
    my $arg1 = shift;
    my $arg2 = shift;
    my $arg3 = shift;

    my $guid;
    my $id;
    my $type;
    my $args;

    if ( defined ( $arg2 ) )
    {
        $guid = $arg0;
	$id   = $arg1;
	$type = $arg2;
	$args = $arg3;

	if ( ! ( isa ( $args, 'HASH' )))
        {
          eval { $args = XMLin( $args, forcearray => 1 ) };
	  return error( "unable to create job. unable to parse xml argument list: $@" ) if ( $@ );
        }
    }
    else
    {
	my $xmldata = $arg1;

	return error( "unable to create job. xml doesn't contain a job description" ) unless ( defined ( $xmldata ) );
	return error( "unable to create job. xml doesn't contain a job description" ) if ( length( $xmldata ) <= 0 );

	my $j;

	# parse xml
	eval { $j = XMLin( $xmldata,  forcearray => 1 ) };
	return error( "unable to create job. unable to parse xml: $@" ) if ( $@ );
	return error( "job description contains invalid xml" ) unless ( isa ($j, 'HASH' ) );

	# retrieve variables
	$id   = $j->{id}        if ( defined ( $j->{id} ) && ( $j->{id} =~ /^[0-9]+$/ ) );
	$type = $j->{type}      if ( defined ( $j->{type} ) );
	$args = $j->{arguments} if ( defined ( $j->{arguments} ) );

	# check variables
	return error( "unable to create job. id unknown or invalid." )        unless defined( $id );
	return error( "unable to create job. type unknown or invalid." )      unless defined( $type );
	return error( "unable to create job. arguments unknown or invalid." ) unless defined( $args );
    }

    my $self = 
    {
	id   => $id,
	guid => $guid,
	type => $type,
	args => $args,
    };

    bless $self, $class;
    return $self;
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
    my $message = shift;

    my $log = SMT::Utils::openLog();
#    printLog( $log, $self->vblevel(), LOG_ERROR, $message );



    print "$message\n";
    return undef;
}



1;


package Job;

use strict;
use warnings;
use XML::Simple;
use UNIVERSAL 'isa';

sub new
{
    my $class = shift;
    my $self = 
    {
	_id   => shift,
	_type => shift,
	_args => shift,
    };

    # convert args given in xml to hash
    if ( ! ( isa ($self->{_args}, 'HASH' )))
    {
      $self->{_args} = XMLin( $self->{_args}, forcearray => 1 );
    }

    bless $self, $class;
    return $self;
}


sub asXML
{
    my ( $self ) = @_;

    my $job =
    {
      'id'        => $self->{_id},
      'jobtype'   => $self->{_type},
      'arguments' => $self->{_args}
    };

    return XMLout($job, rootname => "job");
}


sub setId 
{
    my ( $self, $id ) = @_;
    $self->{_id} = $id if defined( $id );
    return $self->{_id};
}


sub getId
{
    my ( $self ) = @_;
    return $self->{_id};
}


sub setType 
{
    my ( $self, $type ) = @_;
    $self->{_type} = $type if defined( $type );
    return $self->{_type};
}


sub getType
{
    my ( $self ) = @_;
    return $self->{_type};
}


sub setArguments
{
    my ( $self, $args ) = @_;
    $self->{_args} = $args if defined( $args );

    # convert args given in xml to hash
    if ( ! ( isa ($self->{_args}, 'HASH' )))
    {
      $self->{_args} = XMLin( $self->{_args}, forcearray => 1 );
    }

    return $self->{_args};
}


sub getArguments
{
    my ( $self ) = @_;
    return $self->{_args};
}


sub getArgumentsXML
{
    my ( $self ) = @_;
    return XMLout($self->{_args}, rootname => "arguments");
}



1;


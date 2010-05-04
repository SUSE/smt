package SMT::RegParams;
use strict;
use XML::Parser;
use YAML;

use Data::Dumper;

# constructor
sub new
{
  my $pkgname = shift;
  my %opt   = @_;

  my $self          = {};

  # optional (default) or mandatory
  $self->{accept}   = $opt{accept}   || "optional";

  # "", "registration" or "batch"
  $self->{force}    = $opt{force}    || "";

  $self->{products}  = $opt{products}  || [];
  $self->{params}   = $opt{params}   || {};

  $self->{privacy}  = 0;
  $self->{LOG}      = $opt{log} || undef;

  $self->{wasInteractive} = 0;
  my $id = `/usr/bin/uuidgen 2>/dev/null`;
  chomp($id);
  $self->{websessionid} = $id;
  
  bless($self);

  return $self;
}

sub parse
{
  my $self        = shift;
  my $registerxml = shift;

  return 0 if(!defined $registerxml || $registerxml eq "");

  my $regparser = XML::Parser->new(
    Handlers => { Start => sub { reg_handle_start_tag($self, @_) },
                  Char  => sub { reg_handle_char_tag($self, @_) },
                  End   => sub { reg_handle_end_tag($self, @_) }
                }
  );

  eval {
    $regparser->parse( $registerxml );
  };
  if($@)
  {
    # ignore the errors, but print them
    chomp($@);
    $self->{LOG}->log_error("SMT::Registration::register Invalid XML: $@");
  }

  return 1;
}

sub yaml
{
  my $self = shift;
  return YAML::Dump( $self );
}

sub joinSession
{
  my $self = shift;
  my $yaml = shift;
  my $expectedSessionID = shift || undef;

  return 1 if(! defined $yaml || $yaml eq "");

  my $session = YAML::Load( $yaml );

  # GUID should be the same; if not => error
  if($session->{params}->{guid} ne $self->guid())
  {
    $self->{LOG}->log_error("Guids do not match");
    return 0;
  }
  
  # if expectedSessionID is given, but they do not match the one
  # in the session => abort
  if(defined $expectedSessionID &&
     $session->{websessionid} ne $expectedSessionID)
  {
    $self->{LOG}->log_error("Session IDs do not match");
    return 0;
  }

  # if the session has already a uuid, overwrite the new one
  if( exists $session->{websessionid} && defined $session->{websessionid} &&
      $session->{websessionid} ne "")
  {
    $self->{websessionid} = $session->{websessionid};
  }

  if( $self->acceptOptional() )
  {
    $self->{accept} = $session->{accept};
  }

  if( $self->{force} eq "" )
  {
    $self->{force} = $session->{force};
  }

  if( @{$self->{products}} == 0 )
  {
    $self->{products} = $session->{products};
  }

  foreach my $id (keys %{$session->{params}})
  {
    if( ! exists $self->{params}->{$id} )
    {
      $self->param($id, $session->{params}->{$id});
    }
  }
  
  $self->{wasInteractive} = $session->{wasInteractive};
  
  return 1;
}

sub sessionID
{
  my $self = shift;
  return $self->{websessionid};
}

sub wasInteractive
{
  my $self = shift;
  if (@_) { $self->{wasInteractive} = shift };
  return $self->{wasInteractive};
}

sub param
{
  my $self = shift;
  my $key  = shift;
  return undef if( ! defined $key || $key eq "");
  if (@_)
  {
    $self->{params}->{$key} = shift;
  }
  return $self->{params}->{$key} if(exists $self->{params}->{$key});
  return undef;
}

sub params
{
  my $self = shift;
  if (@_) { $self->{params} = shift };
  return $self->{params};
}

sub products
{
  my $self = shift;
  if (@_) { $self->{products} = shift };
  return $self->{products};
}

sub guid
{
  my $self = shift;
  if (@_) { $self->param("guid", shift); };
  return $self->param("guid");
}

sub accept
{
  my $self = shift;
  if (@_) { $self->{accept} = shift };
  return $self->{accept};
}

sub acceptOptional
{
  my $self = shift;
  return ($self->accept() ne "mandatory")
}

sub acceptMandatory
{
  my $self = shift;
  return ($self->accept() eq "mandatory")
}

sub force
{
  my $self = shift;
  if (@_) { $self->{force} = shift };
  return $self->{force};
}

sub privacy
{
  my $self = shift;
  if (@_) { $self->{privacy} = shift };
  return $self->{privacy};
}

sub reg_handle_start_tag
{
  my $self = shift;
  my( $expat, $element, %attrs ) = @_;
  
  if(lc($element) eq "param")
  {
    if(exists $attrs{id} && defined $attrs{id} && $attrs{id} ne "")
    {
      $self->{TMP}->{ELEMENT} = lc($element);
      $self->{TMP}->{ID}      = $attrs{id};
      $self->{TMP}->{TEXT}    = "";
    }
  }
  elsif(lc($element) eq "product")
  {
    $self->{TMP}->{ELEMENT} = lc($element);
    $self->{TMP}->{product} = \%attrs;
    $self->{TMP}->{product}->{name} = "";
  }
  elsif(lc($element) eq "register")
  {
    if(exists $attrs{accept} && defined $attrs{accept} && lc($attrs{accept}) eq "mandatory")
    {
      $self->{accept} = "mandatory";
    }
    if(exists $attrs{force} && defined $attrs{force} && lc($attrs{force}) ne "")
    {
      $self->{force} = lc($attrs{force});
    }
  }
  elsif(lc($element) eq "host")
  {
    # we handle host as param
    $self->{TMP}->{ELEMENT} = "param";
    $self->{TMP}->{ID} = "host";
    $self->{TMP}->{TEXT} = "";
    if(exists $attrs{type} && defined $attrs{type} && $attrs{type} ne "")
    {
      $self->param("virttype", $attrs{type});
    }
  }
  elsif(lc($element) eq "guid")
  {
    # we handle guid as param
    $self->{TMP}->{ELEMENT} = "param";
    $self->{TMP}->{ID} = "guid";
    $self->{TMP}->{TEXT} = "";
  }
}

sub reg_handle_char_tag
{
  my $self = shift;
  my( $expat, $string) = @_;

  return if($self->{TMP}->{ELEMENT} eq "");

  if($self->{TMP}->{ELEMENT} eq "param")
  {
    $self->{TMP}->{TEXT} .= $string;
  }
  elsif($self->{TMP}->{ELEMENT} eq "product")
  {
    $self->{TMP}->{product}->{name} .= $string;
  }
}

sub reg_handle_end_tag
{
  my $self = shift;
  my( $expat, $element) = @_;
  
  if(lc($element) eq "param" || $self->{TMP}->{ELEMENT} eq "param")
  {
    $self->param($self->{TMP}->{ID}, $self->{TMP}->{TEXT});
    delete $self->{TMP}->{ID};
    delete $self->{TMP}->{TEXT};
  }
  elsif(lc($element) eq "product")
  {
    my %prod = ( name => $self->{TMP}->{product}->{name},
                 version => $self->{TMP}->{product}->{version},
                 release => $self->{TMP}->{product}->{release},
                 arch => $self->{TMP}->{product}->{arch} );
    push @{$self->{products}}, \%prod;
    delete $self->{TMP}->{product};
  }
  elsif(lc($element) eq "register")
  {
    delete $self->{TMP};
  }
}

1;

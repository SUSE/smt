package SMT::RegSession;

use strict;
use DBI;
use SMT::Utils;
use Log::Log4perl qw(get_logger :levels);

# constructor
sub new
{
  my $pkgname = shift;
  my %opt   = @_;

  my $self          = {};
  $self->{GUID}     = $opt{guid} || "";
  $self->{DBH}      = $opt{dbh}  || undef;
  $self->{YAML}     = $opt{yaml} || "";
  $self->{INDB}     = 0;
  $self->{LOG}      = get_logger();
  bless($self);

  return $self;
}

sub loadSession
{
  my $self = shift;

  return 0 if(!defined $self->{DBH});
  return 0 if(!defined $self->{GUID} || $self->{GUID} eq "");

  my $timestamp = SMT::Utils::getDBTimestamp(time()-300);
  my $statement = sprintf("DELETE from reg_sessions where updated_at < %s", $self->{DBH}->quote( $timestamp ) );
  $self->{LOG}->debug("STATEMENT: $statement");
  $self->{DBH}->do( $statement );

  $statement = sprintf("SELECT yaml from reg_sessions WHERE guid = %s", $self->{DBH}->quote($self->{GUID}));
  $self->{LOG}->debug("STATEMENT: $statement");
  my $arr = $self->{DBH}->selectall_arrayref($statement, { Slice => {} } );
  if( @{$arr} == 1 )
  {
    $self->{YAML} = $arr->[0]->{yaml};
    $self->{INDB} = 1;
  }
}

sub yaml
{
  my $self = shift;
  return $self->{YAML};
}

sub updateSession
{
  my $self = shift;
  my $yaml = shift;
  my $statement = "";

  return 0 if(!defined $self->{DBH});
  return 0 if(!defined $self->{GUID} || $self->{GUID} eq "");

  if( $self->{INDB} )
  {
    $statement = sprintf("UPDATE reg_sessions set yaml = %s WHERE guid = %s",
                         $self->{DBH}->quote($yaml),
                         $self->{DBH}->quote($self->{GUID}));
    $self->{LOG}->debug("STATEMENT: $statement");
    $self->{DBH}->do( $statement );
  }
  else
  {
    $statement = sprintf("INSERT INTO reg_sessions (guid, yaml) VALUES (%s, %s)",
                         $self->{DBH}->quote($self->{GUID}),
                         $self->{DBH}->quote($yaml));
    $self->{LOG}->debug("STATEMENT: $statement");

    $self->{DBH}->do( $statement );
  }
  return 1;
}

sub cleanSession
{
  my $self = shift;

  return 0 if(!defined $self->{DBH});
  return 0 if(!defined $self->{GUID} || $self->{GUID} eq "");

  if( $self->{INDB} )
  {
    my $statement = sprintf("DELETE from reg_sessions where guid = %s", $self->{DBH}->quote($self->{GUID}));
    $self->{LOG}->debug("STATEMENT: $statement");
    $self->{DBH}->do( $statement );
  }
  $self->{YAML} = "";
  $self->{INDB} = 0;
  return 1;
}

1;

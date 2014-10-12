package SMT::DB;

use DBI qw(:sql_types);
@ISA = qw(DBI);

use strict;

my $dbh;

package SMT::DB::db;
our @ISA = qw/DBI::db/;

sub sequence_nextval {
  my $self = shift;
  my $sequence = shift;

  my $sth;
  $sth = $self->prepare('select nextval(?)');
  $sth->execute($sequence);

  my ($ret) = $sth->fetchrow;
  $sth->finish;

  return $ret;
}

sub do_h {
  my $self = shift;
  my $query = shift;
  my @params = @_;

  my $sth = $self->prepare($query);
  $sth->execute_h(@params);
}

package SMT::DB::st;
our @ISA = qw/DBI::st/;

sub execute_h {
  my $self = shift;
  my @params = @_;

  $self->set_err(99998, "Odd number of params to execute_h") if @params % 2;

  while (my ($k, $v) = (splice @params, 0, 2, ())) {

    # this allows for inout binds; for instance, DELETE and INSERT with RETURNING clauses
    if (ref $v eq 'SCALAR') {
      $self->bind_param_inout(":$k" => $v, 4096);
    }
    else {
      $self->bind_param(":$k" => $v);
    }
  }

  return $self->execute();
}

1;

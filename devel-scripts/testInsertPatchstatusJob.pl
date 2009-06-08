#!/usr/bin/perl -wT

use SMT::Client;
use Data::Dumper;
use SMT::Utils;

$dbh = SMT::Utils::db_connect();
exit 1 unless defined $dbh;

$client = SMT::Client->new({'dbh' => $dbh});
if ( $client->insertPatchstatusJob("guid17") )
{  print "yes\n";  }


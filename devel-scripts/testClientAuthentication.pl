#!/usr/bin/perl -wT

use SMT::Client;
use Data::Dumper;
use SMT::Utils;

$dbh = SMT::Utils::db_connect();
exit 1 unless defined $dbh;
$cro = SMT::Client->new({'dbh' => $dbh});

$res = undef;

#$res = $cro->getClientsInfo({
#    'GUID' => 'guid15'
#   ,'SECRET' => 'secret15' 
#                            });
$res = $cro->authenticateByIDAndSecret('15', 'secret15');
print Data::Dumper->Dump([$res],["id15-auth"])."\n";

#$res = $cro->getClientsInfo({
#    'GUID' => 'guid15'
#   ,'SECRET' => '' 
#                                   });
$res = $cro->authenticateByIDAndSecret('15', undef);
print Data::Dumper->Dump([$res],["id15-auth-wrong"])."\n";

$res = $cro->getClientsInfo({
    'ID' => '15'
   ,'selectAll' => ''
   ,'SECRET' => undef
                                   });
print Data::Dumper->Dump([$res],["id15-auth-all"])."\n";

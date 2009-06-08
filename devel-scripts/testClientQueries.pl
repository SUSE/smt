#!/usr/bin/perl -wT

use SMT::Client;
use Data::Dumper;
use SMT::Utils;

$dbh = SMT::Utils::db_connect();
exit 1 unless defined $dbh;
$cro = SMT::Client->new({'dbh' => $dbh});

$res = undef;

$res = $cro->getClientsInfo({
    'ID' => '16'
   ,'selectAll' => '' 
                                   });
print Data::Dumper->Dump([$res],["id16-selAll"])."\n";

$res = $cro->getClientsInfo({
    'PATCHSTATUS' => ':5::'
   ,'selectAll' => '' 
                                   });
print Data::Dumper->Dump([$res],["patchstatus"])."\n";

$res = $cro->getClientInfoByGUID('guid16');
print Data::Dumper->Dump([$res],["guid16-infoByGUID"])."\n";

$res = $cro->getClientInfoByID(17);
print Data::Dumper->Dump([$res],["id17-infoByIDselAll"])."\n";

$res = $cro->getAllClientsInfo();
print Data::Dumper->Dump([$res],["all"])."\n";

$res = $cro->getClientIDByGUID("guid11");
print Data::Dumper->Dump([$res],["id18-idByGUID"])."\n";

$res = $cro->getClientGUIDByID(18);
print Data::Dumper->Dump([$res],["guid18-guidByID"])."\n";

$res = $cro->getClientPatchstatusByID(19);
print Data::Dumper->Dump([$res],["id19-patchstatusByID"])."\n";

$res = $cro->getClientPatchstatusByGUID("guid14");
print Data::Dumper->Dump([$res],["guid20-patchstatusByGUID"])."\n";





=pod
getClientsInfo($)
getClientInfoByGUID($)
getClientInfoByID($)
getAllClientsInfo()
getClientGUIDByID($)
getClientIDByGUID($)
getClientPatchstatusByID($)
getClientPatchstatusByGUID($)
=cut


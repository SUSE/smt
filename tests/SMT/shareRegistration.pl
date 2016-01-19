#!/usr/bin/perl
use warnings;
use strict;

use Data::Dumper;
use Config::IniFiles;
use Getopt::Long;
use SMT::Utils;
use WWW::Curl::Easy;

my $smtHost;
my $config;
GetOptions ('config=s' => \$config,
            'host=s' => \$smtHost);

if (! $smtHost && ! $config) {
    my $msg = 'Must specify the target SMT server with --host or config '
        . "file with --config.\n";
    print $msg;
    exit 1;
}

if ($config && ! -f $config) {
    print "could not find configuration file '$config'\n";
    exit 1;
}

my $regInfo = "<?xml version='1.0' encoding='UTF-8'?>"
    . "<registrationData>"
    . "<tableData table='Clients'>"
    . "<entry comulmnName='NAMESPACE' value=''/>"
    . "<entry comulmnName='HOSTNAME' value='smt-client'/>"
    . "<entry comulmnName='TARGET' value='sle-11-x86_64'/>"
    . "<entry comulmnName='GUID' value='03a8f41f176d4776aed0ea2263ea82c4'/>"
    . "<entry comulmnName='SECRET' value='efaf1ed2f80a4548b4904dc5888f9958'/>"
    . "<entry comulmnName='DESCRIPTION' value=''/>"
    . "<entry comulmnName='REGTYPE' value='SR'/>"
    . "<entry comulmnName='LASTCONTACT' value='2014-08-27 13:41:11'/>"
    . "</tableData>"
    . "<tableData table='Registration'>"
    . "<entry comulmnName='REGDATE' value='2014-08-26 09:58:15'/>"
    . "<entry comulmnName='NCCREGERROR' value='0'/>"
    . "<entry comulmnName='NCCREGDATE' value=''/>"
    . "<entry comulmnName='GUID' value='03a8f41f176d4776aed0ea2263ea82c4'/>"
    . "<entry comulmnName='PRODUCTID' value='100550'/>"
    . "</tableData>"
    . "</registrationData>";

my $shareRegDataTargets;
my $certPath;

if ($config) {
    my $cfg = new Config::IniFiles( -file => $config );
    $shareRegDataTargets = $cfg->val('LOCAL', 'shareRegistrations');
    if (! $shareRegDataTargets) {
        print "No registration sharing configured in '$config'\n";
        exit 1;
    }
    $certPath = $cfg->val('LOCAL', 'siblingCertDir');
}
else {
    $shareRegDataTargets = $smtHost;
}

my @smtSiblings = split /,/, $shareRegDataTargets;
for my $smtServer (@smtSiblings) {
    my $ua = SMT::Utils::createUserAgent();
    if ($certPath) {
        $ua->setopt(CURLOPT_CAPATH, $certPath);
    }
    my $url = "https://$smtServer/center/regsvc"
                . '?command=shareregistration'
                . '&lang=en-US&version=1.0';
    my $response = $ua->post($url, Content=>$regInfo);

    if (! $response->is_success) {
        my $dd = Data::Dumper->new([ $response ]);
        print $dd->Dump();
        print "Test FAILED for host '$smtServer'\n";
    }
    else {
        print "SUCCESS for host '$smtServer'\n";
    }
}



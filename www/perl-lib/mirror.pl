#!/usr/bin/env perl

use YEP::Mirror::RpmMd;

#my $url = 'https://MIRRORUSER:MIRRIRPASSWORD@nu.novell.com/repo/repoindex.xml';

$mirror = YEP::Mirror::RpmMd->new();
$mirror->uri( "http://download.opensuse.org/repositories/home:/dmacvicar/openSUSE_10.3" );
$mirror->mirrorTo( "/space/git/suse/yep/www/repo", { urltree => 0 } );


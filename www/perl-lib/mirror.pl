#!/usr/bin/env perl

use YEP::Mirror::RpmMd;

$mirror = YEP::Mirror::RpmMd->new();
$mirror->uri( "http://download.opensuse.org/repositories/home:/dmacvicar/openSUSE_10.3" );
$mirror->mirrorTo( "/space/git/suse/yep/www/repo", { urltree => 0 } );


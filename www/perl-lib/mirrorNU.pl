#!/usr/bin/env perl

use YEP::Mirror::NU;

$mirror = YEP::Mirror::NU->new();
$mirror->uri( 'https://MIRRORUSER:MIRRIRPASSWORD@nu.novell.com');
$mirror->mirrorTo( "/srv/www/htdocs/", { urltree => 0 } );


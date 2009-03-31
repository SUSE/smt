#! /usr/bin/perl -w

BEGIN
{
	push @INC, ".";
};

use strict;
use English;
use Sys::GRP;
use POSIX;
use User::pwent;
my $user = "tux";

my $pw = getpwnam($user) || return 0;
my $primgroup= $pw->gid();

print "UID: $UID\n";
print "EUID: $EUID\n";
print "GID: $GID\n";
print "EGID: $EGID\n";

$GID = $primgroup;
$EGID = $primgroup;
my $ret = Sys::GRP::initgroups($user, $primgroup);
print "RET: $ret \n";

POSIX::setuid( $pw->uid() ) || return 0;

print "UID: $UID\n";
print "EUID: $EUID\n";
print "GID: $GID\n";
print "EGID: $EGID\n";

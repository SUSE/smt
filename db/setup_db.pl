#!/usr/bin/env perl

use SMT::Utils;
use DBIx::Migration::Directories;
use DBIx::Transaction;

sub db_connect
{
    my $cfg = new Config::IniFiles( -file => "/etc/smt.conf" );
    if(!defined $cfg)
    {
        # FIXME: is die correct here?
        die sprintf(__("Cannot read the SMT configuration file: %s"), @Config::IniFiles::errors);
    }
    
    my $config = $cfg->val('DB', 'config');
    my $user   = $cfg->val('DB', 'user');
    my $pass   = $cfg->val('DB', 'pass');
    if(!defined $config || $config eq "")
    {
        # FIXME: is die correct here?
        die __("Invalid Database configuration. Missing value for DB/config.");
    }
     
    my $dbh    = DBIx::Transaction->connect($config, $user, $pass, {RaiseError => 1, AutoCommit => 1});

    return $dbh;
}


if ( not $dbh=db_connect() )
{
    die __("ERROR: Could not connect to the database");
}


my $m = DBIx::Migration::Directories->new(
   base                    => '/usr/share/schemas',
   schema                  => 'smt',
#   desired_version_from    => 'MyApp::DataPackage',
   dbh                     => $dbh
);
 
$m->migrate or die "Installing database failed!";

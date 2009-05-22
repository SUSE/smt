#!/usr/bin/env perl

package SMT::Agent::Config;
use SMT::Agent::Utils;
use Config::IniFiles;
use strict;
use warnings;


my $smtUrl = undef;
my $guid   = undef;
my $secret = undef;

sub smtUrl
{
  if (! defined ( $smtUrl ))
  {
    $smtUrl = readSmtUrl();
  }
    
  return $smtUrl;
};


sub getGuid
{
  if (! defined ( $guid ))
  {
    ($guid, $secret) = readCredentials();
  }
    
  return $guid;
};

sub getSecret
{
  if (! defined ( $secret ))
  {
    ($guid, $secret) = readCredentials();
  }
    
  return $secret;
};






sub readSmtUrl
{
  my $uri;
  open(FH, "< /etc/suseRegister.conf") or error ("Cannot open /etc/suseRegister.conf");
  while(<FH>)
  {
    if($_ =~ /^url\s*=\s*(\S*)\s*/ && defined $1 && $1 ne "")
    {
      $uri = $1;
      last;
    }
  }
  close FH;
  if(!defined $uri || $uri eq "")
  {
    SMT::Agent::Utils::error("Cannot read URL from /etc/suseRegister.conf");
  }
  return $uri;
};


sub getSyconfigValue
{
  my $key  = shift;
  my $val  = undef;

  if ( open(CNF, "< ".SMT::Agent::Constants::CLIENT_CONFIG_FILE)) 
  {
    while(<CNF>)
    {
      if($_ =~ /^\s*#/)
      {
       next;
      }
	elsif($_ =~ /^$key\s*=\s*"*(.+)"+\s*/ && defined $1 && $1 ne "")
      {
	$val = $1;
      }
    }
    close CNF;
  }
  return $val;
};



sub readCredentials
{
  my $guid   = "";
  my $secret = "";

  # read credentials from NCCcredentials file on SLE11 clients
  if ( open(CRED, "< ".SMT::Agent::Constants::CREDENTIALS_FILE) )
  {
    while(<CRED>)
    {
      if($_ =~ /username\s*=\s*(.*)$/ && defined $1 && $1 ne "")
      {
        $guid = $1;
      }
      if($_ =~ /password\s*=\s*(.*)$/ && defined $1 && $1 ne "")
      {
        $secret = $1;
      }
    }
    close CRED;
  }

  # read device id and secret on SLE10 clients
  if ( $guid eq "" && $secret eq "" )
  {
    if ( open(DEVID, "< ".SMT::Agent::Constants::DEVICEID_FILE) )
    {
      while(<DEVID>)
      {
	chomp ($_);
	$guid = $_;
      }
    }
    if ( open(SEC, "< ".SMT::Agent::Constants::SECRET_FILE) )
    {
      while(<SEC>)
      {
	chomp ($_);
	$secret = $_;
      }
    }
  }
  
  
  if ( $guid eq "" && $secret eq "" )
  {
    SMT::Agent::Utils::error ("Cannot read client credentials, please register this client first.");    
  }

  return ( $guid, $secret);
}



1;













1;

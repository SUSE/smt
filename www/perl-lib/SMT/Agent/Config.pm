#!/usr/bin/env perl

package SMT::Agent::Config;
use SMT::Agent::Utils;
use Config::IniFiles;


use strict;
use warnings;



my $smtUrl = undef;

sub smtUrl
{
  if (! defined ( $smtUrl ))
  {
    $smtUrl = readSmtUrl();
  }
    
  return $smtUrl;
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


sub getSMTClientConfig
{
  my $section = shift;
  my $key = shift;

  my $cfg = new Config::IniFiles( -file => SMT::Agent::Constants::CLIENT_CONFIG_FILE );
  if(!defined $cfg)
  {
    SMT::Agent::Utils::error("Cannot read the SMT client configuration file");
  }

  return $cfg->val($section, $key);
};


sub getSyconfigValue
{
  my $file = shift;
  my $key  = shift;
  my $val  = undef;

  if ( open(CNF, "< $file")) 
  {
    while(<CNF>)
    {
      if($_ =~ /^\s*#/)
      {
       next;
      }
      elsif($_ =~ /^$key\s*=\s*"*([^"\s]*)"*\s*/ && defined $1 && $1 ne "")
      {
	$val = $1;
      }
    }
    close CNF;
  }
  return $val;
};


1;

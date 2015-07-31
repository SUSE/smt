#!/usr/bin/env perl

package SMT::Agent::Config;
use SMT::Agent::Utils;
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
  open(FH, "< ".SMT::Agent::Constants::SUSEREGISTER_CONF) or SMT::Agent::Utils::error("Cannot open ".SMT::Agent::Constants::SUSEREGISTER_CONF);
  while(<FH>)
  {
    if($_ =~ /^url\s*[=:]\s*(\S*)\s*/ && defined $1 && $1 ne "")
    {
      $uri = $1;
      last;
    }
  }
  close FH;

  $uri =~ s/^([hH][tT][tT][Pp][Ss]:\/\/[^\/]+)\/.*/$1/ ;

  if(!defined $uri || $uri eq "")
  {
    SMT::Agent::Utils::error("Cannot read URL from ".SMT::Agent::Constants::SUSEREGISTER_CONF);
  }
  return $uri;
};


sub getSysconfigValue
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
#	elsif($_ =~ /^$key\s*=\s*"*(.+)"+\s*/ && defined $1 && $1 ne "")
	elsif($_ =~ /^$key\s*=\s*"(.*)"\s*/ && defined $1 && $1 ne "")
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

  # read credentials from SCCcredentials file on SLE11 clients
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


sub getProxySettings
{
    my $httpsProxy = SMT::Agent::Config::getSysconfigValue( "HTTPS_PROXY" );
    my $proxyUser  = SMT::Agent::Config::getSysconfigValue( "PROXY_USER" );
    
    $httpsProxy = undef if(defined $httpsProxy && $httpsProxy =~ /^\s*$/);
    $proxyUser  = undef if(defined $proxyUser  && $proxyUser =~ /^\s*$/);
    
    if(! defined $httpsProxy)
    {
        if(exists $ENV{https_proxy} && defined $ENV{https_proxy} && $ENV{https_proxy} =~ /^http/)
        {
            # required for Crypt::SSLeay HTTPS Proxy support
            $httpsProxy = $ENV{https_proxy};
        }
    }

    # strip trailing /
    $httpsProxy  =~ s/\/*$// if(defined $httpsProxy);

    if(! defined $proxyUser)
    {
        if( -r "/root/.curlrc")
        {
            # read /root/.curlrc
            open(RC, "< /root/.curlrc") or return ($httpsProxy, undef);
            while(<RC>)
            {
                if($_ =~ /^\s*proxy-user\s*=\s*"(.+)"\s*$/ && defined $1 && $1 ne "")
                {
                    $proxyUser = $1;
                }
                elsif($_ =~ /^\s*--proxy-user\s+"(.+)"\s*$/ && defined $1 && $1 ne "")
                {
                    $proxyUser = $1;
                }
            }
            close RC;
        }
    }
    else
    {
        if($proxyUser =~ /^\s*"?(.+)"?\s*$/ && defined $1)
        {
            $proxyUser = $1;
        }
        else 
        {
            $proxyUser = undef;
        }
    }

    return ($httpsProxy, $proxyUser);
}



1;


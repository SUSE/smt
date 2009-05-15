#!/usr/bin/env perl

package SMTConfig;

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
}


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
    error("Cannot read URL from /etc/suseRegister.conf");
  }
  return $uri;
}


1;

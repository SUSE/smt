#! /usr/bin/perl -w

BEGIN {
    push @INC, "../www/perl-lib";
}

use strict;
use Test::Simple tests => 3;
use Cwd;
#use File::Temp;

#use File::Copy;
#use SMT::Utils;
#use Data::Dumper;

use SMT::Parser::RpmMdOtherFilter;


#my $fh = new File::Temp(); # file to write the new metadata
my $wd = Cwd::cwd();       # current working dir

# packages to remove
my $toremove =
{
  'f7cb8f0f00d3434f723e4681b5cc6c5bef937463' => {
                                                'rel' => '60.6.1',
                                                'epo' => '0',
                                                'arch' => 'noarch',
                                                'ver' => '7.3.6',
                                                'name' => 'logwatch'
                                              },
  '1e6928c73b0409064f05f5af87af2a79b4f64dc9' => {
                                                'rel' => '49.12.1',
                                                'epo' => '0',
                                                'arch' => 'i586',
                                                'ver' => '1.3.5',
                                                'name' => 'audacity'
                                              }
};

#my $log = SMT::Utils::openLog('/local/jkupec/tmp/smt.log');
#my $vblevel = LOG_DEBUG|LOG_DEBUG2|LOG_WARN|LOG_ERROR|LOG_INFO1|LOG_INFO2;

my $parser = SMT::Parser::RpmMdOtherFilter->new(); # log => $log, vblevel => $vblevel); 
$parser->resource($wd . '/testdata/rpmmdtest/code11repo'); # FIXME this should use the testdir

$parser->parse('repodata/filelists.xml.gz', $toremove); #); use $fh if test of the written file is needed
my $parsed = $parser->removed();
ok ((keys %$parsed) == 2);

$parser->parse('repodata/other.xml.gz', $toremove);
$parsed = $parser->removed();
ok ((keys %$parsed) == 2);

$parser->parse('repodata/susedata.xml.gz', $toremove);
$parsed = $parser->removed();
ok ((keys %$parsed) == 2);

#$fh->flush;
#copy("$fh", $wd.'/outfile.xml');

#!/usr/bin/perl


use strict;
use warnings;
use SMT::Utils;
use SMT::JobQueue;
use SMT::Job;
use Data::Dumper;


my $dbh = SMT::Utils::db_connect();
exit 1 unless defined $dbh;
my $c = SMT::JobQueue->new({'dbh' => $dbh});


#print $c->getNextJobID("guid10", 0);
#print $c->retrieveJob("guid10", 42,1);
#print $c->finishJob("guid10", 42,1);
#my ($id, $cookie) = $c->getNextAvailableJobID();
#print "$id - $cookie";
#
#print $c->getNextAvailableJobID();


#if ( $c->deleteJobIDCookie($id, $cookie) )
#{
#  print "success";
#}
#else
#{
#  print "fail";
#}


my $job = SMT::Job->new({ 'dbh' => $dbh });
$job->newJob();
$job->type("softwarepush");
$job->guid("guid10");
$job->description("thomastest");
#$job->id(102);

#print $job->asXML();
#print Dumper($job);

#print $c->addJob($job);

if ( $c->addJobForMultipleGUIDs($job, ("guid10", "guid12", "guid11")) )
{
  print "success";
}
else
{
  print "err";
}



#print SMT::JobQueue->updateJob("guid10", '<job id="43" message="softwarepush failed" returnvalue="5" stderr="&lt;?xml version=\'1.0\'?&gt;\n&lt;stream&gt;\n&lt;message type=&quot;error&quot;&gt;Root privileges are required for installing or uninstalling packages.&lt;/message&gt;\n&lt;/stream&gt;" stdout="" success="false" />' );

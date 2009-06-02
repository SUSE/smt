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
$job->guid("guid11");
$job->description("thomastest");
$job->arguments("<arguments><thomas>true</thomas></arguments>");
$job->expires("2009-08-02 20:07:20");
$job->targeted("2009-02-02 20:07:20");
if ( $c->addJob($job) )
{
  print "successfully added\n\n";
}

print "Next id: ". $c->getNextJobID()."\n";

print $c->getJob("guid11",$c->getNextJobID("guid11", 0),1);


if ( $c->finishJob("guid11", "<job id='44' message='a'><success>true</success></job>"))
{
  print "successfully finished\n\n";
}





#print $job->asXML();
#print Dumper($job);


#if ( $c->addJobForMultipleGUIDs($job, ("guid10", "guid12", "guid11")) )
#{
#  print "success";
#}
#else
#{
#  print "err";
#}


#print $c->retrieveJob("guid11", 44,1);

#print SMT::JobQueue->updateJob("guid10", '<job id="43" message="softwarepush failed" returnvalue="5" stderr="&lt;?xml version=\'1.0\'?&gt;\n&lt;stream&gt;\n&lt;message type=&quot;error&quot;&gt;Root privileges are required for installing or uninstalling packages.&lt;/message&gt;\n&lt;/stream&gt;" stdout="" success="false" />' );

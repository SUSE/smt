#!/usr/bin/env perl

package SMT::Agent::Constants;

use strict;
use warnings;


# script that processes jobs
use constant PROCESSJOB 	=> '/usr/lib/SMT/bin/processjob';

# config file for smt server url
use constant SUSEREGISTER_CONF	=> '/etc/suseRegister.conf';

# path for job handlers (like softwarepush) 
use constant JOB_HANDLER_PATH	=> '/usr/lib/SMT/bin/job';

# rest path for retriving next job id 
#use constant REST_NEXT_JOB	=> '/cgi-bin/smt.cgi/=v1=/smt/job/id/next';
use constant REST_NEXT_JOB	=> '/=/1/jobs/@next';

# rest path for job update (trailing slash is important)
use constant REST_UPDATE_JOB	=> '/cgi-bin/smt.cgi/=v1=/smt/job/id/';

# rest path for job pickup (trailing slash is important)
#use constant REST_GET_JOB	=> '/cgi-bin/smt.cgi/=v1=/smt/job/id/';
use constant REST_GET_JOB	=> '/=/1/jobs/';

# log file
use constant LOG_FILE		=> '/tmp/smtclient.log';

# client config file
use constant CLIENT_CONFIG_FILE	=> '/etc/sysconfig/smtclient';



1;

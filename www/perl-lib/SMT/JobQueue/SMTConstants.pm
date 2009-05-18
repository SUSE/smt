#!/usr/bin/env perl

package SMTConstants;

use strict;
use warnings;


# script that processes jobs
use constant PROCESSJOB 	=> '/home/store/yep/trunk/www/perl-lib/SMT/JobQueue/processjob.pl';

# config file for smt server url
use constant SUSEREGISTER_CONF	=> '/etc/suseRegister.conf';

# rest path for job update (trailing slash is important)
use constant JOB_HANDLER_PATH	=> '/home/store/yep/trunk/www/perl-lib/SMT/JobQueue/';

# rest path for retriving next job id 
use constant REST_NEXT_JOB	=> '/cgi-bin/smt.cgi/=v1=/smt/job/id/next';

# rest path for job update (trailing slash is important)
use constant REST_UPDATE_JOB	=> '/cgi-bin/smt.cgi/=v1=/smt/job/id/';

# rest path for job pickup (trailing slash is important)
use constant REST_GET_JOB	=> '/cgi-bin/smt.cgi/=v1=/smt/job/id/';

# log file
use constant LOG_FILE		=> '/tmp/smtclient.log';

# client config file
use constant CLIENT_CONFIG_FILE	=> '/tmp/smtclient.conf';



1;

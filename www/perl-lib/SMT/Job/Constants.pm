#
# constants for SMT JobQueue
#

package SMT::Job::Constants;

use strict;
use warnings;

use constant
{
  JOB_STATUS =>
  {
      0  =>  'not yet worked on',
      1  =>  'successful',
      2  =>  'failed',
      3  =>  'denied by client',

      'not yet worked on' => 0,
      'successful'    => 1,
      'failed'            => 2,
      'denied by client'  => 3,
  },

  # Job type ID range
  #    0 -  511 : reserved for jobs shipped by vendor
  #  512 - 1023 : custom jobs added by user/customer
  JOB_TYPE    =>
  {
    # Maps JOB_TYPE ID to JOB_TYPE NAME
    1       => 'patchstatus',
    2       => 'softwarepush',
    3       => 'update',
    4       => 'execute',
    5       => 'reboot',
    6       => 'configure',
    7       => 'wait',
    8       => 'eject',
    51      => 'createjob',
    52      => 'report',
    53      => 'inventory',

    # Maps JOB_TYPE NAME to JOB_TYPE ID
    'patchstatus'   =>      1,
    'softwarepush'  =>      2,
    'update'        =>      3,
    'execute'       =>      4,
    'reboot'        =>      5,
    'configure'     =>      6,
    'wait'          =>      7,
    'eject'         =>      8,
    'createjob'     =>     51,
    'report'        =>     52,
    'inventory'     =>     53,
  }
};


1;

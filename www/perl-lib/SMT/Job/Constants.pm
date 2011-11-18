#
# constants for SMT JobQueue
#

package SMT::Job::Constants;

use strict;
use warnings;

use constant
{
  # the status values 0, 4, 5 and 6 are interpreted as successful
  # so chained jobs will be delivered, the only difference is that attention should be drawn to the message
  JOB_STATUS =>
  {
      0  =>  'queued',
      1  =>  'successful',
      2  =>  'failed',
      3  =>  'denied by client',
      4  =>  'warning',
      5  =>  'action needed',
      6  =>  'reboot needed',

      'queued'            => 0,
      'successful'        => 1,
      'failed'            => 2,
      'denied by client'  => 3,
      'warning'           => 4,
      'action needed'     => 5,
      'reboot needed'     => 6
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


## Constants for job data (may not be encapsulated into a hash like structure like above)
##
# basic attributes: only primary keys and foreign key
use constant JOB_DATA_BASIC => qw(id parent_id guid);
  # all attributes that are attributes (in the job XML repersentation) to the job and are not not a CData section or a XML snippet itself
use constant JOB_DATA_ATTRIBUTES => qw(type name description status exitcode created targeted expires retrieved finished upstream cacheresult verbose timelag message persistent);
  # sub-elements of the job (in the job XML representation) that need special handling (CData, XML snippet)
use constant JOB_DATA_ELEMENTS => qw(stdout stderr arguments);


1;

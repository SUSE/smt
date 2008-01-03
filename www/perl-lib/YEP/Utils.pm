package YEP::Utils;

use strict;
use warnings;

use APR::Brigade ();
use APR::Bucket ();
use Apache2::Filter ();

use Apache2::Const -compile => qw(OK SERVER_ERROR :log MODE_READBYTES);
use APR::Const    -compile => qw(:error SUCCESS BLOCK_READ);

use constant IOBUFSIZE => 8192;

use Config::IniFiles;
use DBI;


#
# read the content of a POST and return the data
#
sub read_post {
    my $r = shift;
    
    my $bb = APR::Brigade->new($r->pool,
                               $r->connection->bucket_alloc);
    
    my $data = '';
    my $seen_eos = 0;
    do {
        $r->input_filters->get_brigade($bb, Apache2::Const::MODE_READBYTES,
                                       APR::Const::BLOCK_READ, IOBUFSIZE);
        
        for (my $b = $bb->first; $b; $b = $bb->next($b)) {
            if ($b->is_eos) {
                $seen_eos++;
                last;
            }
            
            if ($b->read(my $buf)) {
                $data .= $buf;
            }
            
            $b->remove; # optimization to reuse memory
        }
        
    } while (!$seen_eos);
    
    $bb->destroy;
    
    return $data;
}

#
# read db values from the yep configuration file,
# open the database and returns the database handle
#
sub db_connect
{
    my $cfg = new Config::IniFiles( -file => "/etc/yep.conf" );
    if(!defined $cfg)
    {
        # FIXME: is die correct here?
        die "Cannot read the YEP configuration file: ".@Config::IniFiles::errors;
    }
    
    my $config = $cfg->val('DB', 'config');
    my $user   = $cfg->val('DB', 'user');
    my $pass   = $cfg->val('DB', 'pass');
    if(!defined $config || $config eq "")
    {
        # FIXME: is die correct here?
        die "Invalid Database configuration. Missing value for DB/config.";
    }
     
    my $dbh    = DBI->connect($config, $user, $pass);

    return $dbh;
}


1;

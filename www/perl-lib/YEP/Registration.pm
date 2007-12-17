package YEP::Registration;

use strict;
use warnings;

use Apache2::RequestRec ();
use Apache2::RequestIO ();
use APR::Brigade ();
use APR::Bucket ();
use Apache2::Filter ();

use Apache2::Const -compile => qw(OK SERVER_ERROR :log MODE_READBYTES);
use APR::Const    -compile => qw(:error SUCCESS BLOCK_READ);

use constant IOBUFSIZE => 8192;

use Data::Dumper;
use DBI;

sub handler {
    my $r = shift;
    
    $r->content_type('text/xml');

    my $args = $r->args();
    my $hargs = {};
    
    foreach my $a (split(/\&/, $args))
    {
        chomp($a);
        my ($key, $value) = split(/=/, $a, 2);
        $hargs->{$key} = $value;
    }
    $r->warn("Registration called with args: ".Data::Dumper->Dump([$hargs]));
    
    if(exists $hargs->{command} && defined $hargs->{command})
    {
        if($hargs->{command} eq "register")
        {
            YEP::Registration::register($r, $hargs);
        }
        elsif($hargs->{command} eq "listproducts")
        {
            YEP::Registration::listproducts($r, $hargs);
        }
        elsif($hargs->{command} eq "listparams")
        {
            YEP::Registration::listparams($r, $hargs);
        }
        else
        {
            $r->log_error("Unknown command: $hargs->{command}");
            return Apache2::Const::SERVER_ERROR;
        }
    }
    else
    {
        $r->log_error("Missing command");
        return Apache2::Const::SERVER_ERROR;
    }
    
    return Apache2::Const::OK;
}

#
# called from handler if client wants to register
# command=register argument given
#
sub register
{
    my $r     = shift;
    my $hargs = shift;

    return;
}

#
# called from handler if client wants the product list
# command=listproducts argument given
#
sub listproducts
{
    my $r     = shift;
    my $hargs = shift;

    $r->warn("listproducts called: ".Data::Dumper->Dump([$r]).",".Data::Dumper->Dump([$hargs]));
    
    # FIXME: find better path to the Database
    my $dbh = DBI->connect("dbi:SQLite:dbname=/srv/www/yep.db","","");
    
    my $sth = $dbh->prepare("SELECT DISTINCT PRODUCT FROM Products where product_list = 'Y'");
    $sth->execute();
    
    print '<?xml version="1.0" encoding="UTF-8"?>'."\n";
    print '<productlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="en">';
    while ( my @row = $sth->fetchrow_array ) 
    {
        print '<product>'.$row[0].'</product>';
    }
    print '</productlist>';
    
    $dbh->disconnect();
    
    return;
}

#
# called from handler if client wants to fetch the parameter list
# command=listparams argument given
#
sub listparams
{
    my $r     = shift;
    my $hargs = shift;

    $r->warn("listparams called: ".Data::Dumper->Dump([$r]).",".Data::Dumper->Dump([$hargs]));
    
    my $data = YEP::Registration::read_post($r);
    
    #print '<?xml version="1.0" encoding="UTF-8"?>'."\n";
    #print "<data>\n";
    #print "$data";
    #print "</data>\n";
    

    # FIXME: find better path to the Database
    my $dbh = DBI->connect("dbi:SQLite:dbname=/srv/www/yep.db","","");
    
    my @pr = (["openSUSE-10.3-retail", "10.3", "0", "i686"], ["openSUSE-10.3-FTP",  "10.3", "0", "i686"]);

    my $statement = "SELECT PARAMLIST FROM Products where ";

    #foreach my $row (@pr)
    #{
    #    $statement .= "(PRODUCT = '$row[0]' and";
    #    $statement .= "VERSION = '$row[1]' and";
    #    $statement .= "RELEASE = '$row[2]' and";
    #    $statement .= "ARCH    = '$row[3]' )";
    #}
    
#    my $sth = $dbh->prepare($statement);
#    $sth->execute();
#    
#    print '<?xml version="1.0" encoding="UTF-8"?>'."\n";
#    print '<productlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="en">';
#    while ( my @row = $sth->fetchrow_array ) 
#    {
#        print '<product>'.$row[0].'</product>';
#    }
#    print '</productlist>';


    return;
}

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


1;


package SMT::Job;

use strict;
use warnings;


###############################################################################
# converts a string containing job arguments in xml format into a hash
# in other words: converts the format from the database into 
#a format XMLout can handle
#
# args:    job arguments (string)
# returns: job arguments (hash)
sub arg2hash
{
    my $xmldata = $_[0];
    my $dat = XMLin( $xmldata, forcearray => 1 );
    return $dat;
}


###############################################################################
# converts a job description into xml format
# args:    job id        (int)
#          job type      (string)
#          job args, xml (string)
#
# returns: xml job description
sub job2xml
{
    my ($jobid, $jobtype, $args) =  @_;

    my $job =
    {
        'jobtype' => $jobtype,
        'id' => $jobid,
        'arguments' =>  arg2hash( $args )
    };

    my $xmldata = XMLout( $job, rootname => "job" );
    return $xmldata;
}




sub  {
    my $r = shift;
    #my $dbh = undef;
    #
    # try to connect to the database - else report server error
    #if ( ! ($dbh=SMT::Utils::db_connect()) ) 
    #{  
    #    return Apache2::Const::SERVER_ERROR; 
    #}

    
    $r->content_type('text/xml');
    $r->err_headers_out->add('Cache-Control' => "no-cache, public, must-revalidate");
    $r->err_headers_out->add('Pragma' => "no-cache");

    my $writer = new XML::Writer(NEWLINES => 0);
    $writer->xmlDecl("UTF-8");

    # just some dummy XML for a quick test ...
    $writer->startTag("jobs4smt");

    $writer->emptyTag('onejob',
                      'id'   =>  42,
                      'method'   => $r->method(),
                 # this is the path we have to parse
                      'pathinfo' => $r->path_info(),
                 # this is the full request path (including the offset)
                      'unparsed_uri' => $r->unparsed_uri(),
                      'user'         => $r->user(),
                 # we do not nee args
                      'args'         => $r->args()
                     );       

    $writer->endTag("jobs4smt");

    return Apache2::Const::OK;
}
1;

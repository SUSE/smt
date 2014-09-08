package SMT::ConnectAPI;

use SMT::Rest::SCCAPIv1;
use SMT::Rest::SCCAPIv2;
use SMT::Rest::SCCAPIv3;
use SMT::Utils;
use Apache2::Const -compile => qw(HTTP_NOT_ACCEPTABLE :log);
use JSON;

#
# Apache Handler
# this is the main function of this request handler
#
sub handler {
    my $r = shift;
    my $api = undef;

    my $apiVersion = SMT::Utils::requestedAPIVersion($r);
    if (not $apiVersion)
    {
        $r->status(Apache2::Const::HTTP_NOT_ACCEPTABLE);
        $r->content_type('application/json');
        $r->custom_response(Apache2::Const::HTTP_NOT_ACCEPTABLE, "");
        print encode_json({ 'error' => "API version not supported",
                            'localized_error' => "API version not supported",
                            'status' => Apache2::Const::HTTP_NOT_ACCEPTABLE });
        return Apache2::Const::HTTP_NOT_ACCEPTABLE;
    }
    $r->err_headers_out->add('scc-api-version' => "v$apiVersion");

    if ( $apiVersion == 1 )
    {
        $api = SMT::Rest::SCCAPIv1->new($r);
        return $api->handler();
    }
    elsif ( $apiVersion == 2 )
    {
        $api = SMT::Rest::SCCAPIv2->new($r);
        return $api->handler();
    }
    elsif ( $apiVersion == 3 )
    {
        $api = SMT::Rest::SCCAPIv3->new($r);
        return $api->handler();
    }
    elsif ( $apiVersion == 4 )
    {
        # there is currently no difference between v3 and v4
        # in the parts we provide. So also use v3 here.
        $api = SMT::Rest::SCCAPIv3->new($r);
        return $api->handler();
    }
    else
    {
        return Apache2::Const::HTTP_NOT_ACCEPTABLE;
    }
}

1;

package SMT::ConnectAPI;

use SMT::Rest::SCCAPIv4;
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

    # API v1 - v3 deprecated and not supported anymore
    if ( $apiVersion == 4 )
    {
        $api = SMT::Rest::SCCAPIv4->new($r);
        return $api->handler();
    }
    else
    {
        return Apache2::Const::HTTP_NOT_ACCEPTABLE;
    }
}

1;

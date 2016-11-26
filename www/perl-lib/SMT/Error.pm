package SMT::Error;

use SMT::Utils;
use Apache2::Const -compile => qw(:log OK SERVER_ERROR NOT_FOUND);
use JSON;

#
# Apache Handler
# this is the main function of this request handler
#
sub handler {
    my $r = shift;
    # only /connect pages get json response errors
    if ($r->prev() && $r->prev()->uri() =~ /\/connect\//)
    {
        $r->content_type('application/json');
        if ($r->path_info() eq "/401") {
            # tell the browser the error
            $r->log->error("Unauthorized");
            $r->status(Apache2::Const::HTTP_UNAUTHORIZED);
            $r->custom_response(Apache2::Const::HTTP_UNAUTHORIZED, "");
            print encode_json(
              { 'error' => "This server could not verify that you are authorized to access this service.",
                'localized_error' => "This server could not verify that you are authorized to access this service.",
                'status' => Apache2::Const::HTTP_UNAUTHORIZED }
            );
        }
        elsif ($r->path_info() eq "/404")
        {
            # tell the browser the error
            $r->log->error("Page Not Found");
            $r->status(Apache2::Const::NOT_FOUND);
            $r->custom_response(Apache2::Const::NOT_FOUND, "");
            print encode_json(
              { 'error' => "Page Not Found: Please contact your Administrator",
                'localized_error' => "Page Not Found: Please contact your Administrator",
                'status' => Apache2::Const::NOT_FOUND }
            );
        }
        else
        {
            # tell the browser the error
            $r->log->error("Internal Server Error");
            $r->status(Apache2::Const::SERVER_ERROR);
            $r->custom_response(Apache2::Const::SERVER_ERROR, "");
            print encode_json(
              { 'error' => "Internal Server Error: Please contact your Administrator",
                'localized_error' => "Internal Server Error: Please contact your Administrator",
                'status' => Apache2::Const::SERVER_ERROR }
            );
        }
        # tell apache engine that everything is OK to not print the HTML standard error page
        return Apache2::Const::OK
    }
}

1;

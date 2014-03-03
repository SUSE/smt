package SMT::SCCApi;

use strict;
use SMT::Curl;
use SMT::Utils;
use JSON;
use Data::Dumper;

# constructor
sub new
{
    my $pkgname = shift;
    my %opt   = @_;
    my $self  = {};

    $self->{VBLEVEL} = 0;
    $self->{LOG}   = undef;
    $self->{USERAGENT}  = undef;
    $self->{URL} = "https://scc.suse.com/connect";

    if(exists $opt{url} && $opt{url})
    {
        $self->{URL} = $opt{URL}
    }
    if(exists $opt{vblevel} && defined $opt{vblevel})
    {
        $self->{VBLEVEL} = $opt{vblevel};
    }

    if(exists $opt{log} && defined $opt{log} && $opt{log})
    {
        $self->{LOG} = $opt{log};
    }
    else
    {
        $self->{LOG} = SMT::Utils::openLog();
    }
    if(exists $opt{useragent} && $opt{useragent})
    {
        $self->{USERAGENT} = $opt{useragent};
    }
    else
    {
        $self->{USERAGENT} = SMT::Utils::createUserAgent(log => $self->{LOG}, vblevel => $self->{VBLEVEL});
        $self->{USERAGENT}->protocols_allowed( [ 'https'] );
    }

    bless($self);
    return $self;
}

sub request
{
    my $self = shift;
    my $url = shift;
    my $method = shift;
    my $headers = shift;
    my $body = shift;

    if ($url !~ /^http/)
    {
        printLog($self->{LOG}, $self->{VBLEVEL}, LOG_ERROR, "Invalid URL");
        return undef;
    }

    my $response = undef;
    if ($method == "get")
    {
        $response = $self->{USERAGENT}->get($url, %{$headers});
    }
    elsif ($method == "head")
    {
        $response = $self->{USERAGENT}->head($url, %{$headers});
    }
    elsif ($method == "post")
    {
        $response = $self->{USERAGENT}->post($url, %{$headers}, 'content' => JSON::encode_json($body));
    }
    elsif ($method == "put")
    {
        $response = $self->{USERAGENT}->put($url, %{$headers}, 'content' => JSON::encode_json($body));
    }
    else
    {
        printLog($self->{LOG}, $self->{VBLEVEL}, LOG_ERROR, "Invalid method");
        return undef;
    }
    if($response->is_success)
    {
        if ($response->content_type() == "application/json")
        {
            return JSON::decode_json($response->content);
        }
        else
        {
            printLog($self->{LOG}, $self->{VBLEVEL}, LOG_ERROR, "Unexpected Content Type");
            return undef;
        }
    }
    printLog($self->{LOG}, $self->{VBLEVEL}, LOG_ERROR, "Unexpected Error");
    return undef;
}

sub announce
{
    my $self = shift;
    my %opts = @_;
    my $uri = $self->{URL}."/subscriptions/systems"

    my $body = {
        "email" => $opts{email},
        "hostname" => SMT::Utils::getFQDN(),
        "hwinfo" => ""
      }
      printLog($self->{LOG}, $self->{VBLEVEL}, LOG_INFO1,
               "Announce data: ".Data::Dumper->dump($body), 0);

      my $headers = {"Authorization" => "Token token=\"".$opts{reg_code}."\""};
      return $self->request($uri, "post", $headers, $body);
}

sub products
{
    my $self = shift;
    my $uri = $self->{URL}."/products"
    printLog($self->{LOG}, $self->{VBLEVEL}, LOG_INFO1,
        "list products", 0);

    return $self->request($uri, "get", {}, {});

}

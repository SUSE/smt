=head1 NAME

SMT::SCCAPI - Module to use the SCC REST API

=head1 DESCRIPTION

Module to use the SCC REST API

=over 4

=cut

package SMT::SCCAPI;

use strict;
use SMT::Curl;
use SMT::Utils;
use JSON;
use URI;
use Data::Dumper;

=item constructor

  SMT::SCCSync->new(...)

  * url
  * authuser
  * authpass
  * log
  * vblevel
  * useragent

=cut

sub new
{
    my $pkgname = shift;
    my %opt   = @_;
    my $self  = {};

    $self->{VBLEVEL} = 0;
    $self->{LOG}   = undef;
    $self->{USERAGENT}  = undef;
    $self->{URL} = "https://scc.suse.com/connect";
    $self->{AUTHUSER} = "";
    $self->{AUTHPASS} = "";
    $self->{IDENT} = "";

    if(exists $opt{url} && $opt{url})
    {
        $self->{URL} = $opt{url};
    }
    if(exists $opt{vblevel} && defined $opt{vblevel})
    {
        $self->{VBLEVEL} = $opt{vblevel};
    }
    if(exists $opt{authuser} && $opt{authuser})
    {
        $self->{AUTHUSER} = $opt{authuser};
    }
    if(exists $opt{authpass} && $opt{authpass})
    {
        $self->{AUTHPASS} = $opt{authpass};
    }
    if(exists $opt{ident} && $opt{ident})
    {
        $self->{IDENT} = $opt{ident};
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

=item announce([@opts])

Announce a system at SCC.

Options:

  * email
  * reg_code

In case of an error it returns "undef".

=cut

sub announce
{
    my $self = shift;
    my %opts = @_;
    my $uri = $self->{URL}."/subscriptions/systems";

    my $body = {
        "email" => $opts{email},
        "hostname" => SMT::Utils::getFQDN(),
        "hwinfo" => ""
    };
    printLog($self->{LOG}, $self->{VBLEVEL}, LOG_INFO1,
             "Announce data: ".Data::Dumper->dump($body), 0);

    my $headers = {"Authorization" => "Token token=\"".$opts{reg_code}."\""};
    return $self->_request($uri, "post", $headers, $body);
}

=item products

List all products.

Returns json structure containing all products with its repositories.
In case of an error it returns "undef".

Example:

    [
      {
        'release_type' => undef,
        'zypper_name' => 'SLES',
        'repos' => [
                     {
                       'format' => undef,
                       'name' => 'SLES12-Pool',
                       'distro_target' => 'sle-12-x86_64',
                       'url' => 'https://nu.novell.com/suse/x86_64/update/SLE-SERVER/12-POOL',
                       'id' => 1150,
                       'description' => 'SLES12-Pool for sle-12-x86_64',
                       'tags' => [
                                   'enabled',
                                   'autorefresh'
                                 ]
                     },
                     {
                       'format' => undef,
                       'name' => 'SLES12-Updates',
                       'distro_target' => 'sle-12-x86_64',
                       'url' => 'https://nu.novell.com/suse/x86_64/update/SLE-SERVER/12',
                       'id' => 1151,
                       'description' => 'SLES12-Updates for sle-12-x86_64',
                       'tags' => [
                                   'enabled',
                                   'autorefresh'
                                 ]
                     }
                   ],
        'arch' => 'x86_64',
        'zypper_version' => '12',
        'id' => 1117,
        'friendly_name' => 'SUSE Linux Enterprise Server BETA TEST 12 x86_64',
        'product_class' => '7261'
      }
    ]

=cut

sub products
{
    my $self = shift;
    my $uri = $self->{URL}."/products";
    printLog($self->{LOG}, $self->{VBLEVEL}, LOG_INFO1,
             "list products", 0);

    return $self->_request($uri, "get", {}, {});
}

=item services

List all services.

Returns json structure containing all services with its repositories.
In case of an error it returns "undef".

=cut

sub services
{
    my $self = shift;
    my $uri = URI->new($self->{URL}."/services");
    printLog($self->{LOG}, $self->{VBLEVEL}, LOG_INFO1,
             "list services", 0);

    return $self->_request($uri, "get", {}, {});
}

=item org_subscriptions

List subscriptions of an organization.

Returns json structure containing subscriptions of an organization with its
system ids consuming it.
In case of an error it returns "undef".

Example:



=cut

sub org_subscriptions
{
    my $self = shift;
    my $uri = URI->new($self->{URL}."/organizations/subscriptions");
    if($self->{AUTHUSER} && $self->{AUTHPASS})
    {
        $uri->userinfo($self->{AUTHUSER}.":".$self->{AUTHPASS});
    }
    printLog($self->{LOG}, $self->{VBLEVEL}, LOG_INFO1,
             "list organization subscriptions", 0);

    return $self->_request($uri->as_string(), "get", {}, {});
}

=item org_repos

List repositories accessible by an organization.

Returns json structure containing repositories accessible by an organization.
In case of an error it returns "undef".

Example:



=cut

sub org_repos
{
    my $self = shift;
    my $uri = URI->new($self->{URL}."/organizations/repositories");
    if($self->{AUTHUSER} && $self->{AUTHPASS})
    {
        $uri->userinfo($self->{AUTHUSER}.":".$self->{AUTHPASS});
    }
    printLog($self->{LOG}, $self->{VBLEVEL}, LOG_INFO1,
             "list organization repositories", 0);

    return $self->_request($uri->as_string(), "get", {}, {});
}

sub org_systems_list
{
    my $self = shift;
    my $uri = URI->new($self->{URL}."/organizations/systems");
    if($self->{AUTHUSER} && $self->{AUTHPASS})
    {
        $uri->userinfo($self->{AUTHUSER}.":".$self->{AUTHPASS});
    }
    printLog($self->{LOG}, $self->{VBLEVEL}, LOG_INFO1,
             "list organization systems", 0);

    return $self->_request($uri->as_string(), "get", {}, {});
}

sub org_systems_show
{
    my $self = shift;
    my $id = shift || return undef;
    my $uri = URI->new($self->{URL}."/organizations/systems/".$id);
    if($self->{AUTHUSER} && $self->{AUTHPASS})
    {
        $uri->userinfo($self->{AUTHUSER}.":".$self->{AUTHPASS});
    }
    printLog($self->{LOG}, $self->{VBLEVEL}, LOG_INFO1,
             "show system with id: $id", 0);

    return $self->_request($uri->as_string(), "get", {}, {});
}

sub org_systems_delete
{
    my $self = shift;
    my $id = shift || return undef;
    my $uri = URI->new($self->{URL}."/organizations/systems/".$id);
    if($self->{AUTHUSER} && $self->{AUTHPASS})
    {
        $uri->userinfo($self->{AUTHUSER}.":".$self->{AUTHPASS});
    }
    printLog($self->{LOG}, $self->{VBLEVEL}, LOG_INFO1,
             "delete syste with id: $id", 0);

    return $self->_request($uri->as_string(), "delete", {}, {});
}


##########################################################################
### private methods
##########################################################################

# _request($url, $method, {headers}, body)
#
# Issue a REST request to <url> using <method>.
#
# <method> should be one of get, head, post or put
#
# With the hash reference <headers> you can add additionly HTTP headers to
# the request.
#
# With the body reference you can define the body to send.
# The body will be JSON encoded before it is send. The body is
# only added if the method is post or put.
#
sub _request
{
    my $self = shift;
    my $url = shift;
    my $method = shift;
    my $headers = shift;
    my $body = shift;

    if ($url !~ /^http/)
    {
        printLog($self->{LOG}, $self->{VBLEVEL}, LOG_ERROR, "Invalid URL: $url");
        return undef;
    }

    $headers = {} if(ref($headers) ne "HASH");
    # generic identification header. Used for debugging in SCC
    $headers->{SMT} = $self->{IDENT};

    my $response = undef;
    if ($method eq "get")
    {
        if(not exists $headers->{'Accept'})
        {
            $headers->{'Accept'} = 'application/json; charset=utf-8';
        }
        $response = $self->{USERAGENT}->get($url, %{$headers});
    }
    elsif ($method eq "head")
    {
        if(not exists $headers->{'Accept'})
        {
            $headers->{'Accept'} = 'application/json; charset=utf-8';
        }
        $response = $self->{USERAGENT}->head($url, %{$headers});
    }
    elsif ($method eq "post")
    {
        if(not exists $headers->{'Content-Type'})
        {
            $headers->{'Content-Type'} = 'application/json; charset=utf-8';
        }
        $response = $self->{USERAGENT}->post($url, %{$headers}, 'content' => JSON::encode_json($body));
    }
    elsif ($method eq "put")
    {
        if(not exists $headers->{'Content-Type'})
        {
            $headers->{'Content-Type'} = 'application/json; charset=utf-8';
        }
        $response = $self->{USERAGENT}->put($url, %{$headers}, 'content' => JSON::encode_json($body));
    }
    elsif ($method eq "delete")
    {
        if(not exists $headers->{'Accept'})
        {
            $headers->{'Accept'} = 'application/json; charset=utf-8';
        }
        $response = $self->{USERAGENT}->delete($url, %{$headers});
    }
    else
    {
        printLog($self->{LOG}, $self->{VBLEVEL}, LOG_ERROR, "Invalid method");
        return undef;
    }
    if($response->is_success)
    {
        printLog($self->{LOG}, $self->{VBLEVEL}, LOG_DEBUG3, Data::Dumper->Dump([$response]));
        if ($response->content_type() eq "application/json")
        {
            return JSON::decode_json($response->content);
        }
        else
        {
            printLog($self->{LOG}, $self->{VBLEVEL}, LOG_ERROR, "Unexpected Content Type");
            return undef;
        }
    }
    printLog($self->{LOG}, $self->{VBLEVEL}, LOG_ERROR, "Connection to registration server failed with: ".$response->status_line);
    return undef;
}

=back

=head1 AUTHOR

mc@suse.de

=head1 COPYRIGHT

Copyright 2014 SUSE LINUX Products GmbH, Nuernberg, Germany.

=cut

1;


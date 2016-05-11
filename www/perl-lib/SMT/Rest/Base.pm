package SMT::Rest::Base;

use strict;
use warnings;

use APR::Brigade ();
use APR::Bucket ();
use APR::Const     -compile => qw(:error SUCCESS BLOCK_READ);
use Apache2::Filter ();

use APR::Brigade;

use Apache2::RequestRec ();
use Apache2::RequestIO ();
use Apache2::Access ();

use Apache2::Const -compile => qw(NOT_FOUND MODE_READBYTES :log);
use Apache2::RequestUtil;

use JSON;

use SMT::Utils;
use SMT::Client;
use DBI qw(:sql_types);
use Data::Dumper;


sub new
{
    my($class, $r) = @_;

    # Set PATH to work in taint mode (bsc#939076)
    $ENV{PATH} = '/sbin:/usr/sbin:/bin:/usr/bin';

    # try to connect to the database - else report server error
    my $dbh = undef;
    my $cfg = undef;
    if ( ! ($dbh=SMT::Utils::db_connect()) )
    {
        $r->log->error("RESTService could not connect to database.");
        return undef;
    }

    eval
    {
        $cfg = SMT::Utils::getSMTConfig();
    };
    if($@ || !defined $cfg)
    {
        $r->log_error("Cannot read the SMT configuration file: ".$@);
        return undef
    }

    my $self = {'_req' => $r,
                '_dbh' => $dbh,
                '_cfg' => $cfg,
                '_usr' => $r->user
    };

    if (SMT::Utils::hasRegSharing($r) && ! $self->{regsharing} ) {
        eval
        {
            require 'SMT/RegistrationSharing.pm';
            #require SMT::RegistrationSharing;
        };
        if ($@)
        {
            my $msg = 'Failed to load registration sharing module '
                . '"SMT/RegistrationSharing.pm"'
                . "\n$@";
            $r->log_error($msg);
        }
        # Plugin successfully loaded
        $self->{regsharing} = 1;
    }

    bless $self, $class;
    return $self;
}

sub request
{
    my $self = shift;
    return $self->{'_req'};
}

sub dbh
{
    my $self = shift;
    return $self->{'_dbh'};
}

sub cfg
{
    my $self = shift;
    return $self->{'_cfg'};
}

sub user
{
    my $self = shift;
    return $self->{'_usr'};
}

#
# get the proper sub-path info part
#  cropps the prefix of the path: "/connect/"
#
sub sub_path($)
{
    my $self = shift || return '';

    # get the path_info
    my $path = $self->request()->path_info();
    # crop the prefix: '/'connect rest service identifier
    $path =~ s/^\/connect\/+//;
    # crop the trailing slash
    $path =~ s/\/?$//;
    # crop the beginning slash
    $path =~ s/^\/?//;

    return $path;
}

sub parse_args($)
{
    my $self = shift || return {};
    my $ret  = {};
    foreach my $kv (split(/&/, $self->request()->args()))
    {
        my ($k, $v) = split(/=/, $kv, 2);
        $ret->{$k} = $v;
    }
    return $ret;
}

#
# read the content of a POST and return the data
#
sub read_post
{
    my $self = shift;
    my $data = SMT::Utils::read_post($self->request());
    $data = '{}' if ! $data;
    return $data;
}

sub respond_with_error
{
    my ($self, $code, $msg) = @_;
    if (! $code)
    {
        $code = Apache2::Const::NOT_FOUND;
        $msg  = "Not Found";
    }
    # errors are logged in each handler
    # returning undef from a handler is allowed, this will result in a 404 response, just as if no handler was defined for the request
    $self->request()->status($code);
    $self->request()->content_type('application/json');
    $self->request()->custom_response($code, "");
    print encode_json({ 'type' => 'error', 'error' => $msg,  'localized_error' => $msg, 'status' => $code });
    $self->request()->log_error("Return error: [$code] $msg");
    return $code;
}

#
# update_last_contact
#
sub update_last_contact($$)
{
    my $self = shift || return undef;

    my $client = SMT::Client->new({ 'dbh' => $self->dbh() });
    return $client->updateLastContact($self->request()->user);
}

sub get_header
{
    my $self    = shift;
    my $key     = shift;
    my $default = shift || undef;

    return $self->request()->headers_in->{$key} || $default;
}

sub get_local_id
{
    my $self = shift;

    my $LocalNUUrl = $self->cfg()->val('LOCAL', 'url');
    $LocalNUUrl =~ s/\s*$//;
    $LocalNUUrl =~ s/\/*$//;
    if(! $LocalNUUrl || $LocalNUUrl !~ /^http/)
    {
        $self->request()->log_error("Invalid url parameter in smt.conf. Please fix the url parameter in the [LOCAL] section.");
        return undef;
    }
    my $localID = "SMT-".$LocalNUUrl;
    $localID =~ s/:*\/+/_/g;
    $localID =~ s/\./_/g;
    $localID =~ s/_$//;

    return $localID;
}

1;


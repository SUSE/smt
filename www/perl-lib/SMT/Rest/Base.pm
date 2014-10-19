package SMT::Rest::Base;

use strict;
use warnings;

use APR::Brigade ();
use APR::Bucket ();
use APR::Const     -compile => qw(:error SUCCESS BLOCK_READ);
use constant IOBUFSIZE => 8192;
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
    bless $self, $class;
    return $self;
}

sub DESTROY {
    my $self = shift;
    $self->dbh()->disconnect();
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

    my $bb = APR::Brigade->new($self->request()->pool, $self->request()->connection->bucket_alloc);

    my $data = '';
    my $seen_eos = 0;
    do {
        $self->request()->input_filters->get_brigade($bb, Apache2::Const::MODE_READBYTES,
                                                     APR::Const::BLOCK_READ, IOBUFSIZE);

        for (my $b = $bb->first; $b; $b = $bb->next($b)) {
            if ($b->is_eos) {
                $seen_eos++;
                last;
            }

            if ($b->read(my $buf)) { $data .= $buf; }
            $b->remove; # optimization to reuse memory
        }
    } while (!$seen_eos);

    $bb->destroy;
    # Fake an empty hash in case we get no data
    $data = '{}' if ! $data;
    $self->request()->log->info("Got content: $data");
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
    print encode_json({ 'error' => $msg,  'localized_error' => $msg, 'status' => $code });
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


1;


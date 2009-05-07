package SMT::Support;

use strict;
use warnings;

use Apache2::Const -compile => qw(OK FORBIDDEN SERVER_ERROR MODE_READBYTES);
use Apache2::RequestRec();

use Apache2::RequestIO ();
use Apache2::RequestUtil;

use constant {
    UPLOAD_DIR => '/var/spool/smt-support/',
    USER_AGENT_REQUIRED => 'SupportConfig',
};

sub new () {
    my $class = 'upload';

    my $self = {
	'error_message' => '',
	'apache_ret' => Apache2::Const::OK,
	'q' => {},
    };

    bless $self;
    return $self;
}

# Parses the HTTP request and fills internal variables
sub ParseQuery ($) {
    my $self = shift;

    my $buffer = '';

    # Can't use CGI for parsing while 'PUT' method is used
    if ($ENV{'REQUEST_METHOD'} eq 'PUT') {
	$buffer = $ENV{'QUERY_STRING'};
    } else {
	$self->{'error_message'} = "method ".$ENV{'REQUEST_METHOD'}." not supported\n";
	$self->{'apache_ret'} = Apache2::Const::OK;
	return 0;
    }

    my ($pair, $name, $value);
    my @params = split (/&/, $buffer);

    # Filling the $q variable with HTTP params
    foreach $pair (@params) {
	($name, $value) = split (/=/, $pair);
	$value =~ tr/+/ /;
	$value =~ s/%([a-fA-F0-9][a-fA-F0-9])/pack("C", hex($1))/eg;

	$self->{'q'}->{$name} = $value;
    }

    return 1;
}

# Checks the HTTP request
sub Check ($) {
    my $self = shift;

    # Checking the user-agent
    my $uagent = $ENV{'HTTP_USER_AGENT'};
    if ($uagent eq "" || $uagent ne USER_AGENT_REQUIRED) {
	$self->{'error_message'} = "user-agent is invalid\n";
	$self->{'apache_ret'} = Apache2::Const::OK;
	return 0;
    }

    return 1;
}

# Saves the uploaded file
sub UploadFile ($) {
    my $self = shift;

    my $filename = $self->{'q'}->{'file'} || do {
	$self->{'error_message'} = "cannot upload file, parameter 'file' not defined\n";
	$self->{'apache_ret'} = Apache2::Const::OK;
	return 0;
    };

    # Removing all but the real file name
    $filename =~ s/.*\/([^\/]*)$/$1/g;
    $filename = UPLOAD_DIR.$filename;

    open (UPLOAD, ">$filename") || do {
	$self->{'error_message'} = "cannot upload file ".$filename.", internal error\n";
	$self->{'apache_ret'} = Apache2::Const::OK;
	warn "cannot upload file ".$filename.": ".$!;
	return 0;
    };

    binmode UPLOAD;
    my $buffer = '';
    while ($buffer = <STDIN>) {
	print UPLOAD $buffer;
    }
    close UPLOAD;

    return 1;
}

sub PrintErrors ($) {
    my $self = shift;

    if ($self->{'error_message'}) {
	print "Status: Failed\nMessage: ".$self->{'error_message'};
    }
}

sub handler :method {
    my $upload = new();

    my $self = shift;
    $upload->{'r'} = shift;
    $upload->{'r'}->content_type('text/plain');

    $upload->ParseQuery() &&
	$upload->Check() &&
	    $upload->UploadFile();

    $upload->PrintErrors();

    return $upload->{'apache_ret'};
}

1;

package SMT::Curl;

use strict;
use SMT::Utils;
use URI;
use URI::QueryParam;
use WWW::Curl::Easy;
use HTTP::Response;
use HTTP::Request;
use English;


use Data::Dumper;

# constructor
sub new
{
    my $pkgname = shift;
    my %opt   = @_;
    my $self  = {};

    $self->{curlobj}   = WWW::Curl::Easy->new();
    $self->{LOG}       = undef;
    $self->{VBLEVEL}   = 0;
    $self->{PROXYUSER} = _getProxySettings();

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

    bless($self);

    $self->setopt(CURLOPT_HEADER, 0);
    $self->setopt(CURLOPT_NOPROGRESS,1);
    $self->setopt(CURLOPT_CONNECTTIMEOUT, $opt{connecttimeout} ) if(exists $opt{connecttimeout});
    if(exists $opt{capath})
    {
        $self->setopt(CURLOPT_CAPATH, $opt{capath} );
    }
    else
    {
        $self->setopt(CURLOPT_CAPATH, '/etc/ssl/certs' );
    }
    $self->setopt(CURLOPT_SSL_VERIFYHOST, 2 );
    $self->setopt(CURLOPT_SSL_VERIFYPEER, 1 );

    if(exists $opt{useragent})
    {
      $self->agent($opt{useragent})
    }
    # setting some defaults
    $self->max_redirect(5);
    $self->connecttimeout(300);

    if($self->{VBLEVEL} & LOG_DEBUG3)
    {
      $self->verbose(1)
    }
    return $self;
}

sub _getProxySettings
{
    my ($httpProxy, $httpsProxy, $noProxy, $proxyUser) = SMT::Utils::getProxySettings();

    # strip trailing /
    $httpsProxy =~ s/\/*$// if(defined $httpsProxy);
    $httpProxy  =~ s/\/*$// if(defined $httpProxy);

    $ENV{http_proxy}  = $httpProxy if(defined $httpProxy  && $httpProxy !~ /^\s*$/);
    $ENV{https_proxy} = $httpsProxy if(defined $httpsProxy && $httpsProxy !~ /^\s*$/);
    $ENV{no_proxy}    = $noProxy if(defined $noProxy    && $noProxy !~ /^\s*$/);

    return $proxyUser;
}


#
# return: 0 == ok, -1 == called without key, >0 == curl error code
#
sub setopt
{
    my $self  = shift;
    my $key   = shift;
    my $value = shift;
    my $curlcode = -1;
    if ( $key )
    {
        $curlcode = $self->{curlobj}->setopt($key, $value);
    }
    return $curlcode;
}

sub verbose
{
    my $self  = shift;
    my $value = shift;

    if ( $value )
    {
        $self->setopt(CURLOPT_DEBUGFUNCTION, sub {
                                my $text = shift;
                                my $unknown = shift;
                                my $type = shift;

                                if($type == 0)
                                {
                                    chomp($text);
                                    printLog($self->{LOG}, $self->{VBLEVEL}, LOG_DEBUG3, "* $text" );
                                }
                                elsif($type == 1 || $type == 2)
                                {
                                    my $pfx = (($type == 1)?"<":">");
                                    chomp($text);
                                    # add \n to not having \r overwriting the same line
                                    printLog($self->{LOG}, $self->{VBLEVEL}, LOG_DEBUG3, "$pfx $text\n" );
                                }
                                return 0;
                            });
        return $self->setopt( CURLOPT_VERBOSE, 1 );
    }
    return $self->setopt( CURLOPT_VERBOSE, 0 );
}

sub agent
{
    my $self  = shift;
    my $value = shift;

    if ( defined $value )
    {
        return $self->setopt( CURLOPT_USERAGENT, "$value" );
    }
    else
    {
        return $self->setopt( CURLOPT_USERAGENT, "" );
    }
}

sub protocols_allowed
{
    my $self  = shift;
    my $value = shift;
    my $pint  = 0;

    if ( ! defined $value )
    {
        $pint |= (~0) ;
    }
    else
    {
        foreach my $p (@$value)
        {
            $pint |= (1 << 0) if ( lc($p) eq "http"  );
            $pint |= (1 << 1) if ( lc($p) eq "https"  );
            $pint |= (1 << 2) if ( lc($p) eq "ftp"  );
            $pint |= (1 << 3) if ( lc($p) eq "ftps"  );
            $pint |= (1 << 4) if ( lc($p) eq "scp"  );
            $pint |= (1 << 5) if ( lc($p) eq "sftp"  );
            $pint |= (1 << 6) if ( lc($p) eq "telnet" );
            $pint |= (1 << 7) if ( lc($p) eq "ldap"  );
            $pint |= (1 << 8) if ( lc($p) eq "ldaps"  );
            $pint |= (1 << 9) if ( lc($p) eq "dict"  );
            $pint |= (1 << 10) if ( lc($p) eq "file"  );
            $pint |= (1 << 11) if ( lc($p) eq "tftp"  );
        }
    }
    return $self->setopt( CURLOPT_PROTOCOLS, int($pint) );
}

sub max_redirect
{
    my $self  = shift;
    my $value = shift;

    if ( $value )
    {
        return $self->setopt( CURLOPT_MAXREDIRS, $value );
    }
    return -1;
}

sub timeout
{
    my $self  = shift;
    my $value = shift;

    if ( $value )
    {
        return $self->setopt( CURLOPT_TIMEOUT, $value );
    }
    return -1;
}

sub connecttimeout
{
    my $self  = shift;
    my $value = shift;

    if ( $value )
    {
        return $self->setopt( CURLOPT_CONNECTTIMEOUT, $value );
    }
    return -1;
}

sub request
{
    my $self     = shift;
    my $request  = shift;
    my %opts     = @_;
    my $curlcode = -1;

    my $uri = $request->uri;

    if($uri->scheme eq "file")
    {
        return $self->request_file($request, %opts);
    }

    $self->setopt(CURLOPT_URL, $uri->as_string);

    if(defined $self->{PROXYUSER} && $self->{PROXYUSER} ne "")
    {
        $self->setopt(CURLOPT_PROXYAUTH, 11); #basic, digest, ntlm
        $self->setopt(CURLOPT_PROXYUSERPWD, $self->{PROXYUSER});
    }

    $self->setopt(CURLOPT_ENCODING, undef);
    if ($request->method eq 'POST')
    {
        $self->setopt(CURLOPT_POST, 1);
        $self->setopt(CURLOPT_POSTFIELDS, $request->content);
        # let libcurl calculate the Content-Length of a post request (bnc#597264)
        $self->setopt(CURLOPT_POSTFIELDSIZE, -1 );
    }
    elsif ($request->method eq 'GET')
    {
        $self->setopt(CURLOPT_HTTPGET, 1);
        $self->setopt(CURLOPT_ENCODING, "gzip");
    }
    elsif ($request->method eq 'HEAD')
    {
        $self->setopt(CURLOPT_NOBODY, 1);
    }
    elsif ($request->method eq 'PUT')
    {
        $self->setopt(CURLOPT_UPLOAD, 1);
        open (my $buf, "<", ${$request->content});
        $self->setopt(CURLOPT_READDATA, $buf);
    }
    elsif ($request->method eq 'DELETE')
    {
        $self->setopt(CURLOPT_CUSTOMREQUEST, "DELETE");
    }

    my @req_headers;
    foreach my $h ($request->headers->header_field_names)
    {
        # Content-Length is calculated by libcurl
        # we do not want to set it as custom headers
        push(@req_headers, "$h: " . $request->header($h)) if("$h" ne "Content-Length");
    }
    if (scalar(@req_headers))
    {
        $self->setopt(CURLOPT_HTTPHEADER, \@req_headers);
    }

    my $buffer1;
    my $header  = "";
    my $content = "";
    if( exists $opts{':content_file'} && defined $opts{':content_file'} &&
        $opts{':content_file'} =~ /^\// )
    {
        open ($buffer1, ">", $opts{':content_file'});
    }
    else
    {
        open ($buffer1, ">", \$content);
    }
    $self->setopt(CURLOPT_WRITEDATA, $buffer1);

    open (my $buffer2, ">", \$header);
    $self->setopt(CURLOPT_WRITEHEADER, $buffer2);

    $curlcode = $self->{curlobj}->perform;

    close $buffer1;
    close $buffer2;

    if ($curlcode == 0)
    {
      my @h = split(/\n/, $header);
      my @new_header = ();
      foreach my $line (@h)
      {
          # $header may contain multiple headers, but we need only the last
          @new_header = () if($line =~ /^HTTP\/1.\d\s\d\d\d\s/);
          push @new_header, $line;
      }
      $header = join("\n", @new_header);

      my $res = HTTP::Response->parse($header . "\r");
      $res->request($request);
      $res->content($content);
      return $res;
    }
    else
    {
      # this error is typically logged in the calling function
      printLog( $self->{LOG}, $self->{VBLEVEL}, LOG_DEBUG3, "$curlcode ".$self->{curlobj}->strerror($curlcode) );
      my $response = HTTP::Response->new(&HTTP::Status::RC_INTERNAL_SERVER_ERROR,
                                         "CURL ERROR($curlcode) ".$self->{curlobj}->strerror($curlcode));
      $response->request($request);
      $response->header("Client-Date" => HTTP::Date::time2str(time));
      $response->header("Client-Warning" => "Internal response");
      $response->header("Content-Type" => "text/plain");
      $response->content("CURL ERROR($curlcode) ".$self->{curlobj}->strerror($curlcode)."\n");
      return $response;
    }
}

sub request_file
{
    my $self     = shift;
    my $request  = shift;
    my %opts     = @_;
    my $file     = undef;

    if( exists $opts{':content_file'} && defined $opts{':content_file'} &&
        $opts{':content_file'} =~ /^\// )
    {
        $file = $opts{':content_file'}
    }
    my $fagent = LWP::UserAgent->new;
    return $fagent->request($request, $file );
}

sub _process_colonic_headers
{
    # Process :content_file  headers.
    my($self, $args, $start_index) = @_;

    my $arg;
    for(my $i = $start_index; $i < @$args; $i += 2) {
        next unless defined $args->[$i];

        if ($args->[$i] eq ':content_file') {
            $arg = $args->[$i + 1];

            # Some sanity-checking...
            Carp::croak("A :content_file value can't be undef")
                unless defined $arg;
            Carp::croak("A :content_file value can't be a reference")
                if ref $arg;
            Carp::croak("A :content_file value can't be \"\"")
                unless length $arg;
        }
        else
        {
            next;
        }
        splice @$args, $i, 2;
        $i -= 2;
    }

    # And return a suitable suffix-list for request(REQ,...)

    return unless defined $arg;
    return (':content_file' => $arg);
}

sub get
{
    require HTTP::Request::Common;
    my ($self, @opt) = @_;
    my @suff = $self->_process_colonic_headers(\@opt,1);
    return $self->request(  HTTP::Request::Common::GET( @opt ), @suff);
}

sub head
{
    require HTTP::Request::Common;
    my ($self, @opt) = @_;
    my @suff = $self->_process_colonic_headers(\@opt,1);
    return $self->request( HTTP::Request::Common::HEAD( @opt ), @suff );
}

sub post
{
    require HTTP::Request::Common;
    my ($self, @opt) = @_;
    my @suff = $self->_process_colonic_headers(\@opt, (ref($opt[1]) ? 2 : 1));
    return $self->request( HTTP::Request::Common::POST( @opt ), @suff );
}

sub put
{
    require HTTP::Request::Common;
    my ($self, @opt) = @_;
    my @suff = $self->_process_colonic_headers(\@opt, (ref($opt[1]) ? 2 : 1));
    return $self->request( HTTP::Request::Common::PUT( @opt ), @suff );
}

sub delete
{
    require HTTP::Request::Common;
    my ($self, @opt) = @_;
    my @suff = $self->_process_colonic_headers(\@opt,1);
    return $self->request( HTTP::Request::Common::DELETE( @opt ), @suff );
}

1;

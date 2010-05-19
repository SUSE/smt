package SMT::Parser::Bulkop;
use strict;
use URI;
use XML::Parser;
use SMT::Utils;
use IO::Zlib;
use Log::Log4perl qw(get_logger :levels);


# The handler is called with something like this
#
# $VAR1 = {
#           'GUID' => 'adbeef4abadb013564',
#           'RESULT' => 'error',
#           'OPERATION' => 'register',
#           'MESSAGE' => 'this is an optional message'
#         };
#
# RESULT can be "success", "warning", "error"
# MESSAGE is available on "error" and "warning"
# OPERATION currently 'register' and 'de-register'
#


# constructor
sub new
{
    my $pkgname = shift;
    my %opt   = @_;
    my $self  = {};

    $self->{CURRENT}   = undef;
    $self->{HANDLER}   = undef;
    $self->{ELEMENT}   = undef;
    $self->{REGCODE}   = "";
    $self->{LOG}       = get_logger();
    $self->{OUT}       = get_logger('userlogger');
    $self->{ERRORS}    = 0;
    
    bless($self);
    return $self;
}

# parses a xml resource
sub parse()
{
    my $self     = shift;
    my $file     = shift;
    my $handler  = shift;
    
    $self->{HANDLER} = $handler;
    
    if (!defined $file)
    {
        $self->{LOG}->error("Invalid filename");
        $self->{OUT}->error(__("Invalid filename"));
        $self->{ERRORS} += 1;
        return $self->{ERRORS};
    }

    # for security reason strip all | characters.
    # XML::Parser ->parsefile( $file ) might be problematic
    $file =~ s/\|//g;
    if (!-e $file)
    {
        printLog($self->{LOG}, $self->vblevel(), LOG_ERROR, );
        $self->{LOG}->error("File '$file' does not exist.");
        $self->{OUT}->error(sprintf(__("File '%s' does not exist."), $file));
        $self->{ERRORS} += 1;
        return $self->{ERRORS};
    }
    
    my $parser = XML::Parser->new( Handlers =>
                                   {
                                    Start=> sub { handle_start_tag($self, @_) },
                                    Char => sub { handle_char_tag($self, @_) },
                                    End=> sub { handle_end_tag($self, @_) },
                                   });

    if ( $file =~ /(.+)\.gz/ )
    {
        my $fh = IO::Zlib->new($file, "rb");
        eval {
            $parser->parse( $fh );
        };
        if ($@) {
            # ignore the errors, but print them
            my $err = $@;
            chomp($err);
            $self->{LOG}->error("SMT::Parser::ListReg Invalid XML in '$file': $err");
            $self->{OUT}->error(sprintf(__("SMT::Parser::ListReg Invalid XML in '%s': %s"), $file, $err));
            $self->{ERRORS} += 1;
        }
        $fh->close;
        undef $fh;
    }
    else
    {
        eval {
            $parser->parsefile( $file );
        };
        if ($@) {
            # ignore the errors, but print them
            my $err = $@;
            chomp($err);
            $self->{LOG}->error("SMT::Parser::ListReg Invalid XML in '$file': $err");
            $self->{OUT}->error(sprintf(__("SMT::Parser::ListReg Invalid XML in '%s': %s"), $file, $err));
            $self->{ERRORS} += 1;
        }
    }
    return $self->{ERRORS};
}

# handles XML reader start tag events
sub handle_start_tag()
{
    my $self = shift;
    my( $expat, $element, %attrs ) = @_;

    if(lc($element) eq "status")
    {
        $self->{ELEMENT} = "STATUS";
        if(exists $attrs{result} && defined $attrs{result})
        {
            $self->{CURRENT}->{RESULT} = $attrs{result};
        }
        if(exists $attrs{operation} && defined $attrs{operation})
        {
            $self->{CURRENT}->{OPERATION} = $attrs{operation};
        }        
    }
    elsif(lc($element) eq "guid")
    {
        $self->{ELEMENT} = "GUID";
        $self->{CURRENT}->{GUID} = "";
    }
    elsif(lc($element) eq "message")
    {
        $self->{ELEMENT} = "MESSAGE";
        $self->{CURRENT}->{MESSAGE} = "";
    }
}

sub handle_char_tag
{
    my $self = shift;
    my( $expat, $string) = @_;

    chomp($string);
    return if($string =~ /^\s*$/);

    if(defined $self->{ELEMENT} && $self->{ELEMENT} eq "GUID")
    {
        $self->{CURRENT}->{GUID} .= $string;
    }
    elsif(defined $self->{ELEMENT} && $self->{ELEMENT} eq "MESSAGE")
    {
        $self->{CURRENT}->{MESSAGE} .= $string;
    }
}

sub handle_end_tag
{
    my( $self, $expat, $element ) = @_;

    if(lc($element) eq "status")
    {
        # first call the callback
        $self->{HANDLER}->($self->{CURRENT});

        $self->{ELEMENT} = undef; 
        $self->{CURRENT} = {};
    }
}

1;



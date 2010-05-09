package SMT::Parser::ListReg;
use strict;
use Log::Log4perl qw(get_logger :levels);
use URI;
use XML::Parser;
use SMT::Utils;
use IO::Zlib;


# The handler is called with something like this
#
# $VAR1 = {
#           'SUBREF' => [
#                         'regcode1',
#                         'regcode2'
#                       ],
#           'GUID' => 'adbeef4abadb013564'
#         };


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
    #     $self->{VBLEVEL}   = 0;
    $self->{ERRORS}    = 0;
    
#     if(exists $opt{log} && defined $opt{log} && $opt{log})
#     {
#         $self->{LOG} = $opt{log};
#     }
#     else
#     {
#         $self->{LOG} = SMT::Utils::openLog();
#     }
# 
#     if(exists $opt{vblevel} && defined $opt{vblevel})
#     {
#         $self->{VBLEVEL} = $opt{vblevel};
#     }

    bless($self);
    return $self;
}

sub vblevel
{
    my $self = shift;
    if (@_) { $self->{VBLEVEL} = shift }
    return $self->{VBLEVEL};
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
        #printLog($self->{LOG}, $self->vblevel(), LOG_ERROR, "Invalid filename");
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
        #printLog($self->{LOG}, $self->vblevel(), LOG_ERROR, "File '$file' does not exist.");
        $self->{LOG}->error("File '$file' does not exist.");
        $self->{OUT}->error(sprintf(__("File '%s' does not exist.", $file)));
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
        if ($@)
        {
          my $e = $@;
          # ignore the errors, but print them
          chomp($e);
          #printLog($self->{LOG}, $self->vblevel(), LOG_ERROR, "SMT::Parser::ListReg Invalid XML in '$file': $@");
          $self->{LOG}->error(sprintf("SMT::Parser::ListReg Invalid XML in '%s': %s",$file, $e));
          $self->{OUT}->error(sprintf(__("SMT::Parser::ListReg Invalid XML in '%s': %s"),$file, $e));
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
        if ($@) 
        {
          my $e = $@;
          # ignore the errors, but print them
          chomp($e);
          #printLog($self->{LOG}, $self->vblevel(), LOG_ERROR, "SMT::Parser::ListReg Invalid XML in '$file': $@");
          $self->{LOG}->error(sprintf("SMT::Parser::ListReg Invalid XML in '%s': %s",$file, $e));
          $self->{OUT}->error(sprintf(__("SMT::Parser::ListReg Invalid XML in '%s': %s"),$file, $e));
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

    if(lc($element) eq "guid")
    {
        $self->{ELEMENT} = "GUID";
        $self->{CURRENT}->{GUID} = "";
    }
    elsif(lc($element) eq "subref")
    {
        $self->{ELEMENT} = "SUBREF";
        if(!exists $self->{CURRENT}->{SUBREF})
        {
            $self->{CURRENT}->{SUBREF} = [];
        }
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
    elsif(defined $self->{ELEMENT} && $self->{ELEMENT} eq "SUBREF")
    {
        $self->{REGCODE} .= $string;
    }
}

sub handle_end_tag
{
    my( $self, $expat, $element ) = @_;

    if(lc($element) eq "client")
    {
        # first call the callback
        $self->{HANDLER}->($self->{CURRENT});

        $self->{ELEMENT} = undef; 
        $self->{REGCODE} = "";
        $self->{CURRENT} = undef;
    }
    elsif(lc($element) eq "subref")
    {
        chomp($self->{REGCODE});
        push @{$self->{CURRENT}->{SUBREF}}, $self->{REGCODE};
        $self->{REGCODE} = "";
    }
}

1;



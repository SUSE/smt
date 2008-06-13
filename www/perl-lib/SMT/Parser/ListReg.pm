package SMT::Parser::ListReg;
use strict;
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
    $self->{LOG}       = undef;

    if(exists $opt{log} && defined $opt{log} && $opt{log})
    {
        $self->{LOG} = $opt{log};
    }
    else
    {
        $self->{LOG} = SMT::Utils::openLog();
    }

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
        printLog($self->{LOG}, "error", "Invalid filename");
        exit 1;
    }

    # for security reason strip all | characters.
    # XML::Parser ->parsefile( $file ) might be problematic
    $file =~ s/\|//g;
    if (!-e $file)
    {
        printLog($self->{LOG}, "error", "File '$file' does not exist.");
        exit 1;
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
            chomp($@);
            printLog($self->{LOG}, "error", "SMT::Parser::ListReg Invalid XML in '$file': $@");
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
            chomp($@);
            printLog($self->{LOG}, "error", "SMT::Parser::ListReg Invalid XML in '$file': $@");
        }
    }
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



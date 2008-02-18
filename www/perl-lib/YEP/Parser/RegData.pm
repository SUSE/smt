package YEP::Parser::RegData;
use strict;
use URI;
use XML::Parser;
use YEP::Utils;
use IO::Zlib;


# constructor
sub new
{
    my $pkgname = shift;
    my %opt   = @_;
    my $self  = {};

    $self->{CURRENT}   = undef;
    $self->{HANDLER}   = undef;
    $self->{LOG}       = undef;

    if(exists $opt{log} && defined $opt{log} && $opt{log})
    {
        $self->{LOG} = $opt{log};
    }
    else
    {
        $self->{LOG} = YEP::Utils::openLog();
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
            printLog($self->{LOG}, "error", "YEP::Parser::RegData Invalid XML in '$file': $@");
        }
    }
    else
    {
        eval {
            $parser->parsefile( $file );
        };
        if ($@) {
            # ignore the errors, but print them
            chomp($@);
            printLog($self->{LOG}, "error", "YEP::Parser::RegData Invalid XML in '$file': $@");
        }
    }
}


# handles XML reader start tag events
sub handle_start_tag()
{
    my $self = shift;
    my( $expat, $element, %attrs ) = @_;


    if(lc($element) eq "col" && defined $attrs{name} && defined $attrs{name} ne "")
    {
#         if($self->{MAINELEMENT} eq "product" && $attrs{name} eq "RELEASE")
#         {
#             $self->{COLNAME} = "REL";
#             $self->{CURRENT}->{REL} = "";
#         }
#         elsif($self->{MAINELEMENT} eq "product" && $attrs{name} eq "RELEASELOWER")
#         {
#             $self->{COLNAME} = "RELLOWER";
#             $self->{CURRENT}->{RELLOWER} = "";
#         }
#         else
#         {
        $self->{COLNAME} = $attrs{name};
        $self->{CURRENT}->{$attrs{name}} = "";
#        }
    }
    elsif(lc($element) eq "row")
    {
        $self->{CURRENT} = {};
        $self->{COLNAME} = "";
    }
    else
    {
        $self->{MAINELEMENT} = $element;
    }
}

sub handle_char_tag
{
    my $self = shift;
    my( $expat, $string) = @_;

    chomp($string);

    return if($string =~ /^\s*$/);

    if(defined $self->{COLNAME} && $self->{COLNAME} ne "")
    {
        if(exists $self->{CURRENT}->{$self->{COLNAME}} && defined $self->{CURRENT}->{$self->{COLNAME}} &&
           $self->{CURRENT}->{$self->{COLNAME}} ne "")
        {
            $self->{CURRENT}->{$self->{COLNAME}} .= $string;
        }
        else
        {
            $self->{CURRENT}->{$self->{COLNAME}} = $string;
        }
    }
}

sub handle_end_tag
{
    my( $self, $expat, $element ) = @_;
    
    if(lc($element) eq "col")
    {
        $self->{COLNAME} = "";
    }
    elsif(lc($element) eq "row")
    {
        $self->{CURRENT}->{MAINELEMENT} = $self->{MAINELEMENT};
        
        # first call the callback
        $self->{HANDLER}->($self->{CURRENT});
    }
    else
    {
        $self->{MAINELEMENT} = "";
    }
}

1;

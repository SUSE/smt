package SMT::Parser::NU;
use strict;
use URI;
use XML::Parser;
use SMT::Utils;
use IO::Zlib;

=head1 NAME

SMT::Parser::NU - parsers NU repoindex.xml file

=head1 SYNOPSIS

  sub handler()
  {
    my $data = shift;
    print $data->{NAME};
    print $data->{DISTRO_TARGET};
    print $data->{PATH};
    print $data->{DESCRIPTION};
    print $data->{PRIORITY};
  }

  $parser = SMT::Parser::NU->new();
  $parser->parse("repoindex.xml", \&handler);

=head1 DESCRIPTION

Parses a repoindex.xml file and calls the handler function
passing every repoindex.xml repo entry to it.

=head1 METHODS

=over 4

=item new()

Create a new SMT::Parser::NU object:

=over 4

=item parse

Starts parsing

=back

=head1 AUTHOR

dmacvicar@suse.de

=head1 COPYRIGHT

Copyright 2007, 2008 SUSE LINUX Products GmbH, Nuernberg, Germany.

=cut

# constructor
sub new
{
    my $pkgname = shift;
    my %opt   = @_;
    my $self  = {};

    $self->{CURRENT}   = undef;
    $self->{HANDLER}   = undef;
    $self->{LOG}    = 0;
    $self->{VBLEVEL}   = 0;
    $self->{ERRORS} = 0;

    if(exists $opt{log} && defined $opt{log} && $opt{log})
    {
        $self->{LOG} = $opt{log};
    }
    else
    {
        $self->{LOG} = SMT::Utils::openLog();
    }

    if(exists $opt{vblevel} && defined $opt{vblevel})
    {
        $self->{VBLEVEL} = $opt{vblevel};
    }

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
    my $path     = shift;
    my $handler  = shift;

    $self->{HANDLER} = $handler;

    # for security reason strip all | characters.
    # XML::Parser ->parsefile( $path ) might be problematic
    $path =~ s/\|//g;
    if (!-e $path)
    {
        printLog($self->{LOG}, $self->vblevel(), LOG_ERROR, "File not found $path");
        $self->{ERRORS} += 1;
        return $self->{ERRORS};
    }

    my $parser;

    $parser = XML::Parser->new( Handlers =>
                                {
                                 Start=> sub { handle_start_tag($self, @_) },
                                 End=> sub { handle_end_tag($self, @_) },
                                });

    if ( $path =~ /(.+)\.gz/ )
    {
        my $fh = IO::Zlib->new($path, "rb");
        eval {
            $parser->parse( $fh );
        };
        if ($@) {
            # ignore the errors, but print them
            chomp($@);
            printLog($self->{LOG}, $self->vblevel(), LOG_ERROR, "SMT::Parser::NU Invalid XML in '$path': $@");
            $self->{ERRORS} += 1;
        }
        $fh->close;
        undef $fh;
    }
    else
    {
        eval {
            $parser->parsefile( $path );
        };
        if ($@) {
            # ignore the errors, but print them
            chomp($@);
            printLog($self->{LOG}, $self->vblevel(), LOG_ERROR, "SMT::Parser::NU Invalid XML in '$path': $@");
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
    # ask the expat object about our position
    my $line = $expat->current_line;

    # we are looking for <repo .../>
    if ( $element eq "repo" )
    {
        my $data = {};
        $data->{NAME} = $attrs{"name"};
        $data->{DISTRO_TARGET} = $attrs{"distro_target"};
        $data->{PATH} = $attrs{"path"};
        $data->{DESCRIPTION} = $attrs{"description"};
        $data->{PRIORITY} = int($attrs{"priority"});
        $self->{CURRENT} = $data;
    }
}


sub handle_end_tag()
{
  my $self = shift;
  my( $expat, $element, %attrs ) = @_;
  if ( $element eq "repo" )
  {
    # call the callback
    $self->{HANDLER}->($self->{CURRENT});
    $self->{CURRENT} = undef;
  }
}

1;

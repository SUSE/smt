package SMT::Parser::RpmMdPrimaryFilter;

use strict;

use XML::Parser;
use IO::Zlib;

use SMT::Utils;

use Data::Dumper;


=head1 NAME

SMT::Parser::RpmMdPrimaryFilter - parses and filters rpm-md primary.xml file

=head1 SYNOPSIS

  $parser = SMT::Parser::RpmMdPrimaryFilter->new(OUT => $filehandle);
  $parser->resource('/path/to/repository/directory/');
  $parser->parse();

=head1 DESCRIPTION

Parses rpm-md repository's primary.xml.gz file and collects information on
unwanted packages (especialy the pkgid). These are then available via
unwanted() method.

Information on the rest of the packages can be made available in the future,
too, if needed.

=head1 METHODS

=over 4

=item new()

Create a new SMT::Parser::RpmMdPrimaryFilter object.

=item parse()

Starts parsing

=item found()

Returns a hash with data of found unwanted packages. Pkgid (rpm package checksum)
as a key and hashes with name, epo, ver, rel, arch keys as values.

Example:

print Dumper(unwanted());
$VAR1 = {
          'f7cb8f0f00d3434f723e4681b5cc6c5bef937463' => {
                                                        'rel' => '60.6.1',
                                                        'epo' => '0',
                                                        'arch' => 'noarch',
                                                        'ver' => '7.3.6',
                                                        'name' => 'logwatch'
                                                      },
          '1e6928c73b0409064f05f5af87af2a79b4f64dc9' => {
                                                        'rel' => '49.12.1',
                                                        'epo' => '0',
                                                        'arch' => 'i586',
                                                        'ver' => '1.3.5',
                                                        'name' => 'audacity'
                                                      }
        };
=back

=head1 AUTHOR

jkupec@suse.cz

=head1 COPYRIGHT

Copyright 2009-2012 SUSE LINUX Products GmbH, Nuernberg, Germany.

=cut

# constructor
sub new
{
    my $pkgname = shift;
    my %opt   = @_;
    my $self  = {};

    $self->{LOG}         = undef;
    $self->{VBLEVEL}     = 0;
    $self->{ERRORS}      = 0;
    $self->{OUT}         = undef;
    $self->{WRITE_OUT}   = 0;

    $self->{RESOURCE}    = undef;
    $self->{LOCATIONHACK}= 0;
    $self->{DEFAULTARCH} = "noarch";
    $self->{CURRENT}     = undef;

    if(exists $opt{log} && defined $opt{log} && $opt{log})
    {
        $self->{LOG} = $opt{log};
    }

    if(exists $opt{vblevel} && defined $opt{vblevel})
    {
        $self->{VBLEVEL} = $opt{vblevel};
    }

    if(exists $opt{out} && defined $opt{out})
    {
        $self->{OUT} = $opt{out};
        $self->{WRITE_OUT} = 1;
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

sub resource
{
    my $self = shift;
    if (@_) { $self->{RESOURCE} = shift }
    return $self->{RESOURCE};
}

sub specialmdlocation
{
    my $self = shift;
    if (@_) { $self->{LOCATIONHACK} = shift }
    return $self->{LOCATIONHACK};
}

sub found()
{
    my $self = shift;
    return $self->{UNWANTED_FOUND};
}

# parses an xml file
sub parse($$)
{
    my ($self, $unwanted) = @_;

    if(!defined $self->{RESOURCE})
    {
        printLog($self->{LOG}, $self->vblevel(), LOG_ERROR, "Invalid resource");
        $self->{ERRORS} += 1;
        return $self->{ERRORS};
    }

    if (not defined $unwanted)
    {
        printLog($self->{LOG}, $self->vblevel(), LOG_ERROR, "Missing parameter 'unwanted'.");
        $self->{ERRORS} += 1;
        return $self->{ERRORS};
    }

    # store in self, so that parser handlers have access to them
    $self->{UNWANTED_GIVEN} = {};
    foreach my $pkg (@$unwanted)
    {
        my $nvra = $pkg->{name} . '-' .
            (defined $pkg->{epo} ? $pkg->{epo} : '0') . ':' .
            $pkg->{ver} . '-' .
            $pkg->{rel} . '.' .
            $pkg->{arch};
        $self->{UNWANTED_GIVEN}->{$nvra} = 1;
    }

    my $path = SMT::Utils::cleanPath($self->{RESOURCE},
        $self->{LOCATIONHACK} ? '.repodata' : 'repodata', 'primary.xml.gz');

    # for security reason strip all | characters.
    # XML::Parser ->parsefile( $path ) might be problematic
    $path =~ s/\|//g;
    if(!-e $path)
    {
        printLog($self->{LOG}, $self->vblevel(), LOG_ERROR, "File not found $path");
        $self->{ERRORS} += 1;
        return $self->{ERRORS};
    }

    my $parser;
    $parser = XML::Parser->new( Handlers => {
                                    Start   => sub { handle_start_tag($self, @_) },
                                    Char    => sub { handle_char_tag ($self, @_) },
                                    End     => sub { handle_end_tag  ($self, @_) },
                                    Default => sub { handle_the_rest ($self, @_) },
                                    Final   => sub { handle_the_end  ($self, @_) }
                                });
    eval
    {
        if ($path =~ /(.+)\.gz/)
        {
            my $fh = IO::Zlib->new($path, "rb");
            $parser->parse($fh);
            $fh->close;
            undef $fh;
        }
        else
        {
            $parser->parsefile($path);
        }
    };
    if($@)
    {
        # ignore the errors, but print them
        chomp($@);
        printLog($self->{LOG}, $self->vblevel(), LOG_ERROR, "SMT::Parser::RpmMdPrimaryFilter: Invalid XML in '$path': $@");
        $self->{ERRORS} += 1;
    }

    $self->{UNWANTED_GIVEN} = {};
    return $self->{ERRORS};
}

# handles XML reader start tag events
sub handle_start_tag
{
    my $self = shift;
    my( $expat, $element, %attrs ) = @_;

    if(! exists $self->{CURRENT}->{MAINELEMENT})
    {
        $self->{CURRENT}->{MAINELEMENT} = undef;
        $self->{CURRENT}->{SUBELEMENT} = undef;
        $self->{CURRENT}->{PKGID} = undef;
        $self->{CURRENT}->{NAME} = undef;
        $self->{CURRENT}->{VERSION} = undef;
        $self->{CURRENT}->{RELEASE} = undef;
        $self->{CURRENT}->{LOCATION} = undef;
        $self->{CURRENT}->{ARCH} = $self->{DEFAULTARCH};
    }

    if (lc($element) eq 'package')
    {
        if( exists $self->{CURRENT}->{MAINELEMENT} &&
            defined $self->{CURRENT}->{MAINELEMENT} &&
            $self->{CURRENT}->{MAINELEMENT})
        {
            my $parentarch = $self->{CURRENT}->{ARCH};
            $self->{CURRENT} = {};
            $self->{CURRENT}->{MAINELEMENT} = undef;
            $self->{CURRENT}->{SUBELEMENT} = undef;
            $self->{CURRENT}->{PKGID} = undef;
            $self->{CURRENT}->{ARCH} = ((defined $parentarch && $parentarch)? $parentarch : $self->{DEFAULTARCH});
        }
        else
        {
            # write out the original XML string read until now (the first
            # <package>), the rest will be writen package by package
            if ($self->{WRITE_OUT})
            {
                print {$self->{OUT}} $self->{CURRENT}->{ORIGXML};
                $self->{CURRENT}->{ORIGXML} = "";
            }
        }

        $self->{CURRENT}->{MAINELEMENT} = lc($element);
    }
    elsif ( defined $self->{CURRENT}->{MAINELEMENT} && $self->{CURRENT}->{MAINELEMENT} )
    {
        if (lc($element) eq 'checksum')
        {
            if(exists $attrs{pkgid} && uc($attrs{pkgid}) eq "YES")
            {
                $self->{CURRENT}->{SUBELEMENT} = lc($element);
            }
        }
        elsif (lc($element) eq 'arch')
        {
            $self->{CURRENT}->{SUBELEMENT} = lc($element);
            $self->{CURRENT}->{ARCH} = "";
        }
        elsif (lc($element) eq 'version')
        {
            $self->{CURRENT}->{SUBELEMENT} = '';
            $self->{CURRENT}->{EPOCH}   = $attrs{epoch} or
                $self->{CURRENT}->{EPOCH} = 0;
            $self->{CURRENT}->{VERSION} = $attrs{ver};
            $self->{CURRENT}->{RELEASE} = $attrs{rel};
        }
        elsif (lc($element) eq 'name')
        {
            $self->{CURRENT}->{SUBELEMENT} = lc($element);
        }
        elsif (lc($element) eq 'location')
        {
            $self->{CURRENT}->{LOCATION} = $attrs{href};
        }
    }

    # store the original XML
    my $line = $expat->original_string;
    if ($self->{WRITE_OUT})
    {
        $self->{CURRENT}->{ORIGXML} .= $line;
    }
}


sub handle_char_tag
{
    my $self = shift;
    my( $expat, $string ) = @_;

     # store the original XML
    my $line = $expat->original_string;
    if ($self->{WRITE_OUT})
    {
        $self->{CURRENT}->{ORIGXML} .= $line;
    }

    if (defined $self->{CURRENT} && defined $self->{CURRENT}->{SUBELEMENT})
    {
        if (lc($self->{CURRENT}->{SUBELEMENT}) eq 'checksum')
        {
            $self->{CURRENT}->{PKGID} .= $string;
        }
        elsif (lc($self->{CURRENT}->{SUBELEMENT}) eq 'arch')
        {
            $self->{CURRENT}->{ARCH} .= $string;
        }
        elsif (lc($self->{CURRENT}->{SUBELEMENT}) eq 'name')
        {
            $self->{CURRENT}->{NAME} .= $string;
        }
    }
}


sub handle_end_tag
{
    my $self = shift;
    my( $expat, $element ) = @_;

    # store the original XML
    my $line = $expat->original_string;
    if ($self->{WRITE_OUT})
    {
        $self->{CURRENT}->{ORIGXML} .= $line;
    }

    if (exists $self->{CURRENT}->{MAINELEMENT} &&
        defined $self->{CURRENT}->{MAINELEMENT} &&
        lc($element) eq $self->{CURRENT}->{MAINELEMENT})
    {
        if ($self->{CURRENT}->{MAINELEMENT} eq 'package')
        {
            my $nvra =
                $self->{CURRENT}->{NAME} . '-' .
                $self->{CURRENT}->{EPOCH} . ':' .
                $self->{CURRENT}->{VERSION} . '-' .
                $self->{CURRENT}->{RELEASE} . '.' .
                $self->{CURRENT}->{ARCH};

            # NOTE: we don't care about .src packages, since we cant't easily
            # know whether there is still some instance (arch) of the package
            # wanted, thus the src package as well.
            # If this is a problem (performance, space), we'll need to find
            # a solution
            if (exists $self->{UNWANTED_GIVEN}->{$nvra} &&
                $self->{CURRENT}->{LOCATION} !~ /delta\.rpm$/) # ignore delta.rpms (just in case)
            {
                my $pkgid = $self->{CURRENT}->{PKGID};
                $self->{UNWANTED_FOUND}->{$pkgid}->{name} = $self->{CURRENT}->{NAME};
                $self->{UNWANTED_FOUND}->{$pkgid}->{epo} = $self->{CURRENT}->{EPOCH};
                $self->{UNWANTED_FOUND}->{$pkgid}->{ver} = $self->{CURRENT}->{VERSION};
                $self->{UNWANTED_FOUND}->{$pkgid}->{rel} = $self->{CURRENT}->{RELEASE};
                $self->{UNWANTED_FOUND}->{$pkgid}->{arch} = $self->{CURRENT}->{ARCH};
                $self->{UNWANTED_FOUND}->{$pkgid}->{loc} = $self->{CURRENT}->{LOCATION};
            }
            # write out the original XML string of current (wanted) package
            elsif ($self->{WRITE_OUT})
            {
                print {$self->{OUT}} $self->{CURRENT}->{ORIGXML};
                print {$self->{OUT}} "\n";
            }

            $self->{CURRENT}->{SUBELEMENT} = undef;
            $self->{CURRENT}->{PKGID} = undef;
            $self->{CURRENT}->{NAME} = undef;
            $self->{CURRENT}->{VERSION} = undef;
            $self->{CURRENT}->{RELEASE} = undef;
            $self->{CURRENT}->{LOCATION} = undef;
            $self->{CURRENT}->{ARCH} = $self->{DEFAULTARCH};
            $self->{CURRENT}->{ORIGXML} = '';
        }
    }
    elsif ( exists $self->{CURRENT}->{SUBELEMENT} && defined $self->{CURRENT}->{SUBELEMENT} &&
            lc($element) eq $self->{CURRENT}->{SUBELEMENT} )
    {
        $self->{CURRENT}->{SUBELEMENT} = undef;
    }
}

# called for all events which do not have their own handlers
sub handle_the_rest
{
    my $self = shift;
    my( $expat, $str ) = @_;

    # store the original XML
    my $line = $expat->original_string;
    if ($self->{WRITE_OUT})
    {
        $self->{CURRENT}->{ORIGXML} .= $line;
    }
}

# called at the end of parsing
sub handle_the_end
{
    my $self = shift;
    my $expat = shift;

    # print the original XML read from last <package> to the end
    my $line = $expat->original_string;
    if ($self->{WRITE_OUT})
    {
        print {$self->{OUT}} $self->{CURRENT}->{ORIGXML} . $line;
        $self->{CURRENT}->{ORIGXML} = ""
    }
}

1;

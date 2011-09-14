package SMT::Parser::RpmMdOtherFilter;

use strict;

use XML::Parser;
use IO::Zlib;

use SMT::Utils;

use Data::Dumper;


=head1 NAME

SMT::Parser::RpmMdPrimary - parses and filters rpm-md primary.xml file

=head1 SYNOPSIS

  $parser = SMT::Parser::RpmMdOtherFilter->new();
  $parser->resource('/path/to/repository/directory/');
  $parser->parse('repodata/filelist.xml', $pkgtoremove, OUT => $filehandle);

=head1 DESCRIPTION

Parses specified rpm-md repository's metadata file and removes metadata of
packages found in given list of pkgids.

=head1 METHODS

=over 4

=item new()

Create a new SMT::Parser::RpmMdPrimary object.

=item parse($file, $pkgtoremove, %options)

Starts parsing.

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

Copyright 2009 SUSE LINUX Products GmbH, Nuernberg, Germany.

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

    $self->{RESOURCE}    = undef;

    $self->{CURRENT}     = {};
    $self->{DROP}        = 0;

    if(exists $opt{log} && defined $opt{log} && $opt{log})
    {
        $self->{LOG} = $opt{log};
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

sub resource
{
    my $self = shift;
    if (@_) { $self->{RESOURCE} = shift }
    return $self->{RESOURCE};
}

sub removed
{
    my $self = shift;
    return $self->{REMOVED};
}

# parses an xml file
sub parse($$$$)
{
    my ($self, $file, $pkgtoremove, %opt) = @_;

    if(!defined $self->{RESOURCE})
    {
        printLog($self->{LOG}, $self->vblevel(), LOG_ERROR, "Invalid resource");
        $self->{ERRORS} += 1;
        return $self->{ERRORS};
    }

    if (not defined $pkgtoremove)
    {
        printLog($self->{LOG}, $self->vblevel(), LOG_ERROR, "Missing parameter 'pkgtoremove'.");
        $self->{ERRORS} += 1;
        return $self->{ERRORS};
    }
    # store in self, so that parser handlers have access to them
    $self->{TOREMOVE} = $pkgtoremove;

    $self->{OUT} = undef;
    $self->{WRITE_OUT} = 0;

    if(exists $opt{out} && defined $opt{out})
    {
        $self->{OUT} = $opt{out};
        $self->{WRITE_OUT} = 1;
    }

    #$self->{CURRENT} = undef;
    $self->{CURRENT}->{MAINELEMENT} = undef;
    $self->{CURRENT}->{PKGID} = undef;
    $self->{REMOVED} = {};

    my $path = SMT::Utils::cleanPath($self->{RESOURCE}, $file);

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
        printLog($self->{LOG}, $self->vblevel(), LOG_ERROR, "SMT::Parser::RpmMdOtherFilter: Invalid XML in '$path': $@");
        $self->{ERRORS} += 1;
    }

    return $self->{ERRORS};
}

# handles XML reader start tag events
sub handle_start_tag
{
    my $self = shift;

    return if($self->{DROP});

    my( $expat, $element, %attrs ) = @_;

    # <package>

    if (lc($element) eq 'package')
    {
        $self->{CURRENT}->{PKGID} = $attrs{pkgid};
        $self->{CURRENT}->{MAINELEMENT} = lc($element);

        if(exists $self->{TOREMOVE}->{$attrs{pkgid}})
        {
            $self->{DROP} = 1;
            printLog($self->{LOG}, $self->vblevel(), LOG_DEBUG, "DROP package name=".$attrs{name}." pkgid=".$attrs{pkgid});
            return;
        }
        else
        {
            $self->{DROP} = 0;
            printLog($self->{LOG}, $self->vblevel(), LOG_DEBUG, "USE package name=".$attrs{name}." pkgid=".$attrs{pkgid});
        }
    }
    # store the original XML
    print {$self->{OUT}} $expat->original_string  if ($self->{WRITE_OUT});
}

sub handle_end_tag
{
    my $self = shift;
    my( $expat, $element ) = @_;

    # store the original XML
    if ($self->{WRITE_OUT} && ! $self->{DROP})
    {
        print {$self->{OUT}} $expat->original_string  if ($self->{WRITE_OUT});
    }

    if (exists $self->{CURRENT}->{MAINELEMENT} &&
        defined $self->{CURRENT}->{MAINELEMENT} &&
        $self->{CURRENT}->{MAINELEMENT} eq lc($element) &&
        $self->{CURRENT}->{MAINELEMENT} eq "package")
    {
        # </package>

        my $pkgid = $self->{CURRENT}->{PKGID};
        if (exists $self->{TOREMOVE}->{$pkgid})
        {
            $self->{REMOVED}->{$pkgid} = $self->{TOREMOVE}->{$pkgid};
            $self->{DROP} = 0;
        }
        $self->{CURRENT}->{PKGID} = undef;
        $self->{CURRENT}->{ORIGXML} = '';
    }
}

# called for all events which do not have their own handlers
sub handle_the_rest
{
    my $self = shift;

    return if($self->{DROP});

    my $expat = shift;

    # store the original XML
    print {$self->{OUT}} $expat->original_string  if ($self->{WRITE_OUT});
}

# called at the end of parsing
sub handle_the_end
{
    my $self = shift;
    my $expat = shift;

    # print the original XML read from last <package> to the end
    if ($self->{WRITE_OUT})
    {
        print {$self->{OUT}} $expat->original_string ;
    }
}

1;

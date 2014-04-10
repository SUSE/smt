package SMT::Parser::RpmMdPatches;
use strict;
use URI;
use XML::Parser;
use SMT::Utils;
use SMT::Parser::RpmMdRepomd;
use IO::Zlib;
use Date::Parse;

=head1 NAME

SMT::Parser::RpmMdPatches - parsers RpmMd repodata files and search for patches

=head1 SYNOPSIS

  $parser = SMT::Parser::RpmMdPatches->new();
  my $patches = $parser->parse("repodata/patches.xml", "repodata/updateinfo.xml.gz");

=head1 DESCRIPTION

Parses metadata and searches for patch descriptions. It can handle both
updateinfo.xml (RPMMD) files and patches.xml with patch-*.xml (SUSE extension
to RPMMD used on openSUSE 10.x and SLE 10).

It returns a hash with patchid ("name-version") as key and subkeys
I<name>, I<version>, I<title>, I<description>, I<type>, I<date>. I<targetrel>,
I<refs>, I<pkgs>

=head1 METHODS

=over 4

=item new()

Creates new SMT::Parser::RpmMdPatches object. Options are passed as keyword
value pairs. Recognized options are:
=over 4

=item log
Logger object created by SMT::Utils::openLog().

=item vblevel
Log verbosity level. See SMT::Utils::LOG* for possible values.

=item filter
Patch filter object (SMT::Filter). If specified, matching patches are discarded
from the result. Additionaly, if output writer is specified, filtered
updateinfo.xml is written to this writer (patches.xml is not written).

=item savefiltered

Remember filtered patches. These will be available via filtered() method after
calling parse().

This option affects only updateinfo.xml.

=item savepackages

This option affects only updateinfo.xml.


=item out
Output writer used to write filtered updateinfo.xml.

=back
=cut
sub new
{
    my $pkgname = shift;
    my %opt   = @_;
    my $self  = {};

    $self->{CURRENT}   = undef;
    $self->{CURRENTSUBPKG}   = undef;
    $self->{RESOURCE}  = undef;
    $self->{LOCATIONHACK} = 0;
    $self->{LOG}    = 0;
    $self->{VBLEVEL}   = 0;

    $self->{PATCHES} = {};
    $self->{FILTER} = undef;
    $self->{SAVE_FILTERED} = 0;
    $self->{FILTERED} = {};
    $self->{SAVE_PACKAGES} = 0;
    $self->{OUT} = undef;

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

    if(exists $opt{filter} && defined $opt{filter})
    {
        $self->{FILTER} = $opt{filter};
    }

    if(exists $opt{out} && defined $opt{out})
    {
        $self->{OUT} = $opt{out};
    }

    if(exists $opt{savefiltered} && defined $opt{savefiltered} && $opt{savefiltered})
    {
        $self->{SAVE_FILTERED} = $opt{savefiltered};
    }

    if(exists $opt{savepackages} && defined $opt{savepackages} && $opt{savepackages})
    {
        $self->{SAVE_PACKAGES} = $opt{savepackages};
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


=item parse()

Starts parsing and returns a hash with all patches found.

=cut

# parses a xml resource
sub parse
{
    my $self     = shift;
    my @repodata = @_;

    my $path     = undef;

    if(!defined $self->{RESOURCE})
    {
        printLog($self->{LOG}, $self->vblevel(), LOG_ERROR, "Invalid resource");
        return {};
    }

    $self->{PACKAGES} = [];
    $self->{PATCHES} = {};
    my $prefix = ($self->specialmdlocation()?".":"");
    my $p = SMT::Parser::RpmMdRepomd->new(log => $self->{LOG},
                                          vblevel => $self->vblevel());
    $p->resource($self->{RESOURCE});
    my $repomd = $p->parse($prefix."repodata/repomd.xml");
    foreach my $start (@repodata)
    {
        if ($start =~ /updateinfo\.xml/ && defined $self->{OUT})
        {
            $self->{WRITE_OUT} = 1;
        }
        else
        {
            $self->{WRITE_OUT} = 0;
        }

        if ($start =~ /updateinfo\.xml/ &&
            $repomd &&
            exists $repomd->{data}->{updateinfo}->{location}->{href} &&
            $repomd->{data}->{updateinfo}->{location}->{href})
        {
            $start = $prefix.$repomd->{data}->{updateinfo}->{location}->{href};
        }
        elsif ($start =~ /patches\.xml/ &&
               $repomd &&
               exists $repomd->{data}->{patches}->{location}->{href} &&
               $repomd->{data}->{patches}->{location}->{href})
        {
            $start = $prefix.$repomd->{data}->{patches}->{location}->{href};
        }
        $path = $self->{RESOURCE}."/$start";

        # for security reason strip all | characters.
        # XML::Parser ->parsefile( $path ) might be problematic
        $path =~ s/\|//g;
        if (!-e $path)
        {
            # we do not count errors here; we want to work also on broken metadata
            printLog($self->{LOG}, $self->vblevel(), LOG_DEBUG, "File not found $path", 0);
            next;
        }

        $self->{STACK} = [];

        printLog($self->{LOG}, $self->vblevel(), LOG_DEBUG, "Found $path. Parsing...", 0);

        # if we need these data sometimes later then we have to find
        # a new solution. But this save us 80% time.
        next if($start =~ /other\.xml[\.gz]*$/);
        next if($start =~ /filelists\.xml[\.gz]*$/);

        my $parser = XML::Parser->new( Handlers =>
                                       {
                                        Start=> sub { handle_start_tag($self, @_) },
                                        Char => sub { handle_char_tag($self, @_) },
                                        End=> sub { handle_end_tag($self, @_) },
                                        Default => sub { handle_the_rest($self, @_) },
                                        Final => sub { handle_the_end($self, @_) }
                                       });

        if ( $path =~ /(.+)\.gz/ )
        {
            my $fh = IO::Zlib->new($path, "rb");
            eval {
                $parser->parse( $fh );
            };
            if ($@) {
                # ignore the errors, we want to work also in broken data
                chomp($@);
                printLog($self->{LOG}, $self->vblevel(), LOG_DEBUG, "SMT::Parser::RpmMdPatches Invalid XML in '$path': $@");
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
                # ignore the errors, we want to work also in broken data
                chomp($@);
                printLog($self->{LOG}, $self->vblevel(), LOG_DEBUG, "SMT::Parser::RpmMdPatches Invalid XML in '$path': $@");
            }
        }
    }
    return $self->{PATCHES};
}

# handles XML reader start tag events
sub handle_start_tag
{
    my $self = shift;
    my( $expat, $element, %attrs ) = @_;
    my $lcelement = lc($element);

    # ask the expat object about our position
    # my $ln = $expat->current_line;

    # store the original XML
    my $line = $expat->original_string;
    if ($self->{WRITE_OUT})
    {
        $self->{CURRENT}->{ORIGXML} .= $line;
    }

    if(! exists $self->{CURRENT}->{MAINELEMENT})
    {
        $self->{CURRENT}->{MAINELEMENT} = '';
        $self->{CURRENT}->{SUBELEMENT} = '';
        $self->{CURRENT}->{LOCATION} = "";
        $self->{CURRENT}->{PATCHID} = "";
        $self->{CURRENT}->{PATCHVER} = "";
        $self->{CURRENT}->{PATCHTYPE} = "";
        $self->{CURRENT}->{PATCHTITLE} = "";
        $self->{CURRENT}->{PATCHDESCR} = "";
        $self->{CURRENT}->{PATCHDATE} = "";
        $self->{CURRENT}->{PATCHTARGET} = "";
        $self->{CURRENT}->{PATCHREFS} = [];
    }

    if ($lcelement eq "updates")
    {
        # write out the original XML string read until now, the rest will be
        # writen patch by patch (<update> element)
        if ($self->{WRITE_OUT})
        {
            print {$self->{OUT}} $self->{CURRENT}->{ORIGXML};
            $self->{CURRENT}->{ORIGXML} = "";
        }
    }
    if ( $lcelement eq "patch" || $lcelement eq "data" )
    {
        $self->{CURRENT}->{MAINELEMENT} = lc($element);
        $self->{CURRENT}->{PATCHDATE} = $attrs{timestamp};
    }
    elsif ( lc($element) eq "update" )
    {
        $self->{CURRENT}->{MAINELEMENT} = lc($element);
        $self->{CURRENT}->{PATCHTYPE} = $attrs{type};
        $self->{CURRENT}->{PATCHVER} = $attrs{version};
        $self->{CURRENT}->{PACKAGES} = [];
    }
    elsif ( lc($element) eq "category" )
    {
        $self->{CURRENT}->{SUBELEMENT} = lc($element);
    }
    elsif ( lc($element) eq "id" && $self->{CURRENT}->{MAINELEMENT} eq "update" )
    {
        $self->{CURRENT}->{SUBELEMENT} = lc($element);
    }
    elsif ( lc($element) eq "issued" && $self->{CURRENT}->{MAINELEMENT} eq "update" )
    {
        # RedHat has date="YYYY-MM-DD HH:MM:SS"
        # SUSE used timestamp since epoch
        if (index($attrs{date}, " ") > 0)
        {
            $self->{CURRENT}->{PATCHDATE} = str2time($attrs{date}, "GMT");
        }
        else
        {
            $self->{CURRENT}->{PATCHDATE} = $attrs{date};
        }
        $self->{CURRENT}->{SUBELEMENT} = lc($element) if (! $attrs{date});
    }
    elsif ( lc($element) eq "title" && $self->{CURRENT}->{MAINELEMENT} eq "update" )
    {
        $self->{CURRENT}->{SUBELEMENT} = lc($element);
    }
    elsif ( lc($element) eq "description" && ($self->{CURRENT}->{MAINELEMENT} eq "update" || $self->{CURRENT}->{MAINELEMENT} eq "patch") )
    {
        $self->{CURRENT}->{SUBELEMENT} = lc($element);
    }
    elsif ( lc($element) eq "release" && $self->{CURRENT}->{MAINELEMENT} eq "update" )
    {
        $self->{CURRENT}->{SUBELEMENT} = lc($element);
    }
    elsif ( lc($element) eq "reference" && $self->{CURRENT}->{MAINELEMENT} eq "update" )
    {
        if(!exists $attrs{'id'} && $attrs{'type'} eq "self")
        {
            # This is a reference to RedHat Errata.
            # We need to find out an ID for it
            if( $attrs{'href'} =~ /errata\/([^.]+).html$/ )
            {
                $attrs{'id'} = $1;
            }
            elsif( $attrs{'href'} =~ /show_bug.cgi\?id=(.+)$/ )
            {
                $attrs{'id'} = $1;
            }
        }
        push @{$self->{CURRENT}->{PATCHREFS}}, \%attrs;
    }
    elsif ( lc($element) eq "yum:name" && $self->{CURRENT}->{MAINELEMENT} eq "patch" )
    {
        $self->{CURRENT}->{SUBELEMENT} = lc($element);
    }
    elsif ( lc($element) eq "yum:version" && $self->{CURRENT}->{MAINELEMENT} eq "patch" )
    {
        $self->{CURRENT}->{PATCHVER} = $attrs{ver};
    }
    elsif ( lc($element) eq "summary" && $self->{CURRENT}->{MAINELEMENT} eq "patch" )
    {
        if( $attrs{lang} eq "en" )
        {
            $self->{CURRENT}->{SUBELEMENT} = lc($element);
        }
    }
    elsif ( lc($element) eq "location" )
    {
        $self->{CURRENT}->{LOCATION} = $attrs{href};
    }
    elsif ($lcelement eq 'package')
    {
        # updateinfo.xml's <package>
        if ($self->{CURRENT}->{MAINELEMENT} eq 'update')
        {
            push @{$self->{STACK}}, $self->{CURRENT}->{MAINELEMENT};
            $self->{CURRENT}->{MAINELEMENT} = 'package';
            $self->{CURRENT}->{SUBELEMENT} = '';
            $self->{CURRENT}->{PKGNAME} = $attrs{name};
            $self->{CURRENT}->{PKGEPO} = $attrs{epoch};
            $self->{CURRENT}->{PKGVER} = $attrs{version};
            $self->{CURRENT}->{PKGREL} = $attrs{release};
            $self->{CURRENT}->{PKGARCH} = $attrs{arch};
        }
        # patch-*.xml's /patch/atom/package
        elsif ($self->{CURRENT}->{MAINELEMENT} eq 'patch')
        {
            push @{$self->{STACK}}, $self->{CURRENT}->{MAINELEMENT};
            $self->{CURRENT}->{MAINELEMENT} = 'package';
            $self->{CURRENT}->{SUBELEMENT} = '';
        }
    }
    elsif ($lcelement eq 'script' || $lcelement eq 'message')
    {
        # code 10 patch-*.xml's /patch/atom/message or /patch/atom/script
        if ($self->{CURRENT}->{MAINELEMENT} eq 'patch')
        {
            push @{$self->{STACK}}, $self->{CURRENT}->{MAINELEMENT};
            $self->{CURRENT}->{MAINELEMENT} = $lcelement;
            $self->{CURRENT}->{SUBELEMENT} = '';
        }
    }
    elsif ($self->{CURRENT}->{MAINELEMENT} eq 'package')
    {
        if ($lcelement eq 'name' || $lcelement eq 'arch')
        {
            $self->{CURRENT}->{SUBELEMENT} = $lcelement;
        }
        elsif ($lcelement eq 'version')
        {
            $self->{CURRENT}->{PKGEPO} = $attrs{epoch};
            $self->{CURRENT}->{PKGVER} = $attrs{ver};
            $self->{CURRENT}->{PKGREL} = $attrs{rel};
        }
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

    if (defined $self->{CURRENT} && defined $self->{CURRENT}->{MAINELEMENT})
    {
        # skip code10 patch <script> and <message> data
        if ($self->{CURRENT}->{MAINELEMENT} eq 'script' ||
            $self->{CURRENT}->{MAINELEMENT} eq 'message')
        {
            return;
        }
    }

    if (defined $self->{CURRENT} && defined $self->{CURRENT}->{SUBELEMENT})
    {
        if ($self->{CURRENT}->{SUBELEMENT} eq "category")
        {
            $self->{CURRENT}->{PATCHTYPE} .= $string;
        }
        elsif ($self->{CURRENT}->{SUBELEMENT} eq "id")
        {
            $self->{CURRENT}->{PATCHID} .= $string;
        }
        elsif ($self->{CURRENT}->{SUBELEMENT} eq "title")
        {
            $self->{CURRENT}->{PATCHTITLE} .= $string;
        }
        elsif ($self->{CURRENT}->{SUBELEMENT} eq "summary")
        {
            $self->{CURRENT}->{PATCHTITLE} .= $string;
        }
        elsif ($self->{CURRENT}->{SUBELEMENT} eq "description")
        {
            $self->{CURRENT}->{PATCHDESCR} .= $string;
        }
        elsif ($self->{CURRENT}->{SUBELEMENT} eq "yum:name")
        {
            $self->{CURRENT}->{PATCHID} .= $string;
        }
        elsif ($self->{CURRENT}->{SUBELEMENT} eq 'release')
        {
            $self->{CURRENT}->{PATCHTARGET} .= $string;
        }
        elsif ($self->{CURRENT}->{SUBELEMENT} eq 'issued')
        {
            $self->{CURRENT}->{PATCHDATE} .= $string;
        }
        elsif ($self->{CURRENT}->{MAINELEMENT} eq 'package')
        {
            if ($self->{CURRENT}->{SUBELEMENT} eq 'name')
            {
                $self->{CURRENT}->{PKGNAME} .= $string;
            }
            elsif ($self->{CURRENT}->{SUBELEMENT} eq 'arch')
            {
                $self->{CURRENT}->{PKGARCH} .= $string;
            }
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

    if (defined $self->{CURRENT}->{MAINELEMENT} &&
           lc($element) eq $self->{CURRENT}->{MAINELEMENT} )
    {
        if ($self->{CURRENT}->{MAINELEMENT} eq 'package')
        {
            my $pkg = {};
            $pkg->{name} = $self->{CURRENT}->{PKGNAME};
            $pkg->{epo}  = $self->{CURRENT}->{PKGEPO};
            $pkg->{ver}  = $self->{CURRENT}->{PKGVER};
            $pkg->{rel}  = $self->{CURRENT}->{PKGREL};
            $pkg->{arch} = $self->{CURRENT}->{PKGARCH};
            push @{$self->{CURRENT}->{PACKAGES}}, $pkg;
            $self->{CURRENT}->{MAINELEMENT} = pop @{$self->{STACK}} if (@{$self->{STACK}});
            $self->{CURRENT}->{PKGNAME} = '';
            $self->{CURRENT}->{PKGEPO} = '';
            $self->{CURRENT}->{PKGVER} = '';
            $self->{CURRENT}->{PKGREL} = '';
            $self->{CURRENT}->{PKGARCH} = '';
        }

        elsif (($self->{CURRENT}->{MAINELEMENT} eq 'update' || $self->{CURRENT}->{MAINELEMENT} eq 'patch') &&
            $self->{CURRENT}->{PATCHID}   ne "" &&
            $self->{CURRENT}->{PATCHTYPE} ne "" &&
            $self->{CURRENT}->{PATCHVER}  ne "")
        {
            my $str = $self->{CURRENT}->{PATCHID}."-".$self->{CURRENT}->{PATCHVER};
            $self->{PATCHES}->{$str}->{name} = $self->{CURRENT}->{PATCHID};
            $self->{PATCHES}->{$str}->{version} = $self->{CURRENT}->{PATCHVER};
            $self->{PATCHES}->{$str}->{type} = $self->{CURRENT}->{PATCHTYPE};
            $self->{PATCHES}->{$str}->{title} = $self->{CURRENT}->{PATCHTITLE};
            $self->{PATCHES}->{$str}->{description} = $self->{CURRENT}->{PATCHDESCR};
            $self->{PATCHES}->{$str}->{date} = $self->{CURRENT}->{PATCHDATE};
            $self->{PATCHES}->{$str}->{targetrel} = $self->{CURRENT}->{PATCHTARGET};
            $self->{PATCHES}->{$str}->{refs} = $self->{CURRENT}->{PATCHREFS};
            $self->{PATCHES}->{$str}->{pkgs} = $self->{CURRENT}->{PACKAGES};

            # remove the patch if it matches current filter
            if (defined $self->{FILTER} && $self->{FILTER}->matches($self->{PATCHES}->{$str}))
            {
                if ($self->{SAVE_FILTERED})
                {
                    $self->{FILTERED}->{$str} = $self->{PATCHES}->{$str};
                }
                if ($self->{SAVE_PACKAGES})
                {
                    push @{$self->{PACKAGES}}, @{$self->{CURRENT}->{PACKAGES}};
                }
                delete($self->{PATCHES}->{$str});
            }
            # write out the original XML string of current patch
            elsif ($self->{WRITE_OUT})
            {
                print {$self->{OUT}} $self->{CURRENT}->{ORIGXML};
            }

            $self->{CURRENT}->{PATCHID}   = "";
            $self->{CURRENT}->{PATCHVER}  = "";
            $self->{CURRENT}->{PATCHTYPE} = "";
            $self->{CURRENT}->{PATCHTITLE} = "";
            $self->{CURRENT}->{PATCHDESCR} = "";
            $self->{CURRENT}->{PATCHDATE} = "";
            $self->{CURRENT}->{PATCHTARGET} = "";
            $self->{CURRENT}->{PATCHREFS} = [];
            $self->{CURRENT}->{ORIGXML} = "";
        }
        elsif ($self->{CURRENT}->{MAINELEMENT} eq 'script' ||
               $self->{CURRENT}->{MAINELEMENT} eq 'message')
        {
            $self->{CURRENT}->{MAINELEMENT} =
               pop @{$self->{STACK}} if (@{$self->{STACK}});
            $self->{CURRENT}->{SUBELEMENT} = '';
        }

        # second check location if we have other metadata files
        # this is basically to retrieve the patches from SUSE's
        # code 10 repodata/patch-*.xml files

        if(exists $self->{CURRENT}->{LOCATION} && defined $self->{CURRENT}->{LOCATION} &&
           $self->{CURRENT}->{LOCATION} =~ /(.+)\.xml(.*)/)
        {
            my $location = $self->{CURRENT}->{LOCATION};
            $self->{CURRENT} = undef;
            if($self->{LOCATIONHACK})
            {
                # rewrite directory
                $location =~ s/repodata/.repodata/;
            }
            # create new parser, since reusing this one would cause
            # concatenating of all the XMLs to the $self->{OUT} output.
            my $parsenew = SMT::Parser::RpmMdPatches->new(
                log => $self->{LOG},
                vblevel => $self->{VBLEVEL});
            $parsenew->resource($self->{RESOURCE});
            $parsenew->specialmdlocation($self->{LOCATIONHACK});
            my $patches = $parsenew->parse($location);
            foreach my $key (keys %{$patches})
            {
                $self->{PATCHES}->{$key} = $patches->{$key};
            }
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

    # print the original XML read from last <patch> to the end
    my $line = $expat->original_string;
    if ($self->{WRITE_OUT})
    {
        print {$self->{OUT}} $self->{CURRENT}->{ORIGXML} . $line;
        $self->{CURRENT}->{ORIGXML} = ""
    }
}

sub filtered()
{
    my $self = shift;
    return $self->{FILTERED};
}

sub filteredpkgs()
{
    my $self = shift;
    return $self->{PACKAGES};
}

=back
=head1 AUTHOR

mc@suse.de, jkupec@suse.cz

=head1 COPYRIGHT

Copyright 2007-2012 SUSE LINUX Products GmbH, Nuernberg, Germany.

=cut

1;

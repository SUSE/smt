package SMT::Parser::RpmMdPatches;
use strict;
use URI;
use XML::Parser;
use SMT::Utils;
use IO::Zlib;

=head1 NAME

SMT::Parser::RpmMdPatches - parsers RpmMd repodata files and search for patches

=head1 SYNOPSIS

  $parser = SMT::Parser::RpmMdPatches->new();
  my $patches = $parser->parse("repodata/patches.xml", "repodata/updateinfo.xml.gz");

=head1 DESCRIPTION

Parses metadata and search for patch descriptions. 
It returns a hash patchid as key and the subkeys
I<title>, I<description> and I<type>

=head1 METHODS

=over 4

=item new()

Create a new SMT::Parser::RpmMdPatches object:

=over 4

=item parse

Starts parsing and returns a hash with all patches found.

=back

=head1 AUTHOR

mc@suse.de

=head1 COPYRIGHT

Copyright 2007, 2008, 2009 SUSE LINUX Products GmbH, Nuernberg, Germany.

=cut

# constructor
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


# parses a xml resource
sub parse
{
    my $self     = shift;
    my @repodata = @_;

    my $path     = undef;
    
    if(!defined $self->{RESOURCE})
    {
        printLog($self->{LOG}, $self->vblevel(), LOG_ERROR, "Invalid resource");
        return $self->{PATCHES};
    }
    
    foreach my $start (@repodata)
    {
        $path = $self->{RESOURCE}."/$start";

        # for security reason strip all | characters.
        # XML::Parser ->parsefile( $path ) might be problematic
        $path =~ s/\|//g;
        if (!-e $path)
        {
            # we do not count errors here; we want to work also on broken metadata
            printLog($self->{LOG}, $self->vblevel(), LOG_DEBUG, "File not found $path");
            next;
        }
    
        # if we need these data sometimes later then we have to find
        # a new solution. But this save us 80% time.
        next if($start =~ /other\.xml[\.gz]*$/);
        next if($start =~ /filelists\.xml[\.gz]*$/);

        my $parser = XML::Parser->new( Handlers =>
                                       {
                                        Start=> sub { handle_start_tag($self, @_) },
                                        Char => sub { handle_char_tag($self, @_) },
                                        End=> sub { handle_end_tag($self, @_) },
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
    # ask the expat object about our position
    #my $line = $expat->current_line;

    if(! exists $self->{CURRENT}->{MAINELEMENT})
    {
        $self->{CURRENT}->{MAINELEMENT} = undef;
        $self->{CURRENT}->{SUBELEMENT} = undef;
        $self->{CURRENT}->{LOCATION} = "";
        $self->{CURRENT}->{PATCHID} = "";
        $self->{CURRENT}->{PATCHVER} = "";
        $self->{CURRENT}->{PATCHTYPE} = "";
        $self->{CURRENT}->{PATCHTITLE} = "";
        $self->{CURRENT}->{PATCHDESCR} = "";
    }
    
    if ( lc($element) eq "patch" || lc($element) eq "data" )
    {
        $self->{CURRENT}->{MAINELEMENT} = lc($element);
    }
    elsif ( lc($element) eq "update" )
    {
        $self->{CURRENT}->{MAINELEMENT} = lc($element);
        $self->{CURRENT}->{PATCHTYPE} = $attrs{type};
        $self->{CURRENT}->{PATCHVER} = $attrs{version};
    }
    elsif ( lc($element) eq "category" )
    {
        $self->{CURRENT}->{SUBELEMENT} = lc($element);
    }
    elsif ( lc($element) eq "id" && $self->{CURRENT}->{MAINELEMENT} eq "update" )
    {
        $self->{CURRENT}->{SUBELEMENT} = lc($element);
    }
    elsif ( lc($element) eq "title" && $self->{CURRENT}->{MAINELEMENT} eq "update" )
    {
        $self->{CURRENT}->{SUBELEMENT} = lc($element);
    }
    elsif ( lc($element) eq "description" && ($self->{CURRENT}->{MAINELEMENT} eq "update" || $self->{CURRENT}->{MAINELEMENT} eq "patch") )
    {
        $self->{CURRENT}->{SUBELEMENT} = lc($element);
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
}

sub handle_char_tag
{
    my $self = shift;
    my( $expat, $string ) = @_;

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
    }
}


sub handle_end_tag
{
    my $self = shift;
    my( $expat, $element ) = @_;

    if (exists $self->{CURRENT}->{MAINELEMENT} && defined $self->{CURRENT}->{MAINELEMENT} &&
           lc($element) eq $self->{CURRENT}->{MAINELEMENT} )
    {
        if( $self->{CURRENT}->{PATCHID} ne "" && $self->{CURRENT}->{PATCHTYPE} ne "" &&
            $self->{CURRENT}->{PATCHVER} ne "")
        {
            my $str = $self->{CURRENT}->{PATCHID}."-".$self->{CURRENT}->{PATCHVER};
            $self->{PATCHES}->{$str}->{type} = $self->{CURRENT}->{PATCHTYPE};
            $self->{PATCHES}->{$str}->{title} = $self->{CURRENT}->{PATCHTITLE};
            $self->{PATCHES}->{$str}->{description} = $self->{CURRENT}->{PATCHDESCR};

            $self->{CURRENT}->{PATCHID}   = "";
            $self->{CURRENT}->{PATCHVER}  = "";
            $self->{CURRENT}->{PATCHTYPE} = "";
            $self->{CURRENT}->{PATCHTITLE} = "";
            $self->{CURRENT}->{PATCHDESCR} = "";
        }

        # second check location if we have other metadata files
        
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
            $self->parse($location);
        }
        
        $self->{CURRENT} = undef;
    }
    elsif ( exists $self->{CURRENT}->{SUBELEMENT} && defined $self->{CURRENT}->{SUBELEMENT} &&
            lc($element) eq $self->{CURRENT}->{SUBELEMENT} )
    {
        $self->{CURRENT}->{SUBELEMENT} = undef;
    }
}

1;

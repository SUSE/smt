package SMT::Parser::RpmMd;
use strict;
use URI;
use XML::Parser;
use SMT::Utils;
use IO::Zlib;

=head1 NAME

SMT::Parser::RpmMd - parsers YUM repodata files

=head1 SYNOPSIS

  sub handler()
  {
    my $data = shift;
    print $data->{NAME};
    print $data->{ARCH};
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
    $self->{CURRENTSUBPKG}   = undef;
    $self->{HANDLER}   = undef;
    $self->{RESOURCE}  = undef;
    $self->{LOCATIONHACK} = 0;
    $self->{LOG}    = 0;
    $self->{VBLEVEL}   = 0;
    $self->{ERRORS}   = 0;

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

sub patches
{
    my $self = shift;
    return $self->{PATCHES};
}

# parses a xml resource
sub parse()
{
    my $self     = shift;
    my $repodata = shift;
    my $handler  = shift;

    my $path     = undef;
    
    $self->{HANDLER} = $handler;
    
    if(!defined $self->{RESOURCE})
    {
        printLog($self->{LOG}, $self->vblevel(), LOG_ERROR, "Invalid resource");
        $self->{ERRORS} += 1;
        return $self->{ERRORS};
    }
    
    $path = $self->{RESOURCE}."/$repodata";

    # for security reason strip all | characters.
    # XML::Parser ->parsefile( $path ) might be problematic
    $path =~ s/\|//g;
    if(!-e $path)
    {
        printLog($self->{LOG}, $self->vblevel(), LOG_ERROR, "File not found $path");
        $self->{ERRORS} += 1;
        return $self->{ERRORS};
    }
    
    # if we need these data sometimes later then we have to find
    # a new solution. But this save us 80% time.
    return $self->{ERRORS} if($repodata =~ /other\.xml[\.gz]*$/);
    return $self->{ERRORS} if($repodata =~ /filelists\.xml[\.gz]*$/);
    

    my $parser;
    
    $parser = XML::Parser->new( Handlers =>
                                { Start=> sub { handle_start_tag($self, @_) },
                                  Char => sub { handle_char_tag($self, @_) },
                                  End=> sub { handle_end_tag($self, @_) },
                                });
    
    if ( $path =~ /(.+)\.gz/ )
    {
      my $fh = IO::Zlib->new($path, "rb");
      eval {
          $parser->parse( $fh );
      };
      if($@) {
          # ignore the errors, but print them
          chomp($@);
          printLog($self->{LOG}, $self->vblevel(), LOG_ERROR, "SMT::Parser::RpmMd Invalid XML in '$path': $@");
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
      if($@) {
          # ignore the errors, but print them
          chomp($@);
          printLog($self->{LOG}, $self->vblevel(), LOG_ERROR, "SMT::Parser::RpmMd Invalid XML in '$path': $@");
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

    if(! exists $self->{CURRENT}->{MAINELEMENT})
    {
        $self->{CURRENT}->{MAINELEMENT} = undef;
        $self->{CURRENT}->{SUBELEMENT} = undef;
        $self->{CURRENT}->{NAME} = undef;
        $self->{CURRENT}->{ARCH} = undef;
        $self->{CURRENT}->{CHECKSUM} = undef;
        $self->{CURRENT}->{LOCATION} = undef;
        $self->{CURRENT}->{PKGFILES} = [];
        $self->{CURRENT}->{PATCHID} = "";
        $self->{CURRENT}->{PATCHVER} = "";
        $self->{CURRENT}->{PATCHTYPE} = "";
        $self->{CURRENT}->{PATCHTITLE} = "";
        $self->{CURRENT}->{PATCHDESCR} = "";
    }
    
    if ( lc($element) eq "location" )
    {
        if(!defined $self->{CURRENTSUBPKG})
        {
            $self->{CURRENT}->{LOCATION} = $attrs{href};
        }
        else
        {
            $self->{CURRENTSUBPKG}->{LOCATION}   = $attrs{href};
        }
    }
    elsif ( lc($element) eq "package" || lc($element) eq "patch" || lc($element) eq "data" )
    {
        $self->{CURRENT}->{MAINELEMENT} = lc($element);
    }
    elsif ( lc($element) eq "update" )
    {
        $self->{CURRENT}->{MAINELEMENT} = lc($element);
        $self->{CURRENT}->{PATCHTYPE} = $attrs{type};
        $self->{CURRENT}->{PATCHVER} = $attrs{version};
    }
    elsif ( lc($element) eq "newpackage" )
    {
        $self->{CURRENT}->{MAINELEMENT} = lc($element);
        $self->{CURRENT}->{NAME} = $attrs{name};
        $self->{CURRENT}->{ARCH} = $attrs{arch};
    }
    elsif ( lc($element) eq "name" )
    {
        $self->{CURRENT}->{SUBELEMENT} = lc($element);
    }
    elsif ( lc($element) eq "arch" )
    {
        $self->{CURRENT}->{SUBELEMENT} = lc($element);
    }
    elsif ( $self->{CURRENT}->{MAINELEMENT} eq "newpackage" && lc($element) eq "filename" )
    {
        $self->{CURRENT}->{SUBELEMENT} = lc($element);
    }
    elsif ( lc($element) eq "checksum" )
    {
        if(exists $attrs{type} && $attrs{type} eq "sha")
        {
            $self->{CURRENT}->{SUBELEMENT} = lc($element);
        }
    }
    elsif ( lc($element) eq "patchrpm" || lc($element) eq "deltarpm" )
    {
        $self->{CURRENTSUBPKG}->{CHECKSUM} = "";
        $self->{CURRENTSUBPKG}->{LOCATION} = "";
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
}

sub handle_char_tag
{
    my $self = shift;
    my( $expat, $string ) = @_;

    if (defined $self->{CURRENT} && defined $self->{CURRENT}->{SUBELEMENT})
    {
        if ($self->{CURRENT}->{SUBELEMENT} eq "name")
        {
            $self->{CURRENT}->{NAME} .= $string;
        }
        elsif ($self->{CURRENT}->{SUBELEMENT} eq "arch")
        {
            $self->{CURRENT}->{ARCH} .= $string;
        }
        elsif ($self->{CURRENT}->{SUBELEMENT} eq "checksum")
        {
            if (!defined $self->{CURRENTSUBPKG})
            {
                $self->{CURRENT}->{CHECKSUM} .= $string;
            }
            else
            {
                $self->{CURRENTSUBPKG}->{CHECKSUM} .= $string;
            }
        }
        elsif ($self->{CURRENT}->{SUBELEMENT} eq "filename")
        {
            $self->{CURRENT}->{LOCATION} .= $string;
        }
        elsif ($self->{CURRENT}->{SUBELEMENT} eq "category")
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


sub handle_end_tag()
{
    my $self = shift;
    my( $expat, $element ) = @_;

    if ( lc($element) eq "patchrpm" || lc($element) eq "deltarpm" )
    {
        push @{$self->{CURRENT}->{PKGFILES}}, $self->{CURRENTSUBPKG};
        $self->{CURRENTSUBPKG} = undef;
    }
    elsif (exists $self->{CURRENT}->{MAINELEMENT} && defined $self->{CURRENT}->{MAINELEMENT} &&
           lc($element) eq $self->{CURRENT}->{MAINELEMENT} )
    {
        # first call the callback
        $self->{HANDLER}->($self->{CURRENT});
        
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
            $self->parse($location, $self->{HANDLER});
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

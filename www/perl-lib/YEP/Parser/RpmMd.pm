package YEP::Parser::RpmMd;
use strict;
use URI;
use XML::Parser;

=head1 NAME

YEP::Parser::RpmMd - parsers YUM repodata files

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

  $parser = YEP::Parser::NU->new();
  $parser->parse("repoindex.xml", \&handler);

=head1 DESCRIPTION

Parses a repoindex.xml file and calls the handler function
passing every repoindex.xml repo entry to it.

=head1 METHODS

=over 4

=item new()

Create a new YEP::Parser::NU object:

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
    my $self  = {};

    $self->{CURRENT}   = undef;
    $self->{CURRENTSUBPKG}   = undef;
    $self->{HANDLER}   = undef;
    $self->{RESOURCE}  = undef;
    bless($self);
    return $self;
}

sub resource
{
    my $self = shift;
    if (@_) { $self->{RESOURCE} = shift }
    return $self->{RESOURCE};
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
        die "Invalid resource";
    }
    
    $path = $self->{RESOURCE}."/$repodata";

    if(!-e $path)
    {
        return;
    }
    
    # if we need these data sometimes later then we have to find
    # a new solution. But this save us 80% time.
    return if($repodata =~ /other\.xml[\.gz]*$/);
    return if($repodata =~ /filelists\.xml[\.gz]*$/);
    

    my $parser;
    
    $parser = XML::Parser->new( Handlers =>
                                { Start=> sub { handle_start_tag($self, @_) },
                                  Char => sub { handle_char_tag($self, @_) },
                                  End=> sub { handle_end_tag($self, @_) },
                                });
    
    if ( $path =~ /(.+)\.gz/ )
    {
      use IO::Zlib;
      my $fh = IO::Zlib->new($path, "rb");
      eval {
          $parser->parse( $fh );
      };
      if($@) {
          # ignore the errors, but print them
          chomp($@);
          print STDERR "Error: $@\n";
      }
    }
    else
    {
      eval {
          $parser->parsefile( $path );
      };
      if($@) {
          # ignore the errors, but print them
          chomp($@);
          print STDERR "Error: $@\n";
      }
    }
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
        $self->{CURRENT}->{CHECKSUM} = undef;
        $self->{CURRENT}->{LOCATION} = undef;
        $self->{CURRENT}->{PKGFILES} = [];
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
    elsif ( lc($element) eq "package" || lc($element) eq "patch" || lc($element) eq "data")
    {
        $self->{CURRENT}->{MAINELEMENT} = lc($element);
    }
    elsif ( lc($element) eq "name" )
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
        
        # second check location if we have other metadata files
        
        if(exists $self->{CURRENT}->{LOCATION} && defined $self->{CURRENT}->{LOCATION} &&
           $self->{CURRENT}->{LOCATION} =~ /(.+)\.xml(.*)/)
        {
            my $location = $self->{CURRENT}->{LOCATION};
            $self->{CURRENT} = undef;
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

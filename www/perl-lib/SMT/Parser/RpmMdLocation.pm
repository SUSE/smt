package SMT::Parser::RpmMdLocation;
use strict;
use URI;
use XML::Parser;
use SMT::Utils;
use IO::Zlib;

use Data::Dumper;


=head1 NAME

SMT::Parser::RpmMdLocation - parsers rpm-md repodata files

=head1 SYNOPSIS

  sub handler()
  {
    my $data = shift;
    print $data->{LOCALTION};
    print $data->{CHECKSUM};
    print $data->{ARCH};
    print $data->{MAINELEMENT};
  }

  $parser = SMT::Parser::RpmMdLocation->new();
  $parser->resource('/path/to/repository/directory/');
  $parser->parse("repodata/repomd.xml", \&handler);

=head1 DESCRIPTION

Parses a metadata of a rpm-md repository calls the handler function
for every location it find.

=head1 METHODS

=over 4

=item new()

Create a new SMT::Parser::RpmMdLocation object:

=over 4

=item parse

Starts parsing

=back

=head1 AUTHOR

dmacvicar@suse.de, mc@suse.de

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
    $self->{STORE}     = [];
    $self->{HANDLER}   = undef;
    $self->{RESOURCE}  = undef;
    $self->{LOCATIONHACK} = 0;
    $self->{LOG}    = 0;
    $self->{VBLEVEL}   = 0;
    $self->{ERRORS}   = 0;
    $self->{DEFAULTARCH} = "noarch";
    
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
    #return $self->{ERRORS} if($repodata =~ /updateinfo\.xml[\.gz]*$/);
    #return $self->{ERRORS} if($repodata =~ /susedata\.xml[\.gz]*$/);
    
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
          printLog($self->{LOG}, $self->vblevel(), LOG_ERROR, "SMT::Parser::RpmMdLocation Invalid XML in '$path': $@");
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
          printLog($self->{LOG}, $self->vblevel(), LOG_ERROR, "SMT::Parser::RpmMdLocation Invalid XML in '$path': $@");
          $self->{ERRORS} += 1;
      }
    }
    return $self->{ERRORS};
}

# handles XML reader start tag events
sub handle_start_tag
{
    my $self = shift;
    my( $expat, $element, %attrs ) = @_;
    # ask the expat object about our position
    my $line = $expat->current_line;

    if(! exists $self->{CURRENT}->{MAINELEMENT})
    {
        $self->{CURRENT}->{MAINELEMENT} = undef;
        $self->{CURRENT}->{SUBELEMENT} = undef;
        $self->{CURRENT}->{CHECKSUM} = undef;
        $self->{CURRENT}->{ARCH} = $self->{DEFAULTARCH};
        $self->{CURRENT}->{LOCATION} = undef;
    }

    if ( lc($element) eq "package" || lc($element) eq "patch" || lc($element) eq "data" || 
         lc($element) eq "delta" || lc($element) eq "patchrpm" || lc($element) eq "deltarpm" )
    {
        if( exists $self->{CURRENT}->{MAINELEMENT} && 
            defined $self->{CURRENT}->{MAINELEMENT} &&
            $self->{CURRENT}->{MAINELEMENT} ne "")
        {
            my $parentarch = $self->{CURRENT}->{ARCH};
            push @{$self->{STORE}}, $self->{CURRENT};
            $self->{CURRENT} = {};
            $self->{CURRENT}->{MAINELEMENT} = undef;
            $self->{CURRENT}->{SUBELEMENT} = undef;
            $self->{CURRENT}->{CHECKSUM} = undef;
            $self->{CURRENT}->{ARCH} = ((defined $parentarch && $parentarch ne "")?"$parentarch":"$self->{DEFAULTARCH}");
            $self->{CURRENT}->{LOCATION} = undef;
        }
        
        $self->{CURRENT}->{MAINELEMENT} = lc($element);
    }
    elsif ( defined $self->{CURRENT}->{MAINELEMENT} && $self->{CURRENT}->{MAINELEMENT} ne "" &&
            lc($element) eq "location" )
    {
        $self->{CURRENT}->{LOCATION} = $attrs{href};
    }
    elsif ( defined $self->{CURRENT}->{MAINELEMENT} && $self->{CURRENT}->{MAINELEMENT} ne "" &&
            lc($element) eq "checksum" )
    {
        if(exists $attrs{type} && $attrs{type} eq "sha")
        {
            $self->{CURRENT}->{SUBELEMENT} = lc($element);
        }
    }
    elsif ( defined $self->{CURRENT}->{MAINELEMENT} && $self->{CURRENT}->{MAINELEMENT} ne "" &&
            lc($element) eq "arch" )
    {
        $self->{CURRENT}->{SUBELEMENT} = lc($element);
	$self->{CURRENT}->{ARCH} = "";
    }
    elsif ( defined $self->{CURRENT}->{MAINELEMENT} && $self->{CURRENT}->{MAINELEMENT} ne "" &&
            lc($element) eq "filename" )
    {
        $self->{CURRENT}->{SUBELEMENT} = lc($element);
    }
    elsif ( lc($element) eq "newpackage" )
    {
        $self->{DEFAULTARCH} = $attrs{arch};
    }
    
}

sub handle_char_tag
{
    my $self = shift;
    my( $expat, $string ) = @_;
    
    if (defined $self->{CURRENT} && defined $self->{CURRENT}->{SUBELEMENT})
    {
        if (lc($self->{CURRENT}->{SUBELEMENT}) eq "checksum")
        {
            $self->{CURRENT}->{CHECKSUM} .= $string;
        }
        elsif (lc($self->{CURRENT}->{SUBELEMENT}) eq "arch")
        {
            $self->{CURRENT}->{ARCH} .= $string;
        }
        elsif (lc($self->{CURRENT}->{MAINELEMENT}) eq "delta" && lc($self->{CURRENT}->{SUBELEMENT}) eq "filename")
        {
            $self->{CURRENT}->{LOCATION} .= $string;
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
        # first: call the callback if LOCATION has a value
        if(exists $self->{CURRENT}->{LOCATION} &&
           defined $self->{CURRENT}->{LOCATION} && 
           $self->{CURRENT}->{LOCATION} ne "")
        {
            $self->{HANDLER}->($self->{CURRENT});
               
            # second: check location if we have other metadata files to parse
        
            if($self->{CURRENT}->{LOCATION} =~ /(.+)\.xml(.*)/)
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
        }
        
        # third: check the STORE and move the last entry to CURRENT
        
        $self->{CURRENT} = pop @{$self->{STORE}};
    }
    elsif ( exists $self->{CURRENT}->{SUBELEMENT} && defined $self->{CURRENT}->{SUBELEMENT} &&
            lc($element) eq $self->{CURRENT}->{SUBELEMENT} )
    {
        $self->{CURRENT}->{SUBELEMENT} = undef;
    }
    elsif ( lc($element) eq "newpackage" )
    {
        $self->{DEFAULTARCH} = "noarch";
    }
}

1;

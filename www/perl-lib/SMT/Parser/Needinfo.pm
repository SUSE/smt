package SMT::Parser::Needinfo;

use strict;
use XML::Parser;
use DBI;
use SMT::Utils;

# constructor
sub new
{
  my $pkgname = shift;
  my %opt   = @_;
  my $self  = {};
  
  $self->{DBH}  = $opt{dbh} || undef;
  $self->{LOG}  = $opt{log} || undef;
  $self->{VBLEVEL} = $opt{vblevel} || 0;
  $self->{PID}  = $opt{pid} || undef;
  
  $self->{ELEMENT} = "";
  $self->{ATTR}    = {};
  $self->{MANDATORY} = 0;
  $self->{descr} = { "guid" => "Machine ID",
                     "secret" => "ZMD secret",
                     "ostarget" => "Target operating system identifier",
                     "ostarget-bak" => "Target operating system identifier",
                     "identification" => "Personal identification",
                     "email" => "E-mail address",
                     "regcode-sles" => "Activation code for SUSE Linux Enterprise Server",
                     "regcode-jeos" => "Activation code for SUSE Linux Enterprise JeOS",
                     "regcode-namaga" => "Activation code for Novell Access Manager",
                     "regcode-nowssbe" => "Activation code for Novell Open Workgroup Suite",
                     "regcode-oes" => "Activation code for Novell Open Enterprise Server",
                     "regcode-res" => "Activation code for RES",
                     "regcode-sled" => "Activation code for SUSE Linux Enterprise Desktop",
                     "regcode-slehae" => "Activation code for SUSE Linux Enterprise High Availability Extension",
                     "regcode-slehas" => "Activation code for SUSE Linux Enterprise HA Server",
                     "regcode-slepos" => "Activation code for SUSE Linux Enterprise Point of Service",
                     "regcode-slert" => "Activation code for SUSE Linux Enterprise Server RT Solution",
                     "regcode-slm" => "Activation code for Sentinal Log Manager",
                     "regcode-slms" => "Activation code for SUSE Lifecycle Management Server",
                     "regcode-studioonsite" => "Activation code for SUSE Studio OnSite",
                     "regcode-vmdp" => "Activation code for SUSE Linux Enterprise Virtual Machine Driver Pack",
                     "regcode-webyast" => "Activation code for WebYaST",
                     "regcode-zenworks" => "Activation code for ZENworks Pulsar",
                     "regcode-zos" => "Activation code for ZENworks Orchestrator",
                     "moniker" => "System name or description",
                     "sysident" => "System identification",
                     "hostname" => "Hostname",
                     "cpu-count" => "CPU count",
                     "installed-langs" => "Installed languages",
                     "hw_inventory" => "Hardware inventory",
                     "cpu" => "CPU details",
                     "disk" => "Disk details",
                     "dsl" => "DSL details",
                     "gfxcard" => "Graphics card details",
                     "isdn" => "ISDN details",
                     "memory" => "Memory",
                     "netcard" => "Network card data",
                     "scsi" => "SCSI device data",
                     "sound" => "Sound card data",
                     "sys" => "System information",
                     "tape" => "Tape storage",
                     "privacy" => "Submit information to help you manage your registered systems.",
                     "host" => "Virtualization Details",
                     "product" => "Installed Products",
                     "processor" => "Processor",
                     "platform" => "Platform",
                     "serial" => "Hardware Serial Number",
                     "serial-lenovo" => "Hardware Serial Number",
                     "serial-dell" => "Hardware Serial Number",
                     "serial-hp" => "Hardware Serial Number",
                     "bios" => "Bios Details",
                     "elogin" => "",
                     "desktops" => "Installed Desktops",
                     "vendor" => "Vendor",
                     #"" => "",
  };

  bless($self);
  return $self;
}

# parses a xml resource
sub parse()
{
  my $self     = shift;
  my $xml      = shift;

  my $statement = sprintf("DELETE from needinfo_params where product_id = %s", $self->{DBH}->quote($self->{PID}));
  printLog($self->{LOG}, $self->{VBLEVEL}, LOG_DEBUG, "STATEMENT: $statement") ;
  $self->{DBH}->do( $statement );
  
  
  my $parser = XML::Parser->new( Handlers => {
                                 Start => sub { handle_start_tag($self, @_) },
                                 End   => sub { handle_end_tag($self, @_) },
  });

  eval
  {
    $parser->parse( $xml );
  };
  if ($@) {
    # ignore the errors, but print them
    chomp($@);
    #printLog($self->{LOG}, $self->vblevel(), LOG_ERROR, "SMT::Parser::ListReg Invalid XML in '$file': $@");
  }
  
  return 1;
}

# handles XML reader start tag events
sub handle_start_tag()
{
  my $self = shift;
  my( $expat, $element, %attrs ) = @_;
  
  if(lc($element) ne "param" && lc($element) ne "needinfo" )
  {
    $self->{ELEMENT} = lc($element);
    $self->{ATTR} = \%attrs;
  }
  elsif(lc($element) eq "param")
  {
    if( (exists $attrs{class} && defined $attrs{class} && $attrs{class} eq "mandatory") ||
        $self->{MANDATORY} )
    {
      $self->{MANDATORY} += 1;
      printLog($self->{LOG}, $self->{VBLEVEL}, LOG_DEBUG, "mandatory + 1 ".$self->{MANDATORY}. " ($element $attrs{id})");
    }
    
    $self->{ELEMENT} = lc($element);
    $self->{ATTR} = \%attrs;
    
    if($self->{MANDATORY})
    {
       $self->{ATTR}->{class} = "mandatory";
    }
    
  }
  
}

sub handle_end_tag
{
  my( $self, $expat, $element ) = @_;
  
  if(lc($element) eq "param")
  {
    if($self->{MANDATORY} > 0)
    {
      $self->{MANDATORY} -= 1;
      printLog($self->{LOG}, $self->{VBLEVEL}, LOG_DEBUG, "mandatory - 1 ".$self->{MANDATORY});
    }
    $self->{ELEMENT} = $self->{ATTR}->{id};
    
  }
  if(lc($element) ne "needinfo" && $self->{ELEMENT} ne "" )
  {
    my $mand = (exists $self->{ATTR}->{class} && $self->{ATTR}->{class} eq "mandatory");
    my $command = ((exists $self->{ATTR}->{command} && defined $self->{ATTR}->{command})?$self->{ATTR}->{command}:"");
    my $descr = $self->description($self->{ATTR}->{description}, $self->{ELEMENT});
    #my $descr = ((exists $self->{ATTR}->{description} && defined $self->{ATTR}->{description})?$self->{ATTR}->{description}:"");

    my $statement = sprintf("INSERT INTO needinfo_params (product_id, param_name, description, command, mandatory) VALUES (%s, %s, %s, %s, %s)",
                            $self->{DBH}->quote( $self->{PID} ),
                            $self->{DBH}->quote( $self->{ELEMENT} ),
                            $self->{DBH}->quote( $descr ),
                            $self->{DBH}->quote( $command ),
                            $self->{DBH}->quote( $mand ));
    printLog($self->{LOG}, $self->{VBLEVEL}, LOG_DEBUG, "STATEMENT: $statement") ;
    $self->{DBH}->do( $statement );
  }
  $self->{ELEMENT} = "";
  $self->{ATTR} = {};
}

sub description
{
  my $self        = shift;
  my $description = shift;
  my $id          = shift;

  return $description if(defined $description && $description ne "");

  return $self->{descr}->{$id} if(exists $self->{descr}->{$id} );
  return "";
}

1;
package Log::Log4perl::Appender::TmpFileBuffer;
our @ISA = qw(Log::Log4perl::Appender);
use File::Temp;

##################################################
sub new {
##################################################
  my $proto  = shift;
  my $class  = ref $proto || $proto;
  my %params = @_;
  my ($fh, $filename) = File::Temp::tempfile("smt-buffer-XXXXXXXX", 
                                           DIR => '/tmp/',
                                           UNLINK => 1,
                                           SUFFIX => ".tmp");
  my $self = {
    name      => "unknown name",
    fh        => $fh,
    filename  => $filename,
    %params,
  };
  
  bless $self, $class;
}

##################################################
sub log {
##################################################
  my $self = shift;
  my %params = @_;
  
  print {$self->{fh}} $params{message};
}

##################################################
sub get_buffer {
##################################################
  my($self) = @_;
  my @buf = ();
  seek($self->{fh}, 0, 0);
  open (BUF, "< ".$self->{filename}) or die "Cannot open $self->{filename}:$!";
  @buf = <BUF>;
  close BUF;
  return join('', @buf);
}

1;

package YEP::ASCIITable;
# by H�kon Nessj�en <lunatic@cpan.org>

@ISA=qw(Exporter);
@EXPORT = qw();
@EXPORT_OK = qw();
$VERSION = '0.12';
use Exporter;
use strict;
use Carp;
use overload '""' => 'drawit';

# Determine if Text::Wrap is installed
my $hasWrap;
if (eval { require Text::Wrap }) { use Text::Wrap; $hasWrap=1; }
else { $hasWrap=0; }

=head1 NAME

Text::ASCIITable - Create a nice formatted table using ASCII characters.

=head1 SHORT DESCRIPTION

Pretty nifty if you want to output dynamic text to your console or other
fixed-size-font displays, and at the same time it will display it in a
nice human-readable, or "cool" way.

=head1 SYNOPSIS

  use Text::ASCIITable;
  $t = new Text::ASCIITable;
  $t->setCols('Nickname','Name');
  $t->addRow('Lunatic-|','H�kon Nessj�en');
  $t->addRow('tesepe','William Viker');
  $t->addRow('espen','Espen Ursin-Holm');
  $t->addRow('mamikk','Martin Mikkelsen');
  $t->addRow('p33r','Espen A. J�tte');
  print $t->draw(); 

=head1 FUNCTIONS

=head2 new(options)

Initialize a new table. You can specify output-options. For more options, check out the usage for setOptions(name,value)

  Usage:
  $t = new Text::ASCIITable;

  Or with options:
  $t = new Text::ASCIITable({ hide_Lastline => 1, reportErrors => 0});

=cut

sub new {
  my $self = {
		tbl_cols => [],
		tbl_rows => [],
		tbl_align => {},

		des_top       => ['.=','=.','-','+'],
		des_middle    => ['|=','=|','-','+'],
		des_bottom    => ["'=","='",'-','+'],
		des_rowline   => ['|=','=|','-','+'],

		des_toprow    => ['|','|','|'],
		des_middlerow => ['|','|','|'],

		options => $_[1] || { }
  };

  $self->{options}{reportErrors} = $self->{options}{reportErrors} || 1; # default setting
  $self->{options}{alignHeadRow} = $self->{options}{alignHeadRow} || 'auto'; # default setting

  bless $self;
  return $self;
}

=head2 setCols(@cols)

Define the columns for the table(compare with <TH> in HTML). For example C<setCols(['Id','Nick','Name'])>.
B<Note> that you cannot add Cols after you have added a row. Multiline columnnames are allowed.

=cut

sub setCols {
  my $self = shift;
  do { $self->reperror("setCols needs an array"); return 1; } unless defined($_[0]);
  @_ = @{$_[0]} if (ref($_[0]) eq 'ARRAY');
  do { $self->reperror("setCols needs an array"); return 1; } unless scalar(@_) != 0;
  do { $self->reperror("Cannot edit cols at this state"); return 1; } unless scalar(@{$self->{tbl_rows}}) == 0;

  my @lines = map { [ split(/\n/,$_) ] } @_;

  # Multiline support
  my $max=0;
  my @out;
  grep {$max = scalar(@{$_}) if scalar(@{$_}) > $max} @lines;
  foreach my $num (0..($max-1)) {
    my @tmp = map { @{$_}[$num] || '' } @lines;
    push @out, [ @tmp ];
  }

  @{$self->{tbl_cols}} = @_;
	@{$self->{tbl_multilinecols}} = @out if ($max);
  $self->{tbl_colsismultiline} = $max;

  return undef;
}

=head2 addRow(@collist)

Adds one row to the table. This must be an array of strings. If you defined 3 columns. This array must
have 3 items in it. And so on. Should be self explanatory. The strings can contain newlines.

  Note: It does not require argument to be an array, thus;
  $t->addRow(['id','name']) and $t->addRow('id','name') does the same thing.

=cut

sub addRow {
  my $self = shift;
  @_ = @{$_[0]} if (ref($_[0]) eq 'ARRAY');
  do { $self->reperror("Received too few columns"); return 1; } if scalar(@_) < scalar(@{$self->{tbl_cols}});
  do { $self->reperror("Received too many columns"); return 1; } if scalar(@_) > scalar(@{$self->{tbl_cols}});
  my (@in,@out,@lines,$max);

  # Word wrapping:
  if ($hasWrap) {
    my @s = @_;
    foreach my $c (0..(scalar(@_)-1)) {
      my $width = $self->{tbl_width}{@{$self->{tbl_cols}}[$c]};
      if ($width) {
        $Text::Wrap::columns = $width;
        $in[$c] = wrap('', '', $_[$c]);
      } else {
        $in[$c] = $_[$c];
      }
    }
  } else { @in = @_; }

  # Multiline support:
  @lines = map { [ split(/\n/,$_) ] } @in;
  $max=0;

  grep {$max = scalar(@{$_}) if scalar(@{$_}) > $max} @lines;
  foreach my $num (0..($max-1)) {
    my @tmp = map { @{$_}[$num] || '' } @lines;
    push @out, [ @tmp ];
  }

  # Add row(s)
  push @{$self->{tbl_rows}}, @out;

  # Rowlinesupport:
  $self->{tbl_rowline}{scalar(@{$self->{tbl_rows}})} = 1;

  return undef;
}

# backwardscompatibility, deprecated
sub alignColRight {
  my ($self,$col) = @_;
  do { $self->reperror("alignColRight is missing parameter(s)"); return 1; } unless defined($col);
  return $self->alignCol($col,'right');
}

=head2 alignCol($col,$direction)

Given a columnname, it aligns all data to the given direction in the table. This looks nice on numerical displays
in a column. The column names in the table will be unaffected by the alignment. Possible directions is: left,
center, right, auto or your own subroutine. (Hint: Using auto(default), aligns numbers right and text left)

=cut

sub alignCol {
  my ($self,$col,$direction) = @_;
  do { $self->reperror("alignCol is missing parameter(s)"); return 1; } unless defined($col) && defined($direction);
  do { $self->reperror("Could not find '$col' in columnlist"); return 1; } unless defined(&find($col,$self->{tbl_cols}));

  $self->{tbl_align}{$col} = $direction;
  return undef;
}

=head2 alignColName($col,$direction)

Given a columnname, it aligns the columnname in the row explaining columnnames, to the given direction. (auto,left,right,center
or a subroutine) (Hint: Overrides the 'alignHeadRow' option for the specified column.)

=cut

sub alignColName {
  my ($self,$col,$direction) = @_;
  do { $self->reperror("alignColName is missing parameter(s)"); return 1; } unless defined($col) && defined($direction);
  do { $self->reperror("Could not find '$col' in columnlist"); return 1; } unless defined(&find($col,$self->{tbl_cols}));

  $self->{tbl_colalign}{$col} = $direction;
  return undef;
}

=head2 setColWidth($col,$width,$strict)

Wordwrapping/strict size. Set a max-width(in chars) for a column.
If last parameter is 1, the column will be set to the specified width, even if no text is that long.

 Usage:
  $t->setColWidth('Description',30);

=cut

sub setColWidth {
  my ($self,$col,$width,$strict) = @_;
  do { $self->reperror("setColWidth is missing parameter(s)"); return 1; } unless defined($col) && defined($width);
  do { $self->reperror("Could not find '$col' in columnlist"); return 1; } unless defined(&find($col,$self->{tbl_cols}));
  do { $self->reperror("Text::Wrap not installed. Please install from CPAN"); return 1; } unless $hasWrap;
  $self->{tbl_width}{$col} = int($width);
  $self->{tbl_width_strict}{$col} = $strict ? 1 : 0;

  return undef;
}

# drawing etc, below

sub getColWidth {
  my ($self,$colname,$ignore) = @_;
  my $pos = &find($colname,$self->{tbl_cols});
  #my $maxsize = $self->count($colname);
  my ($extra_for_all,$extrasome);
  my %extratbl;
  do { $self->reperror("Could not find '$colname' in columnlist"); return 1; } unless defined($pos);

  # Expand width of table if headingtext is wider than the rest
  if (defined($self->{options}{headingText}) && !defined($ignore)) {
    # tablewidth before any cols are expanded
    my $width = $self->getTableWidth('ignore some stuff.. you know..') - 4;
    if (length($self->{options}{headingText}) > $width) {
      my $extra = length($self->{options}{headingText}) - $width;
      my $cols = scalar(@{$self->{tbl_cols}});
      $extra_for_all = int($extra/$cols);
      $extrasome = $extra % $cols; # takk for hjelpa rune :P
      my $antall = 0;
      foreach my $c (0..(scalar(@{$self->{tbl_cols}})-1)) {
        my $col = @{$self->{tbl_cols}}[$c];
        $extratbl{$col} = $extra_for_all;
        if ($antall < $extrasome) {
          $antall++;
          $extratbl{$col}++;
        }
      }
    }
  }

  # multiline support in columnnames
  my $maxsize=0;
  grep { $maxsize = length($_) if length($_) > $maxsize } split(/\n/,$colname);

  if ($self->{tbl_width_strict}{$colname} == 1 && int($self->{tbl_width}{$colname}) > 0) {
    # maxsize plus the spaces on each side
    return $self->{tbl_width}{$colname} + 2 + (defined($extratbl{$colname}) ? $extratbl{$colname} : 0);
  } else {
    for my $row (@{$self->{tbl_rows}}) {
      $maxsize = $self->count(@{$row}[$pos]) if ($self->count(@{$row}[$pos]) > $maxsize);
    }
  }

  # maxsize pluss the spaces on each side + extra width from title
  return $maxsize + 2 + (defined($extratbl{$colname}) ? $extratbl{$colname} : 0);
}

=head2 getTableWidth()

If you need to know how wide your table will be before you draw it. Use this function.

=cut

sub getTableWidth {
  my $self = shift;
  my $ignore = shift;
  my $totalsize = 1;
  grep {$totalsize += $self->getColWidth($_,(defined($ignore) ? 'ignoreheading' : undef)) + 1} @{$self->{tbl_cols}};
  return $totalsize;
}

sub drawLine {
  my ($self,$start,$stop,$line,$delim) = @_;
  do { $self->reperror("Missing reqired parameters"); return 1; } unless defined($stop);
  $line = defined($line) ? $line : '-'; 
  $delim = defined($delim) ? $delim : '+'; 

  my $contents;

  $contents = $start;

  for (my $i=0;$i < scalar(@{$self->{tbl_cols}});$i++) {
    my $offset = 0;
    $offset = length($start) - 1 if ($i == 0);
    $offset = length($stop) - 1 if ($i == scalar(@{$self->{tbl_cols}}) -1);

    $contents .= $line x ($self->getColWidth(@{$self->{tbl_cols}}[$i]) - $offset);

    $contents .= $delim if ($i != scalar(@{$self->{tbl_cols}}) - 1);
  }
  return $contents.$stop."\n";
}

=head2 setOptions(name,value)

Use this to set options like: hide_FirstLine,reportErrors, etc.

  $t->setOptions('hide_HeadLine',1);

B<Possible Options>

=over 4

=item hide_HeadRow

Hides output of the columnlisting. Together with hide_HeadLine, this makes a table only show the rows. (However, even though
the column-names will not be shown, they will affect the output if they have for example ridiculoustly long
names, and the rows contains small amount of info. You would end up with a lot of whitespace)

=item reportErrors

Set to 0 to disable error reporting. Though if a function encounters an error, it will still return the value 1, to
tell you that things didn't go exactly as they should.

=item allowHTML

If you are going to use Text::ASCIITable to be shown on HTML pages, you should set this option to 1 when you are going
to use HTML tags to for example color the text inside the rows, and you want the browser to handle the table correct.

=item allowANSI

If you use ANSI codes like <ESC>[1mHi this is bold<ESC>[m or similar. This option will make the table to be
displayed correct when showed in a ANSI compilant terminal. Set this to 1 to enable.

=item alignHeadRow

Set wich direction the Column-names(in the headrow) are supposed to point. Must be left, right, center, auto or a user-defined subroutine.

=item hide_FirstLine, hide_HeadLine, hide_LastLine

Speaks for it self?

=item drawRowLine

Set this to 1 to print a line between each row. You can also define the outputstyle
of this line in the draw() function.

=item headingText

Add a heading above the columnnames/rows wich uses the whole width of the table to output
a heading/title to the table. The heading-part of the table is automaticly shown when
the headingText option contains text. B<Note:> If this text is so long that it makes the
table wider, it will not hesitate to change width of columns that have "strict width".

=item headingAlign

Align the heading(as mentioned above) to left, right, center, auto or using a subroutine.

=item headingStartChar, headingStopChar

Choose the startingchar and endingchar of the row where the title is. The default is
'|' on both. If you didn't understand this, try reading about the draw() function.

=back

=cut

sub setOptions {
  my ($self,$name,$value) = @_;
  my $old = $self->{options}{$name} || undef;
  $self->{options}{$name} = $value;
  return $old;
}

sub drawSingleColumnRow {
  my ($self,$text,$start,$stop,$align,$opt) = @_;
  do { $self->reperror("Missing reqired parameters"); return 1; } unless defined($text);

  my $contents = $start;
  my $width = 0;
  # ok this is a bad shortcut, but 'till i get up with a better one, I use this.
  if (($self->getTableWidth() - 4) < length($text) && $opt eq 'title') {
    $width = length($text);
  }
  else {
    $width = $self->getTableWidth() - 4;
  }
  $contents .= ' '.$self->align(
                       $text,
                       $align || 'left',
                       $width,
                       ($self->{options}{allowHTML} || $self->{options}{allowANSI}?0:1)
                   ).' ';
  return $contents.$stop."\n";
}
sub drawRow {
  my ($self,$row,$isheader,$start,$stop,$delim) = @_;
  do { $self->reperror("Missing reqired parameters"); return 1; } unless defined($row);
  $isheader = $isheader || 0;
  $delim = $delim || '|';

  my $contents = $start;
  for (my $i=0;$i<scalar(@{$row});$i++) {
    my $text = @{$row}[$i];

    if ($isheader != 1 && defined($self->{tbl_align}{@{$self->{tbl_cols}}[$i]})) {
      $contents .= ' '.$self->align(
                         $text,
                         $self->{tbl_align}{@{$self->{tbl_cols}}[$i]} || 'left',
                         $self->getColWidth(@{$self->{tbl_cols}}[$i])-2,
                         ($self->{options}{allowHTML} || $self->{options}{allowANSI}?0:1)
                       ).' ';
    } elsif ($isheader == 1) {

      $contents .= ' '.$self->align(
                         $text,
                         $self->{tbl_colalign}{@{$self->{tbl_cols}}[$i]} || $self->{options}{alignHeadRow} || 'left',
                         $self->getColWidth(@{$self->{tbl_cols}}[$i])-2,
                         ($self->{options}{allowHTML} || $self->{options}{allowANSI}?0:1)
                       ).' ';
    } else {
      $contents .= ' '.$self->align(
                         $text,
                         'left',
                         $self->getColWidth(@{$self->{tbl_cols}}[$i])-2,
                         ($self->{options}{allowHTML} || $self->{options}{allowANSI}?0:1)
                       ).' ';
    }
    $contents .= $delim if ($i != scalar(@{$row}) - 1);
  }
  return $contents.$stop."\n";
}

=head2 draw([@topdesign,@toprow,@middle,@middlerow,@bottom,@rowline])

All the arrays containing the layout is optional. If you want to make your own "design" to the table, you
can do that by giving this method these arrays containing information about which characters to use
where.

B<Custom tables>

The draw method takes C<6> arrays of strings to define the layout. The first, third, fifth and sixth is B<LINE>
layout and the second and fourth is B<ROW> layout. The C<fourth> parameter is repeated for each row in the table.
The sixth parameter is only used if drawRowLine is enabled.

 $t->draw(<LINE>,<ROW>,<LINE>,<ROW>,<LINE>,[<ROWLINE>])

=over 4

=item LINE

Takes an array of C<4> strings. For example C<['|','|','-','+']>

=over 4

=item *

LEFT - Defines the left chars. May be more than one char.

=item *

RIGHT - Defines the right chars. May be more then one char.

=item *

LINE - Defines the char used for the line. B<Must be only one char>.

=item *

DELIMETER - Defines the char used for the delimeters. B<Must be only one char>.

=back

=item ROW

Takes an array of C<3> strings. You should not give more than one char to any of these parameters,
if you do.. it will probably destroy the output.. Unless you do it with the knowledge
of how it will end up. An example: C<['|','|','+']>

=over 4

=item *

LEFT - Define the char used for the left side of the table.

=item *

RIGHT - Define the char used for the right side of the table.

=item *

DELIMETER - Defines the char used for the delimeters.

=back

=back

Examples:

The easiest way:

 $t->draw();

Explanatory example:

 $t->draw( ['L','R','l','D'],  # LllllllDllllllR
           ['L','R','D'],      # L info D info R
           ['L','R','l','D'],  # LllllllDllllllR
           ['L','R','D'],      # L info D info R
           ['L','R','l','D']   # LllllllDllllllR
          );

Nice example:

 $t->draw( ['.','.','-','-'],   # .-------------.
           ['|','|','|'],       # | info | info |
           ['|','|','-','-'],   # |-------------|
           ['|','|','|'],       # | info | info |
           [' \\','/ ','_','|'] #  \_____|_____/
          );

Nice example2:

 $t->draw( ['.=','=.','-','-'],   # .=-----------=.
           ['|','|','|'],         # | info | info |
           ['|=','=|','-','+'],   # |=-----+-----=|
           ['|','|','|'],         # | info | info |
           ["'=","='",'-','-']    # '=-----------='
          );

With Options:

 $t->setOptions('drawRowLine',1);
 $t->draw( ['.=','=.','-','-'],   # .=-----------=.
           ['|','|','|'],         # | info | info |
           ['|-','-|','=','='],   # |-===========-|
           ['|','|','|'],         # | info | info |
           ["'=","='",'-','-'],   # '=-----------='
           ['|=','=|','-','+']    # rowseperator
          );
 Which makes this output:
   .=-----------=.
   | info | info |
   |-===========-|
   | info | info |
   |=-----+-----=| <-- between each row
   | info | info |
   '=-----------='

B<User-defined subroutines for aligning>

If you want to format your text more throughoutly than "auto", or think you
have a better way of centering text; you can make your own subroutine.

  Here's a exampleroutine that aligns the text to the right.
  
  sub myownalign_cb {
    my ($text,$length,$count,$strict) = @_;
    $text = (" " x ($length - $count)).$text;
    return substr($text,0,$length) if ($strict);
    return $text;
  }

  $t->alignCol('Info',\myownalign_cb);

=cut

sub drawit {scalar shift()->draw()}

sub draw {
  my $self = shift;
  my ($top,$toprow,$middle,$middlerow,$bottom,$rowline) = @_;
  my ($tstart,$tstop,$tline,$tdelim) = defined($top) ? @{$top} : @{$self->{des_top}};
  my ($trstart,$trstop,$trdelim) = defined($toprow) ? @{$toprow} : @{$self->{des_toprow}};
  my ($mstart,$mstop,$mline,$mdelim) = defined($middle) ? @{$middle} : @{$self->{des_middle}};
  my ($mrstart,$mrstop,$mrdelim) = defined($middlerow) ? @{$middlerow} : @{$self->{des_middlerow}};
  my ($bstart,$bstop,$bline,$bdelim) = defined($bottom) ? @{$bottom} : @{$self->{des_bottom}};
  my ($rstart,$rstop,$rline,$rdelim) = defined($rowline) ? @{$rowline} : @{$self->{des_rowline}};
  my $contents="";

  $contents .= $self->drawLine($tstart,$tstop,$tline,$tline) unless $self->{options}{hide_FirstLine};
  if (defined($self->{options}{headingText})) {
    $contents .= $self->drawSingleColumnRow($self->{options}{headingText},$self->{options}{headingStartChar} || '|',$self->{options}{headingStopChar} || '|',$self->{options}{headingAlign} || 'center','title');
    $contents .= $self->drawLine($mstart,$mstop,$mline,$mdelim) unless $self->{options}{hide_HeadLine};
  }
  unless ($self->{options}{hide_HeadRow}) {
		# multiline-column-support
		foreach my $row (@{$self->{tbl_multilinecols}}) {
			$contents .= $self->drawRow($row,1,$trstart,$trstop,$trdelim);
		}
	}
  $contents .= $self->drawLine($mstart,$mstop,$mline,$mdelim) unless $self->{options}{hide_HeadLine};
  my $i=0;
  for (@{$self->{tbl_rows}}) {
    $i++;
    $contents .= $self->drawRow($_,0,$mrstart,$mrstop,$mrdelim);
    $contents .= $self->drawLine($rstart,$rstop,$rline,$rdelim) if ($self->{options}{drawRowLine} && $self->{tbl_rowline}{$i} && ($i != scalar(@{$self->{tbl_rows}})));
  }
  $contents .= $self->drawLine($bstart,$bstop,$bline,$bdelim) unless $self->{options}{hide_LastLine};

  return $contents;
}

# nifty subs

# Replaces length() because of optional HTML and ANSI stripping
sub count {
  my ($self,$str) = @_;
  $str =~ s/<.+?>//g if $self->{options}{allowHTML};
  $str =~ s/\33\[(\d+(;\d+)?)?[musfwhojBCDHRJK]//g if $self->{options}{allowANSI}; # maybe i should only have allowed ESC[#;#m and not things not related to
  return length($str);                                                             # color/bold/underline.. But I want to give people as much room as they need.
}

sub align {

  my ($self,$text,$dir,$length,$strict) = @_;

  if ($dir =~ /auto/i) {
    if ($text =~ /^-?\d+(\.\d+)*$/) {
      $dir = 'right';
    } else {
      $dir = 'left';
    }
  }
  if (ref($dir) eq 'CODE') {
    my $ret = eval { return &{$dir}($text,$length,$self->count($text),$strict); };
    return 'CB-ERR' if ($@);
    return 'CB-LEN-ERR' if ($self->count($ret) != $length);
    return $ret;
  } elsif ($dir =~ /right/i) {
    $text = (" " x ($length - $self->count($text))).$text;
    return substr($text,0,$length) if ($strict);
    return $text;
  } elsif ($dir =~ /left/i) {
    $text = $text.(" " x ($length - $self->count($text)));
    return substr($text,0,$length) if ($strict);
    return $text;
  } elsif ($dir =~ /center/i) {
    my $left = ( $length - $self->count($text) ) / 2;
    # Someone tell me if this is matematecally totally wrong. :P
    $left = int($left) + 1 if ($left != int($left) && $left > 0.4);
    my $right = int(( $length - $self->count($text) ) / 2);
    $text = (" " x $left).$text.(" " x $right);
    return substr($text,0,$length) if ($strict);
    return $text;
  }
}

sub reperror {
  my $self = shift;
  print STDERR Carp::shortmess(shift) if $self->{options}{reportErrors};
}

# Best way I could think of, to search the array.. Please tell me if you got a better way.
sub find {
  return undef unless defined $_[1];
  grep {return $_ if @{$_[1]}[$_] eq $_[0];} (0..scalar(@{$_[1]}));
  return undef;
}


1;

__END__

=head1 FEATURES

In case you need to know if this module has what you need, I have made this list
of features included in Text::ASCIITable.

=over 4

=item Configurable layout

You can easily alter how the table should look, in many ways. There are a few examples
in the draw() section of this documentation. And you can remove parts of the layout
or even add a heading-part to the table.

=item Text Aligning

Align the text in a column auto(matically), left, right or center. Usually you want to align text
to right if you only have numbers in that row. The 'auto' direction aligns text to left, and numbers
to the right. You can also use your own subroutine as a callback-function to align your text.
 
=item Multiline support in rows

With the \n(ewline) character you can have rows use more than just one line on
the output. (This looks nice with the drawRowLine option enabled)

=item Optional wordwrap support (using Text::Wrap)

If you have installed Text::Wrap, you will have the possibility to use have rows
not be wider than a set amount of characters. If a line exceedes for example 30
characters, the line will be broken up in several lines.

=item HTML support

If you put in <HTML> tags inside the rows, the output would usually be broken when
viewed in a browser, since the browser "execute" the tags instead of displaying it.
But if you enable allowHTML. You are able to write html tags inside the rows without the
output being broken if you display it in a browser. But you should not mix this with
wordwrap, since this could make undesirable results.

=item ANSI support

Allows you to decorate your tables with colors or bold/underline when you display
your tables to a terminal window.

=item Errorreporting

If you write a script in perl, and don't want users to be notified of the errormessages
from Text::ASCIITable. You can easily turn of error reporting by setting reportErrors to 0.
You will still get an 1 instead of undef returned from the function.

=back

=head1 REQUIRES

Exporter, Carp, Text::Wrap

=head1 AUTHOR

H�kon Nessj�en, lunatic@cpan.org

=head1 VERSION

Current version is 0.12.

=head1 COPYRIGHT

Copyright 2002-2003 by H�kon Nessj�en.
All rights reserved.
This module is free software;
you can redistribute it and/or modify it under the same terms as Perl itself.

=head1 SEE ALSO

Text::FormatTable, Text::Table

=cut

###############################################################################
# This is a wrapper for Alfred Reibenschuh's PDF::API2
# Defines methods to create PDF reports
# By: Andy Orr
# Date: 08/02/2002
# Version: 1.00
###############################################################################

package PDF::Report;

$VERSION = "1.00"; 

=head1 PDF::Report 

=head1 NAME

PDF::Report - A wrapper written for PDF::API2

=head1 SYNOPSIS
	
	use PDF::Report;

        my $pdf = new PDF::Report(%opts);

=cut

use strict;
use PDF::API2;

### SUBS TO DO LIST ###
# getDefault
# setDefault
# setAlign
# getAlign
# centerString
# getStringWidth
#######################

### GLOBAL SECTION ############################################################
# Sane defaults
my %DEFAULTS;
$DEFAULTS{PageSize}='letter';
$DEFAULTS{PageOrientation}='Portrait';
$DEFAULTS{Compression}=1;
$DEFAULTS{PdfVersion}=3;
$DEFAULTS{marginX}=30;
$DEFAULTS{marginY}=30;
$DEFAULTS{font}="Helvetica";
$DEFAULTS{size}=12;

my ( $day, $month, $year )= ( localtime( time ) )[3..5];
my $DATE=sprintf "%02d/%02d/%04d", ++$month, $day, 1900 + $year;

# Document info
my %INFO = 
          (
            Creator => "None",
            Producer => "None",
            CreationDate => $DATE,
            Title => "Untitled",
            Subject => "None",
            Author => "Auto-generated",
          );

my @parameterlist=qw(
        PageSize
        PageWidth
        PageHeight
        PageOrientation
        Compression
        PdfVersion
);
### END GLOBALS ###############################################################

### GLOBAL SUBS ############################################################### 

=head1 METHODS

=item my $pdf = new PDF::Report(%opts);

Creates a new pdf report object.  If no %opts are specified 
the module will use the factory defaults.

B<Example:>

	my $pdf = new PDF::Report(PageSize => "letter", 
                                  PageOrientation => "Landscape");

%opts:
	
        PageSize - '4A', '2A', 'A0', 'A1', 'A2',
                   'A3', 'A4', 'A5', 'A6', '4B', 
                   '2B', 'B0', 'B1', 'B2', 'B3', 
                   'B4', 'B5', 'B6', 'LETTER', 
                   'BROADSHEET', 'LEDGER', 'TABLOID', 
                   'LEGAL', 'EXECUTIVE', '36X36'

	PageOrientation - 'Portrait', 'Landscape'

=cut

# Create a new PDF document
sub new {
  my $class    = shift @_;
  my %defaults = @_;

  foreach my $dflt (@parameterlist) {
    if (defined($defaults{$dflt})) {
      $DEFAULTS{$dflt} = $defaults{$dflt}; # Overridden from user
    }
  }

  # Set the width and height of the page
  my ($pageWidth, $pageHeight) = @{$PDF::API2::Page::pgsz{$DEFAULTS{PageSize}}};
  ($pageWidth, $pageHeight) = @{$PDF::API2::Page::pgsz{$defaults{PageSize}}} 
  			if length($defaults{PageSize});

  # Swap w and h if landscape
  if (lc($DEFAULTS{PageOrientation})=~/landscape/) {
    my $tempW = $pageWidth;
    $pageWidth = $pageHeight;
    $pageHeight = $tempW;
    $tempW = undef;
  }

  my $MARGINX = $DEFAULTS{marginX};
  my $MARGINY = $DEFAULTS{marginY};

  # May not need alot of these, will review later
  my $self= { pdf          => PDF::API2->new(),
              hPos         => undef,
              vPos         => undef,
              size         => 12,    # Default
              font         => undef, # the font object
              PageWidth    => $pageWidth,
              PageHeight   => $pageHeight,
              Xmargin      => $MARGINX,
              Ymargin      => $MARGINY,
              BodyWidth    => $pageWidth - $MARGINX * 2,
              BodyHeight   => $pageHeight - $MARGINY * 2,
              page         => undef, # the current page object
              page_nbr     => 1,
              align        => 'left',
              linewidth    => 1,
              linespacing  => 0,
              FtrFontName  => 'Helvetica-Bold',
              FtrFontSize  => 11,
              MARGIN_DEBUG => 0
            };
  $self->{font} = $self->{pdf}->corefont('Helvetica'), # Default font object
  $self->{font}->encode('latin1');

  bless $self, $class;

  # Set the users options
  foreach my $key (keys %defaults) {
    $self->{$key}=$defaults{$key};
  }

  return $self;
}

=item $pdf->newpage();

Creates a new blank page.  Pass a 1 to toggle page numbering.

=cut

sub newpage {
  my $self = shift;
  my $no_page_number = shift;

  # make a new page
  $self->{page} = $self->{pdf}->page;
  $self->{page}->mediabox($self->{PageWidth}, $self->{PageHeight});

  # Handle the page numbering if this page is to be numbered
  my $total = $self->pages;
  push(@{$self->{no_page_num}}, $no_page_number);
    
  $self->{page_nbr}++;
  return(0);
}

=item ($pagewidth, $pageheight) = $pdf->getPageDimensions();

Returns the width and height of the page according to what page size chosen
in "new".

=cut

sub getPageDimensions {
  my $self = shift;
 
   return($self->{PageWidth}, $self->{PageHeight});
}

=item $pdf->addRawText($text, $x, $y);

Add $text at position $x, $y 

=cut

# This positions string $text at $x, $y
sub addRawText {
  my ( $self, $text, $x, $y ) = @_;
 
  my $txt = $self->{page}->text;
  $txt->font($self->{font}, $self->{size});
  $txt->translate($x, $y);
  $txt->text($text);
}

=item B<To use a fixed width string with more than one space between words, you can do something like:>

sub replaceSpace {
  my $text = shift;
  my $nbsp = "\xA0";
  my $new = '';
  my @words = split(/ /, $text);
  foreach my $word (@words) {
    if (length($word)) {
      $new.=$word . ' ';
    } else {
      $new.=$nbsp . $nbsp;
    }
  } 
  chop($new);
  return $new;
}

=cut

#sub replaceSpace {
#  my $text = shift;
#  my $nbsp = "\xA0";
#  my $new = '';
#
#  my @words = split(/ /, $text);
#  foreach my $word (@words) {
#    if (length($word)) {
#      $new.=$word . ' ';
#    } else {
#      $new.=$nbsp . $nbsp;
#    }
#  } 
#  chop($new);
#  return $new;
#}

=item $pdf->setAddTextPos($hPos, $vPos);

Set the position on the page.  Used by the addText function.

=cut

sub setAddTextPos {
  my ($self, $hPos, $vPos) = @_;
  $self->{hPos}=$hPos;
  $self->{vPos}=$vPos;
}

=item ($hPos, $vPos) = $pdf->getAddTextPos();

Return the (x, y) value of the text position.

=cut

sub getAddTextPos {
  my ($self) = @_;
  return($self->{hPos}, $self->{vPos});
}

=item $pdf->setAlign($align);

Set the justification of the text.  Used by the addText function.

=cut

sub setAlign {
  my ( $self, $align )= @_;
  $align=lc($align);
  if ($align=~m/^left$|^right$|^center$/) {
    $self->{align}=$align;
    $self->{hPos}=undef;        # Clear addText()'s tracking of hPos
  }
}

=item $align = $pdf->getAlign();

Returns the text justification.

=cut

sub getAlign {
  my $self= shift @_;
  return($self->{align});
}

=item $newtext = $pdf->wrapText($text, $width); 

This is a helper function called by addText, which can be called by itself.
wrapText() wraps $text within $width.

=cut

sub wrapText {
  my ( $self, $text, $width )= @_;
  return $text if ($text =~ /\n/);  # We don't wrap text with carriage returns

  my $txt = $self->{page}->text;
  $txt->font($self->{font}, $self->{size});

  my $ThisTextWidth=$txt->advancewidth($text);
  return $text if ( $ThisTextWidth <= $width);

  my $widSpace = $txt->advancewidth('t');  # 't' closest width to a space

  my $currentWidth = 0;
  my $newText = "";
  foreach ( split / /, $text ) {
    my $strWidth = $txt->advancewidth($_);
    if ( ( $currentWidth + $strWidth ) > $width ) {
      $currentWidth = $strWidth + $widSpace;
      $newText .= "\n$_ ";
    } else {
      $currentWidth += $strWidth + $widSpace;
      $newText .= "$_ ";
    }
  }

  return $newText;
}

=item $pdf->addText($text, $hPos, $textWidth); 

Takes $text and prints it to the current page at $hPos.  You may just want 
to pass this function $text if the text is "pre-wrapped" and setAddTextPos 
has been called previously.  Pass a $hPos to change the position the text 
will be printed on the page.  Pass a  $textWidth and addText will wrap the 
text for you.

=cut

sub addText {
  my ( $self, $text, $hPos, $textWidth )= @_;

  my $txt = $self->{page}->text;
  $txt->font($self->{font}, $self->{size});

  # Push the margin on for align=left (need to work on align=right) LHH
  if ( ($hPos=~/^[0-9]+([.][0-9]+)?$/) && ($self->{align}=~ /^left$/i) ) {
    $self->{hPos}=$hPos + $self->{Xmargin};
  }

  # Establish a proper $self->{hPos} if we don't have one already
  if ($self->{hPos} !~ /^[0-9]+([.][0-9]+)?$/) {
    if ($self->{align}=~ /^left$/i) {
      $self->{hPos} = $self->{Xmargin};
    } elsif ($self->{align}=~ /^right$/i) {
      $self->{hPos} = $self->{PageWidth} - $self->{Xmargin};
    } elsif ($self->{align}=~ /^center$/i) {
      $self->{hPos} = int($self->{PageWidth} / 2);
    }
  }

  # If the user did not give us a $textWidth, use the distance
  # from $hPos to the right margin as the $textWidth for align=left,
  # use the distance from $hPos back to the left margin for align=right
  if ( ($textWidth !~ /^[0-9]+$/) && ($self->{align}=~ /^left$/i) ) {
    $textWidth = $self->{BodyWidth} - $self->{hPos} + $self->{Xmargin};
  } elsif ( ($textWidth !~ /^[0-9]+$/) && ($self->{align}=~ /^right$/i) ) {
    $textWidth = $self->{hPos} + $self->{Xmargin};
  } elsif ( ($textWidth !~ /^[0-9]+$/) && ($self->{align}=~ /^center$/i) ) {
    my $textWidthL=$self->{BodyWidth} - $self->{hPos} + $self->{Xmargin};
    my $textWidthR=$self->{hPos} + $self->{Xmargin};
    $textWidth = $textWidthL;
    if ($textWidthR < $textWidth) { $textWidth = $textWidthR; }
    $textWidth = $textWidth * 2;
  }

  # If $self->{vPos} is not set calculate it (on first text add)
  if ( ($self->{vPos} == undef) || ($self->{vPos} == 0) ) {
    $self->{vPos} = $self->{PageHeight} - $self->{Ymargin} - $self->{size};
  }

  # If the text has no carrige returns we may need to wrap it for the user
  if ( $text !~ /\n/ ) {
    $text = $self->wrapText($text, $textWidth);
  }

  if ( $text !~ /\n/ ) {
    # Determine the width of this text
    my $thistextWidth = $txt->advancewidth($text);

    # If align ne 'left' (the default) then we need to recalc the xPos
    # for this call to addRawText()  -- needs attention -- LHH
    my $xPos=$self->{hPos};
    if ($self->{align}=~ /^right$/i) {
      $xPos=$self->{hPos} - $thistextWidth;
    } elsif ($self->{align}=~ /^center$/i) {
      $xPos=$self->{hPos} - $thistextWidth / 2;
    }
    $self->addRawText($text,$xPos,$self->{vPos});

    $thistextWidth = -1 * $thistextWidth if ($self->{align}=~ /^right$/i);
    $thistextWidth = -1 * $thistextWidth / 2 if ($self->{align}=~ /^center$/i);
    $self->{hPos} += $thistextWidth;
  } else {
    $text=~ s/\n/\0\n/g;                # This copes w/strings of only "\n"
    my @lines= split /\n/, $text;
    foreach ( @lines ) {
      $text= $_;
      $text=~ s/\0//;
      if (length( $text )) {
        $self->addRawText($text, $self->{hPos}, $self->{vPos});
      }
      if (($self->{vPos} - $self->{size}) < $self->{Ymargin}) {
        $self->{vPos} = $self->{PageHeight} - $self->{Ymargin} - $self->{size};
        $self->newpage;
      } else {
        $self->{vPos} -= $self->{size} - $self->{linespacing};
      }
    }
  }
}

=item $pdf->addParagragh($text, $hPos, $vPos, $width, $indent);

Add $text at ($hPos, $vPos) within $width with $indent.  
$indent is the number of spaces at the beginning of the first line.

=cut

sub addParagragh {
  my ( $self, $text, $hPos, $vPos, $width, $indent ) = @_;

  my $tempTxt;
  my $space;
  for (1 .. $indent) {
    $space.=" ";
  }
  $tempTxt = $space . $text;
  $text = $tempTxt;
  undef $tempTxt;

  $self->setAddTextPos($hPos, $vPos);
  $self->addText($text, undef);
}

=item $pdf->centerString($a, $b, $yPos, $text); 

Centers $text between points $a and $b at position $yPos.  Be careful how much 
text you try to jam between those points, this function shrinks the text till
it fits!

=cut

sub centerString {  ### CENTERS STRING BETWEEN TWO POINTS
  my $self = shift;
  my $PointBegin = shift;
  my $PointEnd = shift;
  my $YPos = shift;
  my $String = shift;
 
  my $OldTextSize = $self->getSize;
  my $TextSize = $OldTextSize;

  my $Area = $PointEnd - $PointBegin;
 
  my $StringWidth;
  while (($StringWidth = $self->getStringWidth($String)) > $Area) {
    $self->setSize(--$TextSize);  ### DECREASE THE FONTSIZE TO MAKE IT FIT
  }

  my $Offset = ($Area - $StringWidth) / 2;
  $self->addRawText("$String",$PointBegin+$Offset,$YPos);
  $self->setSize($OldTextSize);
} 

sub setRowHeight {
  my $self = shift;
  my $size = shift; # the fontsize

  return (int($size * 1.20));
}

=item $pdf->getStringWidth($String); 

Returns the width of $String according to the current font and fontsize being 
used.

=cut

# replaces silly $pdf->{pdf}->calcTextWidth calls    
sub getStringWidth {
  my $self = shift;
  my $String = shift;

  my $txt = $self->{page}->text;
  $txt->font($self->{font}, $self->{size});
  return $txt->advancewidth($String);
}

=item $pdf->addImg($file, $x, $y); 

Add image $file to the current page at position ($x, $y).

=cut

sub addImg {
  my ( $self, $file, $x, $y ) = @_;

  my $img = $self->{pdf}->image($file);
  my $gfx = $self->{page}->gfx;

  $gfx->image($img, $x, $y);
}

=item $pdf->addImg($file, $x, $y); 

Add image $file to the current page at position ($x, $y) scaled to $scale.

=cut

sub addImgScaled {
  my ( $self, $file, $x, $y, $scale ) = @_;

  my $img = $self->{pdf}->image($file);
  my $gfx = $self->{page}->gfx;

  $gfx->image($img, $x, $y, $scale);
}

=item $pdf->setGfxLineWidth($width);

Set the line width drawn on the page.

=cut

sub setGfxLineWidth {
  my ( $self, $width ) = @_;

  $self->{linewidth} = $width;
}

=item $width = $pdf->getGfxLineWidth();

Returns the current line width.

=cut

sub getGfxLineWidth {
  my $self = shift;

  return $self->{linewidth};
}

=item $pdf->drawLine($x1, $y1, $x2, $y2); 

Draw a line on the current page starting at ($x1, $y1) and ending 
at ($x2, $y2).

=cut

sub drawLine {
  my ( $self, $x1, $y1, $x2, $y2 ) = @_;

  my $gfx = $self->{page}->gfx;
  $gfx->move($x1, $y1);
  $gfx->linewidth($self->{linewidth});
  $gfx->line($x2, $y2);
  $gfx->stroke;
}

=item $pdf->drawRect($x1, $y1, $x2, $y2); 

Draw a rectangle on the current page.  Top left corner is represented by
($x1, $y1) and the bottom right corner is ($x2, $y2).

=cut

sub drawRect { 
  my ( $self, $x1, $y1, $x2, $y2 ) = @_;

  my $gfx = $self->{page}->gfx;
  $gfx->rectxy($x1, $y1, $x2, $y2);
  $gfx->stroke;
}

=item $pdf->shadeRect($x1, $y1, $x2, $y2, $color);

Shade a rectangle with $color.  Top left corner is ($x1, $y1) and the bottom 
right corner is ($x2, $y2).

=cut

=item B<Defined color-names are:>

aliceblue, antiquewhite, aqua, aquamarine, azure,
beige, bisque, black, blanchedalmond, blue,
blueviolet, brown, burlywood, cadetblue, chartreuse,
chocolate, coral, cornflowerblue, cornsilk, crimson,
cyan, darkblue, darkcyan, darkgoldenrod, darkgray,
darkgreen, darkgrey, darkkhaki, darkmagenta,
darkolivegreen, darkorange, darkorchid, darkred,
darksalmon, darkseagreen, darkslateblue, darkslategray,
darkslategrey, darkturquoise, darkviolet, deeppink,
deepskyblue, dimgray, dimgrey, dodgerblue, firebrick,
floralwhite, forestgreen, fuchsia, gainsboro, ghostwhite,
gold, goldenrod, gray, grey, green, greenyellow,
honeydew, hotpink, indianred, indigo, ivory, khaki,
lavender, lavenderblush, lawngreen, lemonchiffon,
lightblue, lightcoral, lightcyan, lightgoldenrodyellow,
lightgray, lightgreen, lightgrey, lightpink, lightsalmon,
lightseagreen, lightskyblue, lightslategray,
lightslategrey, lightsteelblue, lightyellow, lime,
limegreen, linen, magenta, maroon, mediumaquamarine,
mediumblue, mediumorchid, mediumpurple, mediumseagreen,
mediumslateblue, mediumspringgreen, mediumturquoise,
mediumvioletred, midnightblue, mintcream, mistyrose,
moccasin, navajowhite, navy, oldlace, olive, olivedrab,
orange, orangered, orchid, palegoldenrod, palegreen,
paleturquoise, palevioletred, papayawhip, peachpuff,
peru, pink, plum, powderblue, purple, red, rosybrown,
royalblue, saddlebrown, salmon, sandybrown, seagreen,
seashell, sienna, silver, skyblue, slateblue, slategray,
slategrey, snow, springgreen, steelblue, tan, teal,
thistle, tomato, turquoise, violet, wheat, white,
whitesmoke, yellow, yellowgreen

or the rgb-hex-notation:

	#rgb, #rrggbb, #rrrgggbbb and #rrrrggggbbbb

or the cmyk-hex-notation:

        %cmyk, %ccmmyykk, %cccmmmyyykkk and %ccccmmmmyyyykkkk

and additionally the hsv-hex-notation:

        !hsv, !hhssvv, !hhhsssvvv and !hhhhssssvvvv

=cut

sub shadeRect {  
  my ( $self, $x1, $y1, $x2, $y2, $color ) = @_;

  my $gfx = $self->{page}->gfx;

  $gfx->fillcolor($color);
  $gfx->rectxy($x1, $y1, $x2, $y2);
  $gfx->fill;
}

=item $pdf->setFont($font);

Creates a new font object of type $font to be used in the page.

=cut

sub setFont {
  my ( $self, $font, $size )= @_;

  $self->{font} = $self->{pdf}->corefont($font);
  $self->{fontname} = $font;
}

=item $fontname = $pdf->getFont();

Returns the font name currently being used.

=cut

sub getFont {
  my $self = shift;

  return $self->{fontname};
}

=item $pdf->setSize($size); 

Sets the fontsize to $size.  Called before setFont().

=cut

# sets the font size
sub setSize {
  my ( $self, $size ) = @_;

  $self->{size} = $size;
}

=item $fontsize = $pdf->getSize();

Returns the font size currently being used.

=cut

sub getSize {
  my $self = shift;

  return $self->{size};
}

# the number of pages
sub pages {
  my $self = shift;

  return $self->{pdf}->pages;
}

=item $pdf->setInfo(%infohash);

Sets the info structure of the document.  Valid keys for %infohash: 

=cut

sub setInfo {
  my ($self, %info) = @_;

  # Over-ride or define %INFO values
  foreach my $key (keys %INFO) {
    if (length($info{$key}) and ($info{$key} ne $INFO{$key})) {
      $INFO{$key} = $info{$key};
    } 
  }
  my @orig_keys = keys(%INFO);
  foreach my $key (keys %info) {
    if (! grep /$key/, @orig_keys) {
      $INFO{$key} = $info{$key};
    }
  }
}

=item print $pdf->Finish();

Returns the PDF document as text.  

=cut

=item B<Example:>

	# Hand the document to the web browser
	print "Content-type: application/pdf\n\n";
	print $pdf->Finish();

=cut

sub Finish {
  my $self = shift;

  my $total = $self->{page_nbr} - 1;
  for (my $i = 1; $i < $self->{page_nbr}; $i++) {
    # Don't number if this is true
    if ($self->{no_page_num}->[$i - 1]) { next; }
    my $page = $self->{pdf}->openpage($i);
    my $txtobj = $page->text;
    my $txt = "Page $i of $total";
    my $font = $self->{pdf}->corefont("Helvetica");
    my $size = 10;
    $txtobj->font($font, $size);
    $txtobj->translate($self->{Xmargin}, 8);
    $txtobj->text($txt);
    my $size = $self->getStringWidth($DATE);
    $txtobj->translate($self->{PageWidth} - $self->{Xmargin} - $size, 8);
    $txtobj->text($DATE);
  }  

  $self->{pdf}->info(%INFO);
  my $out = $self->{pdf}->stringify;

  return $out;
}
### END GLOBAL SUBS ###########################################################

### PRIVATE SUBS ##############################################################

### END PRIVATE SUBS ##########################################################

=head1 AUTHOR

Andrew Orr

=cut

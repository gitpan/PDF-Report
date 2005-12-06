###############################################################################
# This is a wrapper for Alfred Reibenschuh's PDF::API2
# Defines methods to create PDF reports
# By: Andy Orr
# Date: 03/04/2005 
# Version: 1.30
###############################################################################

package PDF::Report::Table;

$VERSION = "1.30"; 

=head1 PDF::Report 

=head1 NAME

PDF::Report - A wrapper written for PDF::API2

=head1 SYNOPSIS
	
	use PDF::Report;
	use PDF::Report::Table;

  my $pdf = new PDF::Report(
    'PageSize' => 'letter',
    'PageOrientation' => 'Portrait',
  );

  my $some_data =[
    ["test1", "test2", "test3"],
    ["test4", "test5", "test6"],
    ["test7", "test8", "test9"],
  ];
  
  $pdf->addTable($some_data);

=cut

use strict;
use PDF::Report;
use PDF::Table;

=item $pdf->addTable(@data);

Add Table

=cut

sub addTable {
  my $self = shift @_;
  my $data = shift @_;
  my $width = shift @_ || '';
  my $padding = shift @_ || 5;
  my $bgcolor_odd = shift @_ || "#FFFFFF";
  my $bgcolor_even = shift @_ || "#FFFFCC";
  
  my $pdftable = new PDF::Table;
  
  warn "vPos: " . $self->{vPos};
  warn "hPos: " . $self->{hPos};
  warn "PageHeight: " . $self->{PageHeight};
  
  $pdftable->table(
    # required params
    $self->{pdf},
    $self->{page},
    $data,
    -x  => $self->{hPos},
    -start_y => $self->{vPos},
    -start_h => $self->{PageHeight},
    -w => $width, 
    -padding => $padding,
    -background_color_odd => $bgcolor_odd, 
    -background_color_even => $bgcolor_even,
  ); 
}


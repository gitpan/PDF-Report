use ExtUtils::MakeMaker;
use PDF::API2;

$PDF_API2_PREREQ = "0.3r74";

if ($PDF::API2::VERSION lt $PDF_API2_PREREQ) {
  print "PDF::API2 version $PDF::API2::VERSION too old!\nYou need at least " .
        "$PDF_API2_PREREQ\n";
  print "Aborting...\n";
  exit;
}

# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    'NAME'		=> 'PDF::Report',
    'VERSION'	        => 1.20, 
#    'PREREQ_PM'		=> {PDF::API2 => '0.3r74'},
    ($] >= 5.005 ?    ## Add these new keywords supported since 5.005
      (ABSTRACT_FROM => 'Report.pm', # retrieve abstract from module
       AUTHOR     => 'Andrew Orr <aorr@cpan.org>') : ()),
);

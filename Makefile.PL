use ExtUtils::MakeMaker;

$PDF_API2_PREREQ = "0.40.00";

# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    'NAME'		=> 'PDF::Report',
    'VERSION'	        => 1.31, 
    'PREREQ_PM'		=> {PDF::API2 => $PDF_API2_PREREQ},
    ($] >= 5.005 ?    ## Add these new keywords supported since 5.005
      (ABSTRACT_FROM => 'Report.pm', # retrieve abstract from module
       AUTHOR     => 'Andrew Orr <aorr@cpan.org>') : ()),
);

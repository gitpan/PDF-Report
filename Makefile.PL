use ExtUtils::MakeMaker;

# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    'NAME'		=> 'PDF::Report',
    'VERSION'	        => 1.00, 
    'PREREQ_PM'		=> {PDF::API2 => '0.3a9', Text::Roman => '3.01'},
    ($] >= 5.005 ?    ## Add these new keywords supported since 5.005
      (ABSTRACT_FROM => 'Report.pm', # retrieve abstract from module
       AUTHOR     => 'Andrew Orr <aorr@cpan.org>') : ()),
);

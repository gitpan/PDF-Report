use ExtUtils::MakeMaker;

$PDF_API2_PREREQ = "0.3r74";

eval {
  require PDF::API2;

  if ($PDF::API2::VERSION lt $PDF_API2_PREREQ) {
    print "Warning, PDF::API2 version $PDF::API2::VERSION too old!\n" .
          "You should use at least version $PDF_API2_PREREQ\n" .
          "Continuing anyway...\n";
  }
};

print "PDF::API2 Doesn't seem to be installed!\n\n" 
  if $@ =~ /Can't locate PDF\/API2\.pm/; 

# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    'NAME'		=> 'PDF::Report',
    'VERSION'	        => 1.21, 
    'PREREQ_PM'		=> {PDF::API2 => '0.3r74'},
    ($] >= 5.005 ?    ## Add these new keywords supported since 5.005
      (ABSTRACT_FROM => 'Report.pm', # retrieve abstract from module
       AUTHOR     => 'Andrew Orr <aorr@cpan.org>') : ()),
);

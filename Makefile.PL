use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
              'NAME'		=> 'mybench',
              'VERSION_FROM'	=> 'MyBench.pm', # finds $VERSION
              'EXE_FILES'		=> [ 'bench_example' ],
              'PREREQ_PM'		=> {
                                            DBI           => 1.13,
                                            DBD::mysql    => 1.0,
                                           },
              'LIBS'		=> [''], # e.g., '-lm'
              'DEFINE'		=> '', # e.g., '-DHAVE_SOMETHING'
              'INC'		=> '', # e.g., '-I/usr/include/other'
);

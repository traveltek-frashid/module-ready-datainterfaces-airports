use strict;
use Test::Compile;
use File::Find::Rule;

my $dir = "lib/";
my @files = File::Find::Rule->file()->name('*.pm')->in($dir);

all_pm_files_ok(@files);
#!/usr/bin/perl

use strict;
use warnings;

use FindBin;
use TestLibFinder;
use lib test_lib_loc();


use CRI::Test;

plan('no_plan');
setDesc("ALL Torque Regression Tests");

my $testbase = $FindBin::RealBin;

execute_tests(
    "$testbase/reinstall_blcr.bat",
) or die("Torque reinstall test failed!");

execute_tests(
    "$testbase/commands/all.bat",
    "$testbase/job_arrays/release.bat",
    "$testbase/prologue_epilogue/all.bat",
    "$testbase/ha/all.bat",
);
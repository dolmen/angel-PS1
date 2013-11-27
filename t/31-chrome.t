#!perl
use strict;
use warnings FATAL => 'all';

use Test::More tests => 3;
use AngelPS1::Chrome;

is(Red->term, "\e[31m", 'Red');

my $BoldRed = Red + Bold;
isa_ok($BoldRed, 'AngelPS1::Chrome', 'Red+Bold');
is((Red+Bold)->term, "\e[1;31m", 'Red+Bold');

#done_testing;

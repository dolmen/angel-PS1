#!perl
use strict;
use warnings FATAL => 'all';

use Test::More tests => 6;
use AngelPS1::Chrome;

is(Red->term, "\e[31m", 'Red');
is(Bold->term, "\e[1m", 'Bold');

my $BoldRed = Red + Bold;
ok(defined($BoldRed),'Red+Bold defined');
is(ref($BoldRed), 'AngelPS1::Chrome', 'ref(Red+Bold)');
isa_ok($BoldRed, 'AngelPS1::Chrome', 'Red+Bold')
    or diag $BoldRed;
is((Red+Bold)->term, "\e[1;31m", 'Red+Bold');

#done_testing;

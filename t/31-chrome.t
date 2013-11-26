#!perl
use strict;
use warnings FATAL => 'all';

use Test::More tests => 1;
use AngelPS1::Chrome;

is((Red+Bold)->term, "\e[1;31m", );

done_testing;

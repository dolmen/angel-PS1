#!perl
use strict;
use warnings FATAL => 'all';

use Test::More 0.98 tests => 11;
use AngelPS1::Chrome;

is(Red->term, "\e[31m", 'Red');
is(Bold->term, "\e[1m", 'Bold');

my $BoldRed = Red + Bold;
ok(defined($BoldRed),'Red+Bold defined');
is(ref($BoldRed), 'AngelPS1::Chrome', 'ref(Red+Bold)');
isa_ok($BoldRed, 'AngelPS1::Chrome', 'Red+Bold')
    or diag $BoldRed;
is((Red+Bold)->term, "\e[1;31m", 'Red+Bold->term');
is("$BoldRed",       "\e[1;31m", "Red+Bold stringification");

note("@{[ Blue / Yellow + Reset + Reverse ]}Text@{[ Reset ]}");
is("@{[ Blue / Yellow + Reset + Reverse ]}Text@{[ Reset ]}",
    "\e[;7;34;43mText\e[m",
    "Blue / Yellow + Reset + Reverse");

is("${ Red+Bold }", "\e[1;31m", 'deref: ${ Red+Bold }');
is("${ +Red }", "\e[31m", 'deref: ${ +Red }');
is("${( Red )}", "\e[31m", 'deref: ${( Red )}');
note("normal ${ Red+Bold } RED ${ +Reset } normal");

done_testing;

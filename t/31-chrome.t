#!perl
use strict;
use warnings FATAL => 'all';

use Test::More 0.98 tests => 24;
use AngelPS1::Chrome;
use Scalar::Util 'refaddr';

is(Red->term, "\e[31m", 'Red');
is(Bold->term, "\e[1m", 'Bold');

my $BoldRed = Red + Bold;
ok(defined($BoldRed),'Red+Bold defined');
is(ref($BoldRed), 'Term::Chrome', 'ref(Red+Bold)');
isa_ok($BoldRed, 'Term::Chrome', 'Red+Bold')
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

note("${ Black / White }Black / White${ +Reset }");

foreach my $name (qw<Red Green Yellow Blue Magenta Cyan White
                     Bold Blink Reverse Underline>) {
    no strict 'refs';
    note(&{"Term::Chrome::$name"} . $name . Reset);
}

is(substr("${ (color(31) / color(240)) + Reset }", 1),
	 "[;38;5;31;48;5;240m");

# Test extracting components
is(${ Blue->fg }, ${ +Blue }, 'Blue->fg');
is(   Blue->bg,   undef,      'Blue->bg => undef');
is(${ (Red/Blue)->fg }, ${ +Red }, '(Red/Blue)->fg');
is(${ (Red/Blue)->bg }, ${ +Blue }, '(Red/Blue)->bg');
is(${ (Red/Blue+Underline)->fg }, ${ +Red }, '(Red/Blue+Underline)->fg');
is(${ (Red/Blue+Underline)->bg }, ${ +Blue }, '(Red/Blue+Underline)->bg');
is(${ Underline->flags }, ${ +Underline }, 'Underline->flags');
is(${ (Red+Underline)->flags }, ${ +Underline }, '(Red+Underline)->flags');
is(${ (Reset+Underline)->flags }, ${ Reset+Underline }, '(Reset+Underline)->flags');

# Test caching
note "Scalar::Util $Scalar::Util::VERSION";
is(refaddr(color 1), refaddr(color 1),
    'Same object returned by multiple calls of "color 1"');
# As we are using the ||= operator in the implementation of the cache, it is
# better to also check that the value "0" doesn't do nasty things
is(refaddr(color 0), refaddr(color 0),
    'Same object returned by multiple calls of "color 0"');
is(refaddr(color 0), refaddr(Black),
    'Same object returned by call of "color 0" and "Black"');

done_testing;

#!perl
use utf8;
use strict;
use warnings;

use Test::More;

use AngelPS1::Plugin::Gauges
    qw<ColoredGauge CharGauge>;
use AngelPS1::Chrome qw<color Green Bold>;
use AngelPS1::Shell;
use AngelPS1::Compiler qw<reduce>;

AngelPS1::Shell->use('POSIX');

use Term::Encoding 'term_encoding';
my $enc = term_encoding();
note $enc;  # Ensure that builder->output is opened
binmode($_, ":encoding($enc)")
    for Test::More->builder->output;

note scalar reduce ColoredGauge(Green / Green + Bold, 0.4);
# _▁▂▃▄▅▆▇█
# _▁▂▃▄▅▆▇█

{
    local $TODO = "Fix CharGauge";
    is(CharGauge(1), '█');
    is(CharGauge(0.99), '█');
    is(CharGauge(0.85), '█');
}


pass;
done_testing;

#!perl
use strict;
use warnings FATAL => 'all';

use Test::More;

BEGIN {
    eval { require Test::MockTime }
        or plan skip_all => 'Test::MockTime not installed';
}
BEGIN {
    Test::MockTime->import 'set_fixed_time';
}

use AngelPS1::Plugin::DateTime;


plan tests => 4;

my @Time = Time;
isa_ok($Time[0], 'CODE');

my @StrFTime = StrFTime '[%Y]';
isa_ok($StrFTime[0], 'CODE');

set_fixed_time 1372712238;

is($StrFTime[0]->({}), '[2013]');

SKIP: {
    (scalar localtime) eq 'Mon Jul  1 22:57:18 2013'
        or skip 'Not in Europe/Paris (or similar timezone)' => 1;

    is($Time[0]->({}), '22:57:18');
}

# vim:set et ts=8 sw=4 sts=4:

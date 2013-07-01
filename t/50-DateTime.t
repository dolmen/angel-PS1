#!perl
use strict;
use warnings FATAL => 'all';

use Test::More tests => 2;
use Test::MockTime 'set_fixed_time';

use AngelPS1::Plugin::DateTime;


my @Time = Time;
isa_ok($Time[0], 'CODE');

SKIP: {
    set_fixed_time 1372712238;
    (scalar localtime) eq 'Mon Jul  1 22:57:18 2013'
        or skip 'Not in Europe/Paris (or similar timezone)' => 1;

    is($Time[0]->({}), '22:57:18');
}

# vim:set et ts=8 sw=4 sts=4:

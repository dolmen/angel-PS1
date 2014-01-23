#!perl

use strict;
use warnings;

use Test::More;

use AngelPS1::Util qw<one_line>;

is(one_line("abc\n"), 'abc', 'one_line');
is(one_line("abc"),   'abc', 'one_line');

done_testing;

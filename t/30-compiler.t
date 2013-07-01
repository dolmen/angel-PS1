#!perl
use strict;
use warnings FATAL => 'all';

use Test::More;

use AngelPS1::Compiler;

ok(ps1_is_static([ \'xxxx$ ' ]), 'ps1_is_static');
ok(!ps1_is_static([ sub { } ]), '!ps1_is_static');
ok(!ps1_is_static([ 'xx' ]), '!ps1_is_static');
ok(!ps1_is_static([ 'xx$', 'xx' ]), '!ps1_is_static');
ok(!ps1_is_static([ \'xx$', \'xx' ]), '!ps1_is_static');

done_testing
__END__
# vim:set et ts=8 sw=4 sts=4:

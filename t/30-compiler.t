#!perl
use strict;
use warnings FATAL => 'all';

use Test::More;

use AngelPS1::Compiler;
use Term::Chrome qw< Red >;

ok(ps1_is_static([ \'xxxx$ ' ]), 'ps1_is_static');
ok(!ps1_is_static([ sub { } ]), '!ps1_is_static');
ok(!ps1_is_static([ 'xx' ]), '!ps1_is_static');
ok(!ps1_is_static([ 'xx$', 'xx' ]), '!ps1_is_static');
ok(!ps1_is_static([ \'xx$', \'xx' ]), '!ps1_is_static');

is_deeply([ expand({}, \'x') ], [ \'x' ]);
is(scalar reduce(expand({}, \'x')), 'x');
is(scalar reduce(expand({}, \'x', sub { \'y' })), 'xy');
is(scalar reduce(expand({}, \'x', sub { \'y' }, \'z')), 'xyz');
is(scalar reduce(expand({}, \'x', sub { sub { \'y' } }, \'z')), 'xyz');
is(scalar reduce(expand({}, \'x', sub { (\'y', sub { \'z' }) }, \'t')), 'xyzt');
is(scalar reduce(expand({}, \'x', sub { (sub { \'y' }, \'z') }, \'t')), 'xyzt');

# Subs that returns an empty list
is(scalar reduce(expand({}, \'x', sub { () }, \'y')), 'xy');
is(scalar reduce(expand({}, \'x', sub { () })), 'x');
is(scalar reduce(expand({}, \'x', sub { sub { () } }, \'y')), 'xy');

is(scalar reduce(expand({}, sub { \'x' })), 'x');


AngelPS1::Shell->use('dash');
is(scalar reduce(Red, [ 'OK' ]), &{+Red}("OK"), 'reduce: Red [ "OK" ]');
is(scalar reduce(Red, [ ]), '', 'reduce: Red []');

is(scalar reduce(expand({}, Red, [ 'OK' ])), &{+Red}("OK"), 'reduce+expand: Red [ "OK" ]');
is(scalar reduce(expand({}, Red, [ sub { 'OK' } ])), &{+Red}("OK"), 'reduce+expand: Red [ sub { "OK" } ]');
is(scalar reduce(expand({}, Red, [ sub { () } ])), '', 'reduce+expand: Red [ sub { () } ]');


done_testing
__END__
# vim:set et ts=8 sw=4 sts=4:

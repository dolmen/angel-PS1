#!perl
use strict;
use warnings FATAL => 'all';

use Test::More tests => 2;

use AngelPS1::Plugin::Core;
use AngelPS1::Compiler;
use AngelPS1::Shell;

AngelPS1::Shell->use('bash');

my @MarginLeft = MarginLeft(' ', sub { $_[0]->{empty} ? () : ('Hello') });

is(scalar compact(interp({ empty => 1 }, @MarginLeft)), '');
is(scalar compact(interp({ empty => 0 }, @MarginLeft)), ' Hello');
# TODO test with colors

__END__
# vim:set et ts=8 sw=4 sts=4:

#!perl
use strict;
use warnings FATAL => 'all';

use Test::More tests => 6;

use AngelPS1::Plugin::Core;
use AngelPS1::Compiler;
use AngelPS1::Shell;

AngelPS1::Shell->use('bash');

my @MarginLeft = MarginLeft(' ', sub { $_[0]->{empty} ? () : ('Hello') });

is(scalar reduce(expand({ empty => 1 }, @MarginLeft)), '');
is(scalar reduce(expand({ empty => 0 }, @MarginLeft)), ' Hello');

# Test prototype
@MarginLeft = ('[', (MarginLeft '  ', sub { $_[0]->{empty} ? () : ('Hello') }), ']');

is(scalar reduce(expand({ empty => 1 }, @MarginLeft)), '[]');
is(scalar reduce(expand({ empty => 0 }, @MarginLeft)), '[  Hello]');

# Test default margin
@MarginLeft = ('[', (MarginLeft sub { $_[0]->{empty} ? () : ('Hello') }), ']');

is(scalar reduce(expand({ empty => 1 }, @MarginLeft)), '[]');
is(scalar reduce(expand({ empty => 0 }, @MarginLeft)), '[ Hello]');


# TODO test with colors

__END__
# vim:set et ts=8 sw=4 sts=4:

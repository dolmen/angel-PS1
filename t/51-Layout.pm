#!perl
use strict;
use warnings FATAL => 'all';

use Test::More tests => 10;

use AngelPS1::Plugin::Layout;
use AngelPS1::Compiler;
use AngelPS1::Shell;

AngelPS1::Shell->use('bash');

my @MarginLeft  = MarginLeft( '-', sub { $_[0]->{empty} ? () : ('Hello') });
my @MarginRight = MarginRight('-', sub { $_[0]->{empty} ? () : ('Hello') });

is(scalar reduce(expand({ empty => 1 }, @MarginLeft)), '');
is(scalar reduce(expand({ empty => 0 }, @MarginLeft)), '-Hello');
is(scalar reduce(expand({ empty => 1 }, @MarginRight)), '');
is(scalar reduce(expand({ empty => 0 }, @MarginRight)), 'Hello-');

# Test prototype
@MarginLeft = ('[', (MarginLeft '  ', sub { $_[0]->{empty} ? () : ('Hello') }), ']');

is(scalar reduce(expand({ empty => 1 }, @MarginLeft)), '[]');
is(scalar reduce(expand({ empty => 0 }, @MarginLeft)), '[  Hello]');

# Test default margin
@MarginLeft  = ('[', (MarginLeft  sub { $_[0]->{empty} ? () : ('Hello') }), ']');
@MarginRight = ('[', (MarginRight sub { $_[0]->{empty} ? () : ('Hello') }), ']');

is(scalar reduce(expand({ empty => 1 }, @MarginLeft)), '[]');
is(scalar reduce(expand({ empty => 0 }, @MarginLeft)), '[ Hello]');
is(scalar reduce(expand({ empty => 1 }, @MarginRight)), '[]');
is(scalar reduce(expand({ empty => 0 }, @MarginRight)), '[Hello ]');


# TODO test with colors

__END__
# vim:set et ts=8 sw=4 sts=4:

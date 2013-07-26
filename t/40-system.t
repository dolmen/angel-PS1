use strict;
use warnings;

use Test::More tests => 2;

use AngelPS1::System;

AngelPS1::System->use;

my @capabilities =
    grep { AngelPS1::System->can($_) }
         qw<nproc loadavg>;

foreach my $sub (@capabilities) {
    my $result = AngelPS1::System->$sub();
    ok(defined $result, $sub);
    diag "$sub: ", explain $result;
}

done_testing;

# vim:set et ts=8 sw=4 sts=4:

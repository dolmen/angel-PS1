use strict;
use warnings;

use Test::More;

use AngelPS1::System;

AngelPS1::System->use;

my @capabilities =
    grep { AngelPS1::System->can($_) }
         qw<nproc gen_loadavg gen_fetch_battery>;

foreach my $sub (@capabilities) {
    my $result;
    ok(eval { $result = AngelPS1::System->$sub(); 1 }, "$sub runs ok")
        or diag "$@";
    # TODO check $result
}

done_testing;

# vim:set et ts=8 sw=4 sts=4:

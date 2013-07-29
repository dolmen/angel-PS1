#!perl

use strict;
use warnings;

use Test::More;
use File::Spec ();

my @shells =
    map { substr($_, 1+rindex($_, '/'), -3) }
    <lib/AngelPS1/Shell/*.pm>;

my $shell_specific_re = do {
    my $re = join('|', @shells);
    qr/^($re)-/
};

my @examples =
    grep { $_ ne 'examples/die.PS1' }
    <examples/*.PS1>;

foreach my $ex (@examples) {
    note $ex;
    foreach my $sh (@shells) {
        next if $ex =~ $shell_specific_re && $1 ne $sh;

        system $^X '-Ilib', File::Spec->catfile('bin', 'angel-PS1'),
                '--test',
                '--shell' => $sh,
                '-c' => $ex;
        SKIP: {
            cmp_ok($?, '>=', 0, "test $ex with $sh: exec ok")
                or skip 'run failed' => 2;
            cmp_ok($? & 0xff, '==', 0, "test $ex with $sh: exit without signal");
            cmp_ok($? >> 8, '==', 0, "test $ex with $sh: exit code 0");
        }
    }
}

done_testing;

__END__
# vim: set et sw=4 sts=4 :

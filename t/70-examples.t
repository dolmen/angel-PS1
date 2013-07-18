#!perl

use strict;
use warnings;

use Test::More;
use File::Spec ();

opendir my $shells_dir, File::Spec->catdir(qw< lib AngelPS1 Shell >)
    or die;

my @shells = map { /^([a-z].*)\.pm$/ ? ($1) : () }
             readdir($shells_dir);

closedir $shells_dir;

my $shell_specific_re = do {
    my $re = join('|', @shells);
    qr/^($re)-/
};

opendir my $examples_dir, File::Spec->catdir(qw< examples >)
    or die;
my @examples = map { File::Spec->catfile('examples', $_) }
               grep { /\.PS1$/ && ! /^(\.|die\W)/ }
               readdir $examples_dir;
closedir $examples_dir;

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

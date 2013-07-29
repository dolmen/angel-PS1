use strict;
use warnings;

use Test::More;

my @shells =
    map {
        substr($_, 0, 4, ''); # remove 'lib/'
        require $_;
        s{^.*/([^/]*)\.pm$}{AngelPS1::Shell::$1};
        $_
    }
    <lib/AngelPS1/Shell/*.pm>;

my @methods = qw<
    shell_code_dynamic
    ps1_escape
    ps1_invisible
    ps1_finalize

    WorkingDir
    UserPrivSymbol
>;

plan tests => @shells * @methods;

foreach my $shell (@shells) {
    foreach my $method (@methods) {
        ok($shell->can($method), "${shell}->can($method)");
    }
}

# vim:set et ts=8 sw=4 sts=4:

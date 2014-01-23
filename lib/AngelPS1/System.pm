use strict;
use warnings;

package AngelPS1::System;

my %ALIASES = (
    cygwin => 'linux',
);

sub use
{
    my ($class, $system) = @_;
    $system ||= $^O;

    $system = $ALIASES{$system} if exists $ALIASES{$system};
    my $src = "AngelPS1/System/$system.pm";
    require $src;
    our @ISA = ("${class}::$system");
}

sub import
{
    goto &use;
}

'$';
# vim:set et ts=8 sw=4 sts=4:

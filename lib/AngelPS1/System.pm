use strict;
use warnings;

package AngelPS1::System;

my %ALIASES = (
    cygwin => 'linux',
);

my $name;

sub name
{
    $name
}

sub use
{
    return if defined $name && @_ < 2;
    my ($class, $system) = @_;
    $system ||= $^O;

    $system = $ALIASES{$system} if exists $ALIASES{$system};
    my $src = "AngelPS1/System/$system.pm";
    require $src;
    our @ISA = ("${class}::$system");
    $name = $system;
}

*import = *use;

'$';
# vim:set et ts=8 sw=4 sts=4:

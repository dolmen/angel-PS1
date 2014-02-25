use strict;
use warnings;

# A basic AngelPS1::Shell implementation that has dummy methods that
# just let pass what they receive
package AngelPS1::Shell::Raw;

sub ps1_escape
{
    $_[1]
}

sub ps1_invisible
{
    shift; # $class
    @_
}

sub ps1_finalize
{
    $_[1]
}

'$';
# vim:set et ts=8 sw=4 sts=4:

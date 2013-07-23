use strict;
use warnings;

package AngelPS1::Shell::ksh93;

use AngelPS1::Shell::mksh ();
our @ISA = ('AngelPS1::Shell::mksh');

sub ps1_function_name
{
    '_angel_PS1'
}

sub ps1_invisible
{
    shift;
    # Contrary to mksh documentation, ks93 (at least as packaged on
    # Ubuntu as version 93u-1) does not support the "\001\r" trick
    @_
}

'$';
# vim:set et ts=8 sw=4 sts=4:

use strict;
use warnings;

package AngelPS1::Shell::ksh93;

use AngelPS1::Shell::POSIX ();
our @ISA = ('AngelPS1::Shell::POSIX');


sub ps1_finalize
{
    (my $s = $_[1]) =~ s/!/!!/gs;
    $s
}


# ksh93 doesn't have 'local'
sub shell_local
{
    'typeset'
}

# Contrary to mksh documentation, ks93 (at least as packaged on
# Ubuntu as version 93u-1) does not support the "\001\r" trick
# So we do not overload ps1_invisible


# Called from AngelPS1::Shell::POSIX->shell_code_dynamic
sub ps1_time_debug
{
    # Note that "time -- " doesn't work (/usr/bin/time is used in that case)
    q|time |;
}

sub shell_code_dynamic
{
    my $class = shift;
    my $shell_code = $class->SUPER::shell_code_dynamic(@_);
    # Replace [ ... ] (external 'test' command) with [[ ... ]] (internal)
    $shell_code =~ s{([\[\]])}{$1$1}g;
    return $shell_code
}

'$';
# vim:set et ts=8 sw=4 sts=4:

use strict;
use warnings;

package AngelPS1::Shell::mksh;

use AngelPS1::Shell::POSIX ();
our @ISA = ('AngelPS1::Shell::POSIX');


use constant INVIS_CHAR => "\x01";

sub ps1_escape
{
    (my $s = $_[1]) =~ s/!/!!/gs;
    $s =~ s{([\\\$`])}{\\$1}gs;
    # TODO remove INVIS_CHAR
    $s
}

sub ps1_invisible
{
    return if @_ == 1;
    shift; # $class
    my $invis1 = INVIS_CHAR;
    my $invis2 = INVIS_CHAR;
    return (\$invis1, @_, \$invis2)
}

sub ps1_finalize
{
    my $PS1 = $_[1];
    if (index($PS1, INVIS_CHAR) >= 0) {
        # Remove useless leave/enter invisible mode
        my $inv = INVIS_CHAR;
        $PS1 =~ s/\Q$inv$inv//g;
        # Insert the special sequence that tells the invisible mode marker
        substr $PS1, 0, 0, INVIS_CHAR . "\r";
    }
    $PS1
}

sub ps1_function_name
{
    '-angel-PS1'
}

sub ps1_time_debug
{
    q|time -- |;
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

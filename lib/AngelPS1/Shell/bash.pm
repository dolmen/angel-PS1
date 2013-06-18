use strict;
use warnings;

package AngelPS1::Shell::bash;


sub ps1_escape
{
    (my $s = $_[1]) =~ s{[\\\$`]}{\\$1}gs;
    $s
}

sub ps1_invisible
{
    '\[' . $_[1] . '\]'
}


sub ps1_finalize
{
    # Escape the first and last space using bash PS1 encoding as 'read' removes spaces
    # at beginning and end of line
    (my $PS1 = $_[1]) =~ s/^ | $/\\040/g;
    # Escape \ as 'read' expands them
    $PS1 =~ s/\\/\\\\/g;
    # Escape newlines
    $PS1 =~ s/\n/\\\n/g;
    $PS1
}

sub shell_code
{
    my %options = @_;
    my ($debug, $name, $env) = @options{qw<debug name env>};

    # TODO move code from bin/angel-PS1
}

'$';
# vim:set et ts=8 sw=4 sts=4:

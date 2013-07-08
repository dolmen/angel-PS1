use strict;
use warnings;

package AngelPS1::Shell::fish;

sub ps1_escape
{
    # Do nothing
    $_[1]
}

sub ps1_invisible
{
    shift; # $class
    # Do nothing
    @_
}

sub ps1_finalize
{
    # Do nothing
    $_[1]
}


sub shell_code
{
    my ($class, %options) = @_;
    my ($DEBUG, $NAME, $IN, $OUT, $PID, $env) =
        @options{qw<debug name in out pid env>};

    # The shell code will be evaluated with eval as a single line
    # so statements must be properly terminated with ';'
    # No shell comments allowed

    #set err \$status;
    #if test ! -e '$IN'; $NAME leave; fish_prompt; return; end;
    #if ! printf '%s\\0%s' "?=\$err" "PWD=\$PWD" > '$IN'; $NAME leave; fish_prompt; return; end;
    <<EOF;
if test -n "\$APS1_NAME"; eval \$APS1_NAME leave; end;
set -g aps1_prompt_orig (functions fish_prompt | sed 's/#[^'\\''"]*\$//;s/\$/;/');
function fish_prompt;
    set _err \$status;
    if test ! -e '$IN'; $NAME leave; fish_prompt; return; end;
    printf '%s\\0%s' "?=\$_err" "PWD=\$PWD" > '$IN';
    cat '$OUT';
end;
set -g aps1_prompt (functions fish_prompt | sed '1s/fish_prompt/fish_prompt;/');
function $NAME;
    switch "\$argv[1]";
    case quit;
        $NAME leave;
    case leave;
        kill \$APS1_PID 2>/dev/null;
        rm -f -- '$IN';
        set -e -g APS1_PID;
        set -e -g APS1_NAME;
        set -e -g aps1_prompt;
        functions -e fish_prompt $NAME;
        complete -c $NAME -e;
        eval "\$aps1_prompt_orig";
        set -e -g aps1_prompt_orig;
    case mute;
        $NAME off;
    case off;
        eval "\$aps1_prompt_orig";
        complete -c $NAME -e;
        complete -c $NAME -A -f -a 'quit on';
    case unmute;
        $NAME on;
    case on;
        eval "\$aps1_prompt";
        complete -c $NAME -e;
        complete -c $NAME -A -f -a 'quit off';
    case '*';
        echo 'usage: $NAME [quit|mute|off|unmute|on]' >&2;
        return 1;
    end;
end;
complete -c $NAME -A -f -a 'quit off';
set -g APS1_PID $PID;
set -g APS1_NAME '$NAME';
EOF
}

sub WorkingDir
{
    my $home = $ENV{'HOME'};
    sub {
        my $pwd = $_[0]->{'PWD'};
        $pwd =~ s{^$home/}{~/}s;
        $pwd
    }
}

sub UserPrivSymbol
{
    \( $< ? '$' : '#' )
}

'$';
# vim:set et ts=8 sw=4 sts=4:

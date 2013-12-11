use strict;
use warnings;

package AngelPS1::Shell::zsh;

use AngelPS1::Shell::POSIX ();

sub ps1_escape
{
    (my $s = $_[1]) =~ s{%}{%%}gs;
    $s
}

sub ps1_invisible
{
    shift; # $class
    (\'%{', @_, \'%}')
}


sub ps1_finalize
{
    # Escape the first and last space using zsh PS1 zero-length code because
    # 'read' removes spaces at beginning and end of content
    (my $PS1 = $_[1]) =~ s/^ /%{%} /s;
    $PS1 =~ s/ $/ %{%}/s;
    "$PS1\001"
}

sub shell_code_static
{
    my ($class, $PS1, %options) = @_;
    $PS1 =~ s/'/'\\''/g;
    # Keeping \n is hard!
    $PS1 =~ s/\n'/'`echo "\\n'"`'/gs;
    $PS1 =~ s/\n`/'`echo '\\n\\`'`'/gs;
    $PS1 =~ s/\n(.)/'`echo '\\n$1'`'/gs;
    # Look at:
    #    echo $(echo "ab   cd")  ->  "ab cd"
    # We are in this case with < eval $(angel-PS1) > (without quotes)
    # so we replace consecutive spaces by an alternate structure
    $PS1 =~ s/  /'\\ \\ '/g;
    $PS1 = "'$PS1'";
    $PS1 =~ s/^''|[^ ]''$//gs;
    qq{[[ -n "\$APS1_NAME" ]] && \$APS1_NAME leave; set -o promptpercent; set -o nopromptbang; set -o nopromptsubst; n() {print '\\n'}; PS1=$PS1\n}
}

# Returns the code to send to the shell
sub shell_code_dynamic
{
    my ($class, %options) = @_;
    my ($DEBUG, $NAME, $IN, $OUT, $PID, $env) =
        @options{qw<debug name in out pid env>};

    my $shell_debug = $DEBUG->{'in'} ? q|printf 'DEBUG> PS1=%q\\n' "$PS1" ; | : '';

    # The shell code will be evaluated with eval as a single line
    # so statements must be properly terminated with ';'
    # No shell comments allowed
    # Consecutives raw spaces will be reduced to one
    <<EOF;
[[ -n "\$APS1_NAME" ]] && \$APS1_NAME leave;
APS1_PS1="\$PS1";
precmd()
{
    local err=\$?;
    [[ -e '$IN' ]] || { $NAME leave ; return ; };
    printf '%s\\0%s' "?=\$err" "PWD=\$PWD" > '$IN' || { $NAME leave ; return ; };
    read -rd\001 PS1 < '$OUT' || $NAME leave ;
    $shell_debug
} ;
set -o promptpercent ;
set -o nopromptbang ;
set -o nopromptsubst ;
APS1_NAME=$NAME ;
APS1_PID=$PID ;
$NAME()
{
    case "\$1" in
    leave|quit|go-away)
        PS1="\$APS1_PS1" ;
        kill \$APS1_PID 2>/dev/null ;
        rm -f -- '$IN' '$OUT' ;
        unset APS1_PS1 APS1_PID APS1_NAME ;
        trap - EXIT ;
        unset -f -- $NAME precmd ;;
    mute|off)
        PS1="\$APS1_PS1" ;;
    unmute|on)
        ;;
    *)
        echo 'usage: $NAME [quit|mute|off|unmute|on]' >&2 ;
        return 1 ;;
    esac ;
} ;
trap '$NAME leave' EXIT ;
EOF

}


sub WorkingDir
{
    \'%d'
}

sub WorkingDir_Tilde
{
    \'%~'
}


sub Hostname
{
    \'%m'
}

sub UserPrivSymbol
{
    $< ? '$' : '#'
}

'$';
# vim:set et ts=8 sw=4 sts=4:

use strict;
use warnings;

package AngelPS1::Shell::bash;


sub ps1_escape
{
    (my $s = $_[1]) =~ s{([\\\$`])}{\\$1}gs;
    $s =~ s{\n}{\\012}gs;
    $s
}

sub ps1_invisible
{
    shift; # $class
    (\'\[', @_, \'\]')
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
    "$PS1\n"
}

sub shell_code_static
{
    my ($class, $PS1, %options) = @_;
    qq{[[ -n "\$APS1_NAME" ]] && \$APS1_NAME leave; shopt -s promptvars; PS1='$PS1'\n}
}

# Returns the code to send to the shell
sub shell_code_dynamic
{
    my ($class, %options) = @_;
    my ($DEBUG, $NAME, $IN, $OUT, $PID, $env) =
        @options{qw<debug name in out pid env>};

    my $shell_debug = $DEBUG->{'in'} ? q|printf 'DEBUG> PS1=%q\\n' "$PS1" ; | : '';
    my $time_debug = $DEBUG->{'time'} ? q|time | : '';
    my $script = eval { require FindBin; $FindBin::Bin.'/'.$FindBin::Script } || $0;
    my $reload = join(' ', map { (my $x=$_) =~ s/'/'\\''/g; qq<'$x'> }
                           $^X, $script, @AngelPS1::ARGV_BACKUP);

    # The shell code will be evaluated with eval as a single line
    # so statements must be properly terminated with ';'
    # No shell comments allowed
    # No unquoted wildcards (*, ?) allowed (see GH #17). That's why we
    # use the ''*)  trick in the 'case' block of the angel function.
    <<EOF;
[[ -n "\$APS1_NAME" ]] && \$APS1_NAME leave;
APS1_PS1="\$PS1";
APS1_PROMPT_COMMAND="\$PROMPT_COMMAND";
-angel-PS1()
{
    local err=\$?;
    if [[ ! -e '$IN' ]] || ! printf '%s\\0%s' "?=\$err" "PWD=\$PWD" > '$IN' || ! read PS1 < '$OUT'; then $NAME leave ; return ; fi;
    $shell_debug
} ;
shopt -s promptvars ;
PROMPT_COMMAND='${time_debug}-angel-PS1' ;
APS1_NAME=$NAME ;
APS1_PID=$PID ;
$NAME()
{
    case "\$1" in
    reload)
        eval \$($reload) ;;
    leave|quit|go-away)
        PROMPT_COMMAND="\$APS1_PROMPT_COMMAND" ;
        PS1="\$APS1_PS1" ;
        kill \$APS1_PID 2>/dev/null ;
        rm -f -- '$IN' '$OUT' ;
        unset APS1_PS1 APS1_PID APS1_NAME APS1_PROMPT_COMMAND ;
        [[ "\$(trap -p EXIT)" = "trap -- '$NAME leave' EXIT" ]] && trap - EXIT ;
        unset -f -- $NAME -angel-PS1 ;;
    mute|off)
        PROMPT_COMMAND="\$APS1_PROMPT_COMMAND" ;
        PS1="\$APS1_PS1" ;;
    unmute|on)
        PROMPT_COMMAND=-angel-PS1 ;;
    ''*)
        echo 'usage: $NAME [reload|quit|mute|off|unmute|on]' >&2 ;
        return 1 ;;
    esac ;
} ;
trap '$NAME leave' EXIT ;
EOF

}


sub WorkingDir
{
    \'$PWD'
}

sub WorkingDir_Tilde
{
    \'\w'
}

sub Hostname
{
    \'h'
}

sub UserPrivSymbol
{
    \'\$'
}

'$';
# vim:set et ts=8 sw=4 sts=4:

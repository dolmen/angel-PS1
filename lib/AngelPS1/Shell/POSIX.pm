use strict;
use warnings;

package AngelPS1::Shell::POSIX;

sub ps1_escape
{
    (my $s = $_[1]) =~ s/!/!!/gs;
    $s =~ s{([\\\$`])}{\\$1}gs;
    $s
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

sub ps1_function_name
{
    my $angel_name = $_[1];
    # dash, (should check for the real POSIX shell) doesn't like '-' in function
    # names. Is it related to its name?
    $angel_name =~ s/-/_/g;
    "_${angel_name}_PS1"
}

sub ps1_time_debug
{
    # Not supported
    ''
}

sub shell_code
{
    my ($class, %options) = @_;
    my ($DEBUG, $NAME, $IN, $OUT, $PID, $env) =
        @options{qw<debug name in out pid env>};

    my $function_name = $class->ps1_function_name($NAME);
    my $time_debug = $DEBUG->{'time'} ? $class->ps1_time_debug : '';

    # The shell code will be evaluated with eval as a single line
    # so statements must be properly terminated with ';'
    # No shell comments allowed
    <<EOF;
[ -n "\$APS1_NAME" ] && \$APS1_NAME leave;
APS1_PS1="\$PS1";
$function_name()
{
    local err=\$?;
    [ -e '$IN' ] || { eval "echo '\$APS1_PS1'"; $NAME leave ; return ; };
    printf '%s\\0%s' "?=\$err" "PWD=\$PWD" > '$IN' || { eval "echo '\$APS1_PS1'"; $NAME leave ; return ; };
    cat $OUT || $NAME leave ;
} ;
PS1='\$($time_debug$function_name)' ;
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
        unset -f -- $NAME $function_name ;;
    mute|off)
        PS1="\$APS1_PS1" ;;
    unmute|on)
        PS1='\$($time_debug$function_name)' ;;
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

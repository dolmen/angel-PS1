use strict;
use warnings;

package AngelPS1::Shell::mksh;

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
    shift; # $class
    (\INVIS_CHAR, @_, \INVIS_CHAR)
}

sub ps1_finalize
{
    my $PS1 = $_[1];
    substr($PS1, 0, 0, INVIS_CHAR . "\r") if index($PS1, INVIS_CHAR) >= 0;
    $PS1
}

sub shell_code
{
    my ($class, %options) = @_;
    my ($DEBUG, $NAME, $IN, $OUT, $PID, $env) =
        @options{qw<debug name in out pid env>};

    my $time_debug = $DEBUG ? q|time -- | : '';

    # The shell code will be evaluated with eval as a single line
    # so statements must be properly terminated with ';'
    # No shell comments allowed
    <<EOF;
[[ -n "\$APS1_NAME" ]] && \$APS1_NAME leave;
APS1_PS1="\$PS1";
-angel-PS1()
{
    local err=\$?;
    [[ -e '$IN' ]] || { eval "echo '\$APS1_PS1'"; $NAME leave ; return ; };
    printf '%s\\0%s' "?=\$err" "PWD=\$PWD" > '$IN' || { eval "echo '\$APS1_PS1'"; $NAME leave ; return ; };
    cat $OUT || $NAME leave ;
} ;
PS1='\$(${time_debug}-angel-PS1)' ;
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
        unset -f -- $NAME -angel-PS1 ;;
    mute|off)
        PS1="\$APS1_PS1" ;;
    unmute|on)
        PS1='\$(${time_debug}-angel-PS1)' ;;
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

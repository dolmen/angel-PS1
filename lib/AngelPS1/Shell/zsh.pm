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
    pos($PS1) = 0;
    $PS1 =~ s/\G'/'\\''/g;
    # Preserve \n
    $PS1 =~ s/\n/'\$'\\n''/gs;
    $PS1 =~ s/\t/'\$'\\t''/gs;
    # Look at:
    #    echo $(echo "ab   cd")  ->  "ab cd"
    # We are in this case with < eval $(angel-PS1) > (without quotes)
    # so we replace consecutive spaces by an alternate representation
    $PS1 =~ s/  /'\\ \\ '/g;
    $PS1 = "'$PS1'";
    $PS1 =~ s/'''/'/g;
    $PS1 =~ s/^''|[^ ]''$//gs;
    qq{[[ -n "\$APS1_NAME" ]] && \$APS1_NAME leave; [[ -n "\$prompt_theme" ]] && prompt off ; set -o promptpercent; set -o nopromptbang; set -o nopromptsubst; PS1=$PS1\n}
}

# Returns the code to send to the shell
sub shell_code_dynamic
{
    my ($class, %options) = @_;
    my ($DEBUG, $NAME, $IN, $OUT, $PID, $env) =
        @options{qw<debug name in out pid env>};

    my $shell_debug = $DEBUG->{'in'} ? q|printf 'DEBUG> PS1=%q\\n' "$PS1" ; | : '';
    my $argv = join(' ', map { (my $x=$_) =~ s/'/'\\''/g; qq<'$x'> } @AngelPS1::ARGV_BACKUP);

    # The shell code will be evaluated with eval as a single line
    # so statements must be properly terminated with ';'
    # No shell comments allowed
    # Consecutives raw spaces will be reduced to one
    <<EOF;
[[ -n "\$APS1_NAME" ]] && \$APS1_NAME leave;
APS1_PS1="\$PS1";
[[ -n "\$prompt_theme" ]] && { APS1_prompt="prompt '\$prompt_theme'"; prompt off; };
-angel-PS1()
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
add-zsh-hook precmd -angel-PS1 ;
APS1_NAME=$NAME ;
APS1_PID=$PID ;
$NAME()
{
    case "\$1" in
    reload)
        eval \$($0 $argv) ;;
    leave|quit|go-away)
        PS1="\$APS1_PS1" ;
        eval \$APS1_prompt ;
        kill \$APS1_PID 2>/dev/null ;
        rm -f -- '$IN' '$OUT' ;
        unset APS1_PS1 APS1_PID APS1_NAME APS1_prompt ;
        add-zsh-hook -d precmd -angel-PS1 ;
        add-zsh-hook -d zshexit -angel-PS1-exit ;
        unset -f -- $NAME -angel-PS1 -angel-PS1-exit ;;
    mute|off)
        add-zsh-hook -d precmd -angel-PS1 ;
        PS1="\$APS1_PS1" ;;
    unmute|on)
        add-zsh-hook precmd -angel-PS1 ;;
    *)
        echo 'usage: $NAME [reload|quit|mute|off|unmute|on]' >&2 ;
        return 1 ;;
    esac ;
} ;
-angel-PS1-exit() { $NAME leave ; } ;
add-zsh-hook zshexit -angel-PS1-exit ;
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

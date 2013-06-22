use strict;
use warnings;

package AngelPS1::Shell::tcsh;

sub ps1_escape
{
    # csh special symbols
    (my $s = $_[1]) =~ s{%}{%%}gs;
    # csh special sequences for special chars, à la bindkey
    $s =~ s{\\}{\\\\}gs;
    $s =~ s{\^}{\\136}gs;
    # csh special: history number
    $s =~ s{!}{\\041}gs;
    # \n must be escaped as tcsh replaces it with space in backquote (`) output
    $s =~ s{\n}{\\n}gs;
    #print STDERR "Escape [$_[1]] => [$s]\n";
    $s
}

sub ps1_invisible
{
    '%{' . $_[1] . '%}'
}

sub ps1_finalize
{
    my $prompt = $_[1];
    $prompt =~ s/'/'\\''/g;
    # tcsh replaces '\n' with a space in command substitution (backquotes: `)
    # so '\n' will be lost in our current implementation
    # TODO: try to replace with '\\n'
    warn "Prompt has '\\n' This is not supported by angel-PS1!" if $prompt =~ /\n/;
    qq{set prompt = '$prompt'};
}

sub shell_code
{
    my ($class, %options) = @_;
    my ($DEBUG, $NAME, $IN, $OUT, $env) = @options{qw<debug name in out env>};

    #my $time_debug = $DEBUG ? q|time -- | : '';

    # Reference for this csh shit:
    # - http://www.grymoire.com/Unix/CshTop10.txt
    # - http://www.faqs.org/faqs/unix-faq/shell/csh-whynot/

    my $shell_code = <<EOF;
if ( \${?aps1_name} ) then
    eval \$aps1_name leave
endif
set aps1_prompt = \$prompt:q
set aps1_precmd = 'if ( -p $IN ) then\\
    echo -n "?=\$?:q\\0PWD=\$PWD:q" > $IN\\
    eval "`cat $OUT`"\\
else\\
    $NAME leave\\
endif'
alias precmd 'eval \$aps1_precmd:q'
set aps1_angel = 'switch ( "\$aps1_arg" )\\
    case leave:\\
    case quit:\\
        set prompt = "\$aps1_prompt:q"\\
        kill \$aps1_pid\\
        rm -f -- $IN $OUT\\
        unset aps1_prompt aps1_pid aps1_name aps1_precmd aps1_angel aps1_arg\\
        unalias precmd $NAME\\
        breaksw\\
    case off:\\
    case mute:\\
        unalias precmd\\
        set prompt = \$aps1_prompt:q\\
        breaksw\\
    case on:\\
    case unmute:\\
        alias precmd \$aps1_precmd:q\\
        breaksw\\
    default:\\
        echo "$NAME: unknown option"\\
        echo "usage: $NAME [quit|mute|off|unmute|on]"\\
endsw'
alias $NAME 'set aps1_arg = \\!*; eval \$aps1_angel:q; :'
set aps1_name = '$NAME'
EOF
#alias $NAME-kill 'set prompt = \$aps1_prompt:q; kill \$aps1_pid >/dev/null; unset aps1_prompt aps1_pid aps1_name aps1_precmd aps1_angel aps1_arg; unalias precmd $NAME $NAME-kill; :'

    my $file = POSIX::tmpnam()."$$.csh";
    open my $f, '>', $file;
    print $f $shell_code;
    close $f;

    # Return value, passed as the eval argument
    # aps1_pid assignment will be concatenated
    #"cat $file; " . # For debugging
    "source $file; rm -f $file;"
}

sub WorkingDir
{
    \'%~'
}

sub UserPrivSymbol
{
    # The 'promptchars' variable defines exactly what will be displayed
    \'%#'
}

'$';
# vim:set et ts=8 sw=4 sts=4:

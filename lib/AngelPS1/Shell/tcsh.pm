use strict;
use warnings;

package AngelPS1::Shell::tcsh;

sub ps1_escape
{
    (my $s = $_[1]) =~ s{%}{%%}gs;
    $s =~ s/!/%\${_excl}/gs;
    $s
}

sub ps1_invisible
{
    '%{' . $_[1] . '%}'
}

sub ps1_finalize
{
    my $prompt = $_[1];
    $prompt
}

sub shell_code
{
    my ($class, %options) = @_;
    my ($DEBUG, $NAME, $IN, $OUT, $env) = @options{qw<debug name in out env>};

    #my $time_debug = $DEBUG ? q|time -- | : '';

    # Reference for this csh shit:
    # - http://www.grymoire.com/Unix/CshTop10.txt
    # - http://www.faqs.org/faqs/unix-faq/shell/csh-whynot/

    my $shell_code =
    <<EOF;
if ( \${?aps1_name} ) then
    \$aps1_name leave
endif
set aps1_prompt = "\$prompt"
set _excl = !
alias x 'eval "echo OK\\\\
echo B"'

echo A
set precmd1 = 'echo OK\\\\\\
if ( ! -e $IN ) then\\
    $NAME leave\\
else\\
    # This is not finished
    echo \\\?=\\\$?\\\\\\0PWD=\\\$PWD\\
endif'
echo B
#alias precmd1 'eval \$precmd1:q"
set aps1_name = '$NAME'
alias $NAME 'set prompt = "\$aps1_prompt"; kill \$aps1_pid; unalias precmd $NAME'
EOF
    #echo \\\?=\\\$?\\\\\\0PWD=\\\$PWD\\\\
    #echo -n \\\\"?=\\\$?\\0PWD=\\\$PWD\\\\" | od -c # > $IN || $NAME leave\\\\
    #set prompt = \\\\"`cat $OUT`\\\\"\\\\
    #echo "'\\"'"\\\\

# TODO inject this as an alias '$NAME'
our $z = <<EOF;
    switch (\\!:1)
    case leave:
    case quit:
    case go-away:
        set prompt = "\$aps1_prompt"
        kill \$aps1_pid
        rm -f -- '$IN' '$OUT'
        unset aps1_prompt aps1_pid aps1_name
        unalias $NAME precmd
        breaksw
    default:
        echo 'usage: $NAME [quit|mute|off|unmute|on]'
    endsw ;
} ;
EOF

    my $file = POSIX::tmpnam()."$$.csh";
    open my $f, '>', $file;
    print $f $shell_code;
    close $f;

    # Return value, passed as the eval argument
    # aps1_pid assignment will be concatenated
    "cat $file; " . # For debugging
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

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
    shift; # $class
    (\'%{', @_, \'%}')
}

sub ps1_finalize
{
    my $prompt = $_[1];
    $prompt =~ s/'/'\\''/g;
    # tcsh replaces '\n' with a space in command substitution (backquotes: `)
    # so '\n' will be lost in our current implementation
    # TODO: try to replace with '\\n'
    warn "Prompt has '\\n' This is not supported by angel-PS1!" if $prompt =~ /\n/;
    qq{'$prompt'};
}

sub shell_code_dynamic
{
    my ($class, %options) = @_;
    my ($DEBUG, $NAME, $IN, $OUT, $PID, $env) =
        @options{qw<debug name in out pid env>};

    # Reference for this csh shit:
    # - http://www.grymoire.com/Unix/CshTop10.txt
    # - http://www.faqs.org/faqs/unix-faq/shell/csh-whynot/

    # Note that because of bug http://bugs.gw.com/view.php?id=259
    # we can not use if/else/endif in aps1_precmd because that
    # pollutes the history, so we can't do check of existence of
    # $IN (see previous implementation in the history)

    my $shell_code = <<'EOF';
if ( ${?aps1_name} ) then
    eval $aps1_name leave
endif
set aps1_prompt = $prompt:q
set aps1_precmd = 'set aps1_err = $?\
if ( -p ##IN## ) then\
    echo -n "?=$aps1_err:q##1##PWD=$PWD:q" > ##IN##\
    eval "set prompt = `cat ##OUT##`"\
endif'
alias precmd 'eval $aps1_precmd:q'
alias ##NAME## 'switch ( \!* )\
    case leave:\
    case quit:\
        set prompt = "$aps1_prompt:q"\
        kill $aps1_pid\
        rm -f -- ##IN## ##OUT##\
        unset aps1_prompt aps1_pid aps1_name aps1_precmd\
        unalias precmd ##NAME##\
        breaksw\
    case off:\
    case mute:\
        unalias precmd\
        set prompt = $aps1_prompt:q\
        breaksw\
    case on:\
    case unmute:\
        alias precmd '\''eval $aps1_precmd:q'\''\
        :\
        breaksw\
    default:\
        echo "##NAME##: unknown option"\
        echo "usage: ##NAME## [quit|mute|off|unmute|on]"\
        breaksw\
endsw'
set aps1_name = '##NAME##'
set aps1_pid = '##PID##'
EOF

    $shell_code =~ s/##1##/\001/g; # Separator for the environment line
    $shell_code =~ s/##IN##/$IN/g;
    $shell_code =~ s/##OUT##/$OUT/g;
    $shell_code =~ s/##NAME##/$NAME/g;
    $shell_code =~ s/##PID##/$PID/g;
# For debugging
#alias $NAME-kill 'set prompt = \$aps1_prompt:q; kill \$aps1_pid >/dev/null; unset aps1_prompt aps1_pid aps1_name aps1_precmd; unalias precmd $NAME $NAME-kill; :'

    # Inside backquotes (`) output \n are replaced with spaces by tcsh
    # So switch/if can not work.
    # Workaround: save the shell code to a file, and source it.
    require File::Temp;
    my $file = File::Temp::tmpnam()."$$.tcsh";
    # TODO encoding, as the angel name may not be ascii
    open my $f, '>', $file;
    print $f $shell_code;
    close $f;

    # Return value, passed as the eval argument
    # aps1_pid assignment will be concatenated
    #"cat $file; " . # For debugging
    "source $file; rm -f $file"
}

sub WorkingDir
{
    \'%/'
}

sub WorkingDir_Tilde
{
    \'%~'
}

sub Hostname
{
    \'%h'
}

sub UserPrivSymbol
{
    # The 'promptchars' variable defines exactly what will be displayed
    \'%#'
}

'$';
# vim:set et ts=8 sw=4 sts=4:

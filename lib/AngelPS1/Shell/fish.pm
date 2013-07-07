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
function fish_prompt;
    set _err \$status;
    if test ! -e '$IN'; $NAME leave; fish_prompt; return; end;
    printf '%s\\0%s' "?=\$_err" "PWD=\$PWD" > '$IN';
    cat '$OUT';
end;
function $NAME;
    switch "\$argv[1]";
    case quit;
        $NAME leave;
    case leave;
        kill \$APS1_PID 2>/dev/null;
        rm -f -- '$IN';
        set -e -g APS1_PID;
        set -e -g APS1_NAME;
        functions -e fish_prompt $NAME;
    case '*';
        echo 'usage: $NAME [quit]' >&2;
        return 1;
    end;
end;
complete -c $NAME -a 'quit leave';
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

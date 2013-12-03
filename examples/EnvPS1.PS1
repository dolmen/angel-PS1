#!perl

# bash-style prompt definition using emulation by Env::PS1
#
# *** This is not a pratical example. Skip this if you are just discovering
# angel-PS1. This example is in the category "you can do crazy things with
# angel-PS1, but that doesn't mean you should".

use strict;
use warnings;

use Env::PS1;


# Note that Env::PS1 just ignores \[ and \] so you'll not get result as good as
# when using the AngelPS1 compiler natively.

tie my $prompt, Env::PS1::,
    \'\C{blue}\t\C{reset} \u@\h:\w\C{white}\$\C{reset} ';

(
    sub {
	$ENV{PWD} = shift->{PWD};
	"$prompt"
    }
)
__END__

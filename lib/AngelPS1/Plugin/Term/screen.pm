
use strict;
use warnings;

package AngelPS1::Plugin::Term::screen;

our $VERSION = $AngelPS1::VERSION;

use Exporter 5.57 ();
our @ISA = 'Exporter';
our @EXPORT = qw(ScreenTitle);

use AngelPS1::Shell;

sub ScreenTitle
{
    return if $ENV{'TERM'} ne 'screen'
        || exists $ENV{'TMUX'}
        || !exists $ENV{'TERMCAP'};

    AngelPS1::Shell->ps1_invisible(
	"\ek",
	@_,
	"\e\\"
    )
}

# TODO add support for the 'search|name' feature of screen
# See "TITLES" section in screen(1)


'$';
# vim:set et ts=8 sw=4 sts=4:

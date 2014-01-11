
use strict;
use warnings;

package AngelPS1::Plugin::Term::tmux;

our $VERSION = $AngelPS1::VERSION;

use Exporter 5.57 ();
our @ISA = 'Exporter';
our @EXPORT = qw(TmuxWindow TmuxTitle);

use AngelPS1::Shell;

# This requires the 'allow-rename' option to be enabled
sub TmuxWindow
{
    return if !exists $ENV{'TMUX'}
        || $ENV{'TERM'} ne 'screen';

    AngelPS1::Shell->ps1_invisible(
	"\ek",
	@_,
	"\e\\"
    )
}

sub TmuxTitle
{
    return if !exists $ENV{'TMUX'}
        || $ENV{'TERM'} ne 'screen';

    AngelPS1::Shell->ps1_invisible(
	"\e]2;",
	@_,
	"\e\\"
    )
}

'$';
# vim:set et ts=8 sw=4 sts=4:

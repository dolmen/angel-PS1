use strict;
use warnings;

package AngelPS1::Prompt::Default;

use AngelPS1::Shell ();
use AngelPS1::Color;
use AngelPS1::Plugin::Core;
use AngelPS1::Plugin::TerminalSize;
use AngelPS1::Plugin::Git;

use POSIX ();

(my $TTYNAME = POSIX::ttyname(0)) =~ s{^/dev/}{};

return () unless AngelPS1::Shell->can('WorkingDir')
              && AngelPS1::Shell->can('UserPrivSymbol');

# The prompt is the list returned as the last statement
(
    (AngelPS1::Shell->name, ' ') x!! $AngelPS1::DEBUG,
    [ $BLUE ],
    sub { sprintf('%3$02d:%2$02d:%1$02d', localtime) },
    ' ',
    $TTYNAME,
    (sub { "(${COLUMNS}x${LINES})" }) x!! $AngelPS1::DEBUG,
    ' ',
    sub { ((-w $_[0]->{PWD} ? [ $GREEN ] : [ $RED ]), ':') },
    AngelPS1::Shell->WorkingDir,
    ' ',
    GitInfo,
    sub { my $err = $_[0]->{'?'}; $err == 0 ? () : ([ $RED ], $err, ' ') },
    # User mark: root => #    else  $
    ($< ? ([ $BOLD ], AngelPS1::Shell->UserPrivSymbol) : ([ "$BOLD$RED" ], '#')),
    ' ',
)
# vim:set et ts=8 sw=4 sts=4:

use strict;
use warnings;

package AngelPS1::Prompt::Default;

use AngelPS1::Shell ();
use AngelPS1::Color;
use AngelPS1::Plugin::Core;
use AngelPS1::Plugin::DateTime;
use AngelPS1::Plugin::Term;
use AngelPS1::Plugin::Term::Size;
use AngelPS1::Plugin::Git;

use POSIX ();

(my $TTYNAME = POSIX::ttyname(0)) =~ s{^/dev/}{};

return () unless AngelPS1::Shell->can('WorkingDir')
              && AngelPS1::Shell->can('UserPrivSymbol');

# The prompt is the list returned as the last statement
(
    TermTitle(
        (
            AngelPS1::Shell->name,
            ' (',
            # Columns and lines are dynamic!
            sub { "${COLUMNS}x${LINES}) " },
        ) x!! %AngelPS1::DEBUG,
        AngelPS1::Shell->WorkingDir,
    ),
    [ $BLUE ], Time,
    ' ',
    $TTYNAME,
    ' ',
    # User name
    $< ? (scalar getpwuid $<) : (),
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

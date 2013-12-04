use strict;
use warnings;

package AngelPS1::Prompt::Default;

use AngelPS1::Shell ();
use AngelPS1::Chrome;
use AngelPS1::Plugin::Core;
use AngelPS1::Plugin::DateTime;
use AngelPS1::Plugin::Term;
use AngelPS1::Plugin::Term::Size;
use AngelPS1::Plugin::Git;

use POSIX ();

(my $TTYNAME = POSIX::ttyname(0)) =~ s{^/dev/}{};

return () unless AngelPS1::Shell->can('WorkingDir_Tilde')
              && AngelPS1::Shell->can('UserPrivSymbol');

# The prompt is the list returned as the last statement
(
    (
        AngelPS1::Shell->name eq 'fish'
        ? ()
        : TermTitle(
            (%AngelPS1::DEBUG
            ? (
                AngelPS1::Shell->name,
                ' ',
                $TTYNAME,
                ' (',
                # Columns and lines are dynamic!
                sub { "${COLUMNS}x${LINES}) " },
            ) : ()),
            AngelPS1::Shell->WorkingDir_Tilde,
        )
    ),
    # fish has its own special handling through the fish_title function
    Blue, [ Time ],
    ' ',
    # User name
    $< ? (scalar getpwuid $<) : (),
    sub { ((-w $_[0]->{PWD} ? Green : Red), [ ':' ]) },
    AngelPS1::Shell->WorkingDir_Tilde,
    ' ',
    GitInfo,
    sub { my $err = $_[0]->{'?'}; $err == 0 ? () : (Red, [ $err ], ' ') },
    # User mark: root => #    else  $
    ($< ? (Bold, [ AngelPS1::Shell->UserPrivSymbol ]) : (Red + Bold, [ '#' ])),
    ' ',
)
# vim:set et ts=8 sw=4 sts=4:

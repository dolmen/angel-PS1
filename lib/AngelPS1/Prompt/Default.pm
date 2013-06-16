use strict;
use warnings;

package AngelPS1::Prompt::Default;

use AngelPS1::Color;
use AngelPS1::Plugin::Core;
use AngelPS1::Plugin::TerminalSize;
use AngelPS1::Plugin::Git;

use POSIX ();

(my $TTYNAME = POSIX::ttyname(0)) =~ s{^/dev/}{};

# The prompt is the list returned as the last statement
(
    [ $BLUE ],
    sub { sprintf('%3$02d:%2$02d:%1$02d', localtime) },
    ' ',
    $TTYNAME,
    (sub { "(${COLUMNS}x${LINES})" }) x!! $AngelPS1::DEBUG,
    ' ',
    sub { ((-w $_[0]->{PWD} ? [ $GREEN ] : [ $RED ]), ':') },
    \'\\w',
    ' ',
    GitInfo,
    sub { my $err = $_[0]->{'?'}; $err == 0 ? () : ([ $RED ], $err, ' ') },
    # User mark: root => #    else  $
    ($< ? ([ $BOLD ], \'\\$') : ([ "$BOLD$RED" ], '#')),
    ' ',
)
# vim:set et ts=8 sw=4 sts=4:

use strict;
use warnings;

package AngelPS1::Prompt::Default;

use AngelPS1;
use AngelPS1::Shell qw< WorkingDir_Tilde UserPrivSymbol >;
use AngelPS1::Chrome;
use AngelPS1::Plugin::Layout 'MarginRight';
use AngelPS1::Plugin::DateTime;
use AngelPS1::Plugin::Term;
use AngelPS1::Plugin::Term::Size;
use AngelPS1::Plugin::VCS;
use AngelPS1::Plugin::Battery 'BatteryGauge';
use AngelPS1::Plugin::LoadAvg 'LoadAvgPercent';
use AngelPS1::Plugin::Jobs 'Jobs';

use POSIX ();

return () unless AngelPS1::Shell->can('WorkingDir_Tilde')
              && AngelPS1::Shell->can('UserPrivSymbol');

# The prompt is the list returned as the last statement
(
    (
        # fish has its own special handling through the fish_title function
        AngelPS1::Shell->name eq 'fish'
        ? ()
        : TermTitle(
            (%AngelPS1::DEBUG
            ? (
                AngelPS1::Shell->name,
                ' ',
                $AngelPS1::TTYNAME,
                ' (',
                # Columns and lines are dynamic!
                sub { "${COLUMNS}x${LINES}) " },
            ) : ()),
            WorkingDir_Tilde,
        )
    ),

    # Disabled
    #Blue, [ Time ], ' ',

    MarginRight(' ', BatteryGauge),
    MarginRight(' ', LoadAvgPercent),
    MarginRight(' ', Jobs),

    # User name
    $< ? (scalar getpwuid $<) : (),
    sub { -w $_[0]->{PWD} ? Green : Red }, [ ':' ],
    WorkingDir_Tilde,
    ' ',
    MarginRight(VCSInfo),
    sub { my $err = $_[0]->{'?'}; $err == 0 ? () : (Red, [ $err ], ' ') },
    # User mark: root => #    else  $
    ($< ? (Bold, [ UserPrivSymbol ]) : (Red + Bold, [ '#' ])),
    ' ',
)
# vim:set et ts=8 sw=4 sts=4:

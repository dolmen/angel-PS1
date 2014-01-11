#!perl

use strict;
use warnings;

use AngelPS1::Chrome qw<Blue>;
use AngelPS1::Plugin::Term::tmux;
use AngelPS1::Plugin::Term::screen;


sub rand_text
{
    sprintf '%02d', rand 100
}

(
    TmuxTitle(    'TmuxTitle-', \&rand_text),
    TmuxWindow(  'TmuxWindow-', \&rand_text),
    ScreenTitle('ScreenTitle-', \&rand_text),
    Blue,
    [ AngelPS1::Shell->WorkingDir_Tilde ],
    ' ',
    AngelPS1::Shell->UserPrivSymbol,
    ' ',
)

#!perl
#
# A prompt split on 2 lines

use strict;
use warnings;

use AngelPS1::Chrome;

(
    Green, [ "Line1\n" ],
    Blue, [ AngelPS1::Shell->WorkingDir_Tilde ],
    AngelPS1::Shell->UserPrivSymbol, ' ',
)

#!perl
#
# A prompt split on 2 lines

use strict;
use warnings;

use AngelPS1::Chrome;

(
    Green, [ "Line1\n" ],
    Blue, [ AngelPS1::Shell->WorkingDir ],
    AngelPS1::Shell->UserPrivSymbol, ' ',
)

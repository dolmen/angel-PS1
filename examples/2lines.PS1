#!perl
#
# A prompt split on 2 lines

use strict;
use warnings;

use AngelPS1::Chrome;
use AngelPS1::Shell qw<WorkingDir_Tilde UserPrivSymbol>;

(
    Green, [ "Line1\n" ],
    Blue, [ WorkingDir_Tilde ],
    UserPrivSymbol, ' ',
)

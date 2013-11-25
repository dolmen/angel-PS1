#!perl

use strict;
use warnings;

use AngelPS1::Chrome qw<Blue>;

print STDERR "Loading ", __FILE__,"...\n";

(
    Blue,
    [ AngelPS1::Shell->WorkingDir ],
    ' ',
    AngelPS1::Shell->UserPrivSymbol,
    ' ',
)

use strict;
use warnings;

use AngelPS1::Color;

print STDERR "Loading ", __FILE__,"...\n";

(
    [ $BLUE ],
    AngelPS1::Shell->WorkingDir,
    ' ',
    AngelPS1::Shell->UserPrivSymbol,
    ' ',
)

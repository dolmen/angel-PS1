#!perl
#
# A prompt split on 2 lines

use strict;
use warnings;

use AngelPS1::Color;

(
    [ $GREEN ], "Line1\n",
    [ $BLUE ], AngelPS1::Shell->WorkingDir,
    AngelPS1::Shell->UserPrivSymbol, ' ',
)

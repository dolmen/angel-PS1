#!perl
#
# Basic bash example: same as PS1='\w\$ '
#
# It uses bash-specific sequences, bypassing the cross-shell portability
# features of angel-PS1.
# Note that this will build a purely static prompt (exactly the PS1 value
# above), so the prompt will have no angel cost at runtime.
#
# This example is useless in itself, but it may help you to understand how
# angel-PS1 prompt building works.

use AngelPS1::Chrome qw< Green >;

(
    \'\w',            # Same as AngelPS1::Shell->WorkingDir_Tilde if shell is bash
    Green, [ \'\$' ], # Same as AngelPS1::Shell->UserPrivSymbol
    ' ',
)

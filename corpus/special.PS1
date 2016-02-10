#!perl

use AngelPS1::Chrome;

# Test case for special chars: they must all be shown exactly as here.
#
# We try to use every combination of consecutive special chars that may be
# involved in the quoting in all our supported shells
#
# If there is a bug, the methods ps1_escape and ps1_finalize for the
# Angel::PS1::$SHELL have to be fixed.


# Spaces at the beginning and end are to see issues with communication
# between the shell stub and the angel
(
    '  ', # 2 spaces at the beginning
    Blue + Bold,
q<$$$(:)
`:`":"!!   ! x
'   tab{	} tab x 2 {		}
 %     ^        ^         ^             ^
\iii >,
    Reset,
    '$',
    '  ', # 2 spaces at the end
)

#!perl

use AngelPS1::Chrome;

# Test case for special chars: they must all be show as here
#
# We try to use every combination of consecutive special chars that may be
# involved in the quoting in all our supported shells

(
    Blue + Bold,
    # 2 spaces at the beginning
q<  $$$(:)
`:`":"!!   ! x
'   tab{	} tab x 2 {		}
 %     ^        ^         ^             ^
\iii >,
    Reset,
    '$  ', # 2 spaces at the end
)

#!perl

use AngelPS1::Chrome;

# Test case for special chars: they must all be show as here

(
    Blue + Bold,
    # 2 spaces at the beginning
q<  $$$(:)
`:`":"!!   ! x
' wwww
  z   z
\iii >,
    Reset,
    '$  ', # 2 spaces at the end
)

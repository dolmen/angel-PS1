use strict;
use warnings;

package AngelPS1::Chrome;

use Term::Chrome 1.011;

*EXPORT = *Term::Chrome::EXPORT;
*import = *Term::Chrome::import;

__END__

=head1 NAME

AngelPS1::Chrome - DSL for colors and other terminal chrome

=head1 SYNOPSIS

    use Term::Chrome qw<Red Blue Bold Reset color>;

=head1 DESCRIPTION

C<AngelPS1::Chrome> is now just an alias for L<Term::Chrome> which is available
on CPAN and embedded in AngelPS1.

=head1 AUTHOR

Olivier MenguE<eacute>, L<mailto:dolmen@cpan.org>

=cut
# vim:set et ts=8 sw=4 sts=4:

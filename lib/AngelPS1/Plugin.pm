use strict;
use warnings;

package AngelPS1::Plugin;

our $VERSION = $AngelPS1::VERSION;

use Exporter 5.57 'import';
our @EXPORT = qw(compact interp);

*compact = \&AngelPS1::compact;
*interp = \&AngelPS1::interp;

'$';
# vim:set et ts=8 sw=4 sts=4:

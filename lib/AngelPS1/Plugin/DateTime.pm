use strict;
use warnings;

package AngelPS1::Plugin::DateTime;

use Exporter 'import';
our @EXPORT = qw< Time StrFTime >;

sub Time ()
{
    # FIXME this does not take in account if the user changes $ENV{TZ} in the
    # shell
    # TODO provoke an angel reload in that case

    sub { sprintf('%3$02d:%2$02d:%1$02d', localtime) }
}

sub StrFTime ($)
{
    my $format = shift;

    require POSIX;
    sub { POSIX::strftime($format, localtime) }
}

'$'
# vim:set et ts=8 sw=4 sts=4:

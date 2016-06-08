use utf8;
use strict;
use warnings;

package AngelPS1::Plugin::DateTime;

use AngelPS1 ();

use Exporter 'import';
our @EXPORT_OK = qw< Time StrFTime Clock >;

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

# Unicode characters: "CLOCK FACE" family
# They are located in the codepages between:
#     U+1F550 (ONE OCLOCK) and U+1F55B (TWELVE OCLOCK), for the plain hours
#     U+1F55C (ONE-THIRTY) and U+1F567 (TWELVE-THIRTY), for the thirties
# Generated with:
# perl -C -E 'say join("", map {chr(0x1F550+$_)." ".chr(0x1F55C+$_)." "} 0..11)'
my $CLOCK_FACES = '🕐 🕜 🕑 🕝 🕒 🕞 🕓 🕟 🕔 🕠 🕕 🕡 🕖 🕢 🕗 🕣 🕘 🕤 🕙 🕥 🕚 🕦 🕛 🕧 ';

sub Clock
{
    return if ! AngelPS1::_str_allowed($CLOCK_FACES);

    sub {
        my ($min, $hour) = (localtime)[1,2];
        substr($CLOCK_FACES, 2*(($hour*60+$min-45)/30%24), 1)
    }
}

'$'
# vim:set et ts=8 sw=4 sts=4:

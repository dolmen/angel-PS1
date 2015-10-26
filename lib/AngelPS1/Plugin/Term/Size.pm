use strict;
use warnings;

package AngelPS1::Plugin::Term::Size;

our $VERSION = $AngelPS1::VERSION;

use Exporter 5.57 ();
our @ISA = 'Exporter';
our @EXPORT = qw($LINES $COLUMNS);

our ($LINES, $COLUMNS);

# Get the ioctl number
my $TIOCGWINSZ =
    # Shortcut static table
    {
        # $^O => ioctl TIOCGWINSZ constant
        linux => 0x5413,
    }->{$^O}
||
    # Fallback: get the constant from ioctl.ph
    eval {
        package AngelPS1::Plugin::Term::Size::ioctl;
        require 'sys/ioctl.ph';
        delete $INC{'sys/ioctl.ph'};
        \&TIOCGWINSZ
    };


my $_WINSZ = pack('S4');

sub _update_from_ioctl
{
    ioctl(STDERR, $TIOCGWINSZ, $_WINSZ);
    ($LINES, $COLUMNS) = unpack('S2', $_WINSZ);
}

my $TTYNAME;
sub _update_from_stty
{
    my $line = $^O eq 'linux'
        ? `stty -F "$TTYNAME" size`
        # darwin, *BSD have '-f', Solaris has neither
        : `stty size <"$TTYNAME"`;
    chomp($line);
    ($LINES, $COLUMNS) = split / /, $line;
}

# TODO If sys/ioctl.ph is not available, try:
# - Term::Size
# - Term::ReadKey
# - stty size
# - hardcoded value of TIOCGWINSZ based on $^O
# See also perlfaq8: How do I get the screen size?


sub import
{
    # Avoid multiple install due to multiple import from different packages
    unless ($SIG{WINCH}) {
        if (defined $TIOCGWINSZ) {
            # Terminal size change
            $SIG{WINCH} = \&_update_from_ioctl;
        } else {
            require POSIX;
            $TTYNAME = POSIX::ttyname(2); # STDERR
            $SIG{WINCH} = \&_update_from_stty;
        }

        # Fetch now
        $SIG{WINCH}->();
    }

    $_[0]->export_to_level(1, @_);
}

'$';
# vim:set et ts=8 sw=4 sts=4:

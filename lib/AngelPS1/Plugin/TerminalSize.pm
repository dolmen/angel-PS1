use strict;
use warnings;

package AngelPS1::Plugin::TerminalSize;

our $VERSION = $AngelPS1::VERSION;

use Exporter 5.57 ();
our @ISA = 'Exporter';
our @EXPORT = qw($LINES $COLUMNS);

our ($LINES, $COLUMNS);

my $_WINSZ = pack('S4');


sub _update_from_ioctl
{
    ioctl(STDERR, &TIOCGWINSZ, $_WINSZ);
    ($LINES, $COLUMNS) = unpack('S2', $_WINSZ);
}

my $TTYNAME;
sub _update_from_stty
{
    my $line = `stty -F $TTYNAME size`;
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
    unless (defined $SIG{WINCH}) {
        eval {
            # Delay loading of ioctl.ph until import time
            no strict 'refs';
            *TIOCGWINSZ = do {
                package AngelPS1::Plugin::TerminalSize::ioctl;
                require 'sys/ioctl.ph';
                \&TIOCGWINSZ
            };
            delete $INC{'sys/ioctl.ph'};
        };
        if ($@) {
            require POSIX;
            $TTYNAME = POSIX::ttyname(2); # STDERR
            $SIG{WINCH} = \&_update_from_stty;
        } else {
            # Terminal size change
            $SIG{WINCH} = \&_update_from_ioctl;
        }

        # Fetch now
        $SIG{WINCH}->();
    }

    $_[0]->export_to_level(1, @_);
}

'$';
# vim:set et ts=8 sw=4 sts=4:

#!perl
use utf8;
use strict;
use warnings;

use AngelPS1::Chrome;

use constant {
    # Separator characters
    # Powerline font support must have been installed in the X11 terminal
    # See https://powerline.readthedocs.org/en/latest/installation/linux.html#font-installation
    SEP_COLOR   => "\x{E0B0}",
    SEP_THIN    => "\x{E0B1}",

    USERNAME_BG  => color(31),
    USERNAME_FG  => color(231),
    PATH_BG      => color(240),
    PATH_FG      => color(250),
    SEPARATOR_FG => color(245),
    CWD_FG       => color(252),
};

return (
    USERNAME_FG / USERNAME_BG + Reset + Bold,
    ' ',
    $ENV{USER},
    ' ',
    USERNAME_BG / PATH_BG + Reset,
    SEP_COLOR,
    PATH_FG,
    # Display of the current path
    # '/' is replaced by SEP_THIN colored with FG_PWD_SEP
    # Each element of the path is colored with FG_PWD
    # The last element is colored with FG_PWD_LAST
    do {
        # Build invariants just once
        my $home_regexp = qr{^\Q$ENV{HOME}\E(?:/|$)};
        my $color_last = CWD_FG + Bold;

        sub {
            my $dir = shift->{PWD};
            my @cwd;
            # Below $HOME ?
            if ($dir =~ s{$home_regexp}{}s) {
                @cwd = ('~', split m!/!, $dir)
            } else {
                @cwd = split m!/!, $dir;
                $cwd[0] = '/';
            }
            my @sep = (SEPARATOR_FG, SEP_THIN, PATH_FG);
            my $last = pop @cwd;

            (
                ( map { (" $_ ", @sep) } @cwd ),
                $color_last, " $last "
            )
        }
    },
    PATH_BG + Reset,
    SEP_COLOR,
    Reset,
    ' ',
)
__END__

# vim:set et ts=8 sw=4 sts=4:

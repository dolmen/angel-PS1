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

    BG_USER     => color(31),
    FG_USER     => color(231),
    BG_PWD      => color(240),
    FG_PWD      => color(250),
    FG_PWD_SEP  => color(245),
    FG_PWD_LAST => color(252),
};

return (
    FG_USER / BG_USER + Reset + Bold,
    ' ',
    $ENV{USER},
    ' ',
    BG_USER / BG_PWD + Reset,
    SEP_COLOR,
    FG_PWD,
    # Display of the current path
    # '/' is replaced by SEP_THIN colored with FG_PWD_SEP
    # Each element of the path is colored with FG_PWD
    # The last element is colored with FG_PWD_LAST
    do {
        # Build the regexp just once
        my $home_regexp = qr{^\Q$ENV{HOME}\E(?:/|$)};
        my $color_last = FG_PWD_LAST + Bold;

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
            my @sep = (FG_PWD_SEP, SEP_THIN, FG_PWD);
            my $last = pop @cwd;

            (
                ( map { (" $_ ", @sep) } @cwd ),
                $color_last, " $last "
            )
        }
    },
    BG_PWD + Reset,
    SEP_COLOR,
    Reset,
    ' ',
)
__END__

# vim:set et ts=8 sw=4 sts=4:

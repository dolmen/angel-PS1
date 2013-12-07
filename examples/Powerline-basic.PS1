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
    BG_USER / BG_PWD + ResetFlags,
    SEP_COLOR,
    FG_PWD,
    sub {
        my $dir = shift->{PWD};
        my $home = $ENV{HOME};
        my @cwd;
        if ($dir eq '/') {
            @cwd = '/';
        } elsif ($dir =~ s{^$home(/|$)}{~$1}s) {
            @cwd = split m!/!, $dir
        } else {
            @cwd = ('/', split m!/!, substr($dir, 1))
        }
        my @sep = (FG_PWD_SEP, SEP_THIN, FG_PWD);
        my $last = pop @cwd;
        my @res;
        foreach my $p (@cwd) {
            push @res, " $p ", @sep;
        }
        push @res, (FG_PWD_LAST + Bold, " $last ");
        @res
    },
    BG_PWD + Reset + ResetFg,
    SEP_COLOR,
    Reset,
    ' ',
)
__END__

# vim:set et ts=8 sw=4 sts=4:

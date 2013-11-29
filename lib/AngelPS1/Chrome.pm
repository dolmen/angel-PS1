use strict;
use warnings;

package AngelPS1::Chrome;

# Pre-declare packages
{
    package # no index: private package
        AngelPS1::Chrome::Color;
    package # no index: private package
        AngelPS1::Chrome::Flags;
}

sub color ($)
{
    my $color = shift;
    die "invalid color" if ref $color;
    bless \$color, AngelPS1::Chrome::Color::
}


use Exporter 5.57 'import';  # perl 5.8.3

#our @EXPORT_OK;
#BEGIN { our @EXPORT_OK = ('color'); }

{
    my $mk_flag = sub { bless \(my $f = $_[0]), AngelPS1::Chrome::Flags:: };

    my %const = (
        Reset      => $mk_flag->(''),
        Standout   => $mk_flag->(7),
        Underline  => $mk_flag->(4),
        Reverse    => $mk_flag->(7),
        Blink      => $mk_flag->(5),
        Bold       => $mk_flag->(1),

        Black      => color 0,
        Red        => color 1,
        Green      => color 2,
        Yellow     => color 3,
        Blue       => color 4,
        Magenta    => color 5,
        Cyan       => color 6,
        White      => color 7,

        # Larry Wall's favorite color
        # The true 'chartreuse' color from X11 colors is #7fff00
        # The xterm-256 color #118 is near: #87ff00
        Chartreuse => color 118,
    );

    our @EXPORT = ('color', keys %const);

    if ($^V lt v5.16.0) {
        while (my ($name, $value) = each %const) {
            no strict 'refs';
            *$name = sub () { $value };
        }
    } else {
        require constant;
        constant->import(\%const);
    }
}

use Carp ();

our @CARP_NOT = qw<
    AngelPS1::Chrome::Color
    AngelPS1::Chrome::Flags
>;

# Private constructor for AngelPS1::Chrome objects. Lexical, so cross-packages.
# Arguments:
# - foreground color
# - background color
# - flags
my $Chrome = sub ($$$)
{
    my ($fg, $bg, $flags) = @_;

    Carp::croak 'invalid fg color'
        if defined($fg) && ref($fg) ne AngelPS1::Chrome::Color::;
    Carp::croak 'invalid bg color' . ${$bg}
        if defined($bg) && ref($bg) ne AngelPS1::Chrome::Color::;

    my @self = map { ref($_) ? ${$_} : undef } $fg, $bg;

    if (ref($flags)) {
        Carp::croak('invalid flag value: '.ref($flags))
            if ref($flags) ne AngelPS1::Chrome::Flags::;
        push @self, ${$flags};
    }

    bless \@self, __PACKAGE__
};

use overload
    '""' => 'term',
    '+'  => 'plus',
;

sub term
{
    my $self = shift;
    my ($fg, $bg, $flg) = @{$self}[0, 1];
    my $r = join(';', @{$self}[2 .. $#$self]);
    if (defined($fg) || defined($bg)) {
        $r .= ';' if $r;
        if (defined $fg) {
            $r .= $fg < 8 ? (30+$fg) : $fg < 16 ? "9$fg" : "38;5;$fg";
            $r .= ';' if defined $bg;
        }
        $r .= $bg < 8 ? (40+$bg) : $bg < 16 ? "10$bg" : "48;5;$bg" if defined $bg;
    }
    "\e[${r}m"
}

sub clone
{
    bless [ @{$_[0]} ], __PACKAGE__
}

sub plus
{
    my ($self, $other, $swap) = @_;

    if (ref($other) eq AngelPS1::Chrome::Color::) {
        $self->[1] = ${$other};
    } elsif (ref($other) eq AngelPS1::Chrome::Flags::) {
        push @$self, ${$other};
    }

    $self
}

package # no index: private package
    AngelPS1::Chrome::Color;

our @ISA = (AngelPS1::Chrome::);

use overload
    '""' => 'term',
    '/' => 'over',
    '+' => 'plus',
;

sub over
{
    $Chrome->($_[0], $_[1], undef)
}

sub plus
{
    $Chrome->($_[0], undef, $_[1])
}

sub term
{
    $Chrome->(shift, undef, undef)->term
}

package # no index: private package
    AngelPS1::Chrome::Flags;

our @ISA = (AngelPS1::Chrome::);

use overload
    '""' => 'term',
    '+' => 'plus',
;

sub plus
{
    my ($left, $right) = @_;

    $Chrome->(undef, undef, $left) + $right;
}

sub term
{
    $Chrome->(undef, undef, $_[0])->term
}

1;
# vim:set et ts=8 sw=4 sts=4:

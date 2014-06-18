use strict;
use warnings;

package AngelPS1::Chrome;

# Pre-declare packages
{
    package # no index: private package
        AngelPS1::Chrome::Color;
}

use Carp ();

our @CARP_NOT = qw<
    AngelPS1::Chrome::Color
>;

# Private constructor for AngelPS1::Chrome objects. Lexical, so cross-packages.
# Arguments:
# - class name
# - foreground color
# - background color
# - flags list
my $Chrome = sub (*$$;@)
{
    my ($class, @self) = @_;

    my $fg = $self[0];
    Carp::croak "invalid fg color $fg"
        if defined($fg) && ($fg < 0 || $fg > 255);
    my $bg = $self[1];
    Carp::croak "invalid bg color $bg"
        if defined($bg) && ($bg < 0 || $bg > 255);
    # TODO check flags

    bless \@self, $class
};


# Cache for color objects
my %COLOR_CACHE;

sub color ($)
{
    my $color = shift;
    die "invalid color" if ref $color;
    #return $Chrome->(AngelPS1::Chrome::Color::, $color, undef);
    $COLOR_CACHE{chr($color)} ||=
        $Chrome->(AngelPS1::Chrome::Color::, $color, undef);
}


use Exporter 5.57 'import';  # perl 5.8.3

#our @EXPORT_OK;
#BEGIN { our @EXPORT_OK = ('color'); }

{
    my $mk_flag = sub { $Chrome->(AngelPS1::Chrome::, undef, undef, $_[0]) };

    # This is a method
    sub flags
    {
        my $self = shift;
        return undef unless $#$self >= 2;
        $Chrome->(AngelPS1::Chrome::, undef, undef, @{$self}[2..$#$self])
    }

    my %const = (
        Reset      => $mk_flag->(''),
        ResetFg    => $mk_flag->(39),
        ResetBg    => $mk_flag->(49),
        ResetFlags => $mk_flag->(22),
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

use overload
    '""' => 'term',
    '+'  => 'plus',
    '${}' => 'deref',
;

sub term
{
    my $self = shift;
    my ($fg, $bg) = @{$self}[0, 1];
    my $r = join(';', @{$self}[2 .. $#$self]);
    if (defined($fg) || defined($bg)) {
        $r .= ';' if @$self > 2;
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

    die 'invalid value for +' unless $other->isa(__PACKAGE__);

    my @new = @$self;
    $new[0] = $other->[0] if defined $other->[0];
    $new[1] = $other->[1] if defined $other->[1];
    push @new, @{$other}[2 .. $#$other];

    bless \@new, __PACKAGE__
}

sub deref
{
    \("$_[0]")
}

sub fg
{
    my $c = $_[0]->[0];
    defined($c) ? color($c) : undef
}

sub bg
{
    my $c = $_[0]->[1];
    defined($c) ? color($c) : undef
}

package # no index: private package
    AngelPS1::Chrome::Color;

our @ISA = (AngelPS1::Chrome::);

use overload
    '/'   => 'over',
    # Even if overloading is set in the super class, we have to repeat it for old perls
    (
        $^V ge v5.18.0
        ? ()
        : (
            '""'  => \&AngelPS1::Chrome::term,
            '+'   => \&AngelPS1::Chrome::plus,
            '${}' => \&AngelPS1::Chrome::deref,
        )
    ),
;

sub over
{
    die 'invalid bg color for /' unless ref($_[1]) eq AngelPS1::Chrome::Color::;
    $Chrome->(AngelPS1::Chrome::, $_[0]->[0], $_[1]->[0])
}

1;
__END__

=head1 NAME

AngelPS1::Chrome - DSL for colors and other terminal chrome

=head1 SYNOPSIS

    use AngelPS1::Chrome qw<Red Blue Bold Reset color>;

    # Base color constant and attribute
    say Red, 'red text', Reset;

    # Composition, using operator overloading
    say Red/Blue+Bold, 'red on blue', Reset;

    # Extended xterm-256 colors
    say color(125) + Underline, 'Purple', Reset;

    # Define your own constants
    use constant Pink => color 213;

    # Use ${} around Chrome expression inside strings
    say "normal ${ Red+Bold } RED ${ +Reset } normal";

    # Extract components
    say( (Red/Blue)->bg, "blue text", (Green+Reset)->flags );

=head1 DESCRIPTION

C<AngelPS1::Chrome> is a domain-specific language (DSL) for terminal decoration
(colors and other attributes).

In the current implementation stringification to ANSI sequences for C<xterm>
and C<xterm-256> is hard-coded (which means it doesn't use the L<terminfo(5)>
database), but this gives optimized (short) strings.

Colors and attributes are exposed as objects that have overloading for
arithmetic operators.

=head1 EXPORTS

=head2 Functions

C<color(I<0-255>)>

Build a L<AngelPS1::Chrome> object with the given color number. You can use this
constructor to create your own set of color constants.

For example, C<color(0)> gives the same result as C<Black> (but not the same
object).

=head2 Colors

Each of these function return a Chrome object.

=over 4

=item *

C<Black>: C<color 0>

=item *

C<Red>: C<color 1>

=item *

C<Green>: C<color 2>

=item *

C<Yellow>: C<color 3>

=item *

C<Blue>: C<color 4>

=item *

C<Magenta>: C<color 5>

=item *

C<Cyan>: C<color 6>

=item *

C<White>: C<color 7>

=cut

# Secret: Chartreuse

=back

=head2 Decoration flags

The exact rendering of each flag is dependent on how the terminal implements
them. For example C<Underline> and C<Blink> may do nothing.

=over 4

=item *

C<Bold>

=item *

C<Underline>

=item *

C<Blink>

=item *

C<Reverse>

=back

=head2 Special flags

=over 4

=item *

C<Reset> : reset all colors and flags

=back

=head1 METHODS

Here are the methods on C<AngelPS1::Chrome> objects:

=over 4

=item C<fg>

Extract the Chrome object of just the foreground color. Maybe C<undef>.

=item C<bg>

Extract the Chrome object of the just background color. Maybe C<undef>.

=item C<flags>

Extract a Chrome object of just the decoration flags. Maybe C<undef>.

=back

=head1 OVERLOADED OPERATORS

=over 4

=item C</> (mnemonic: "over")

Conmbine a foreground color (on the left) with a background color.

=item C<+>

Add decoration flags (on the right) to colors (on the left).

=item C<""> (stringification)

Transform the object into a sting of ANSI sequences. This is
particularly useful to directly use a Chrome object in a double quoted string.

=item C<${}> (scalar dereference)

Same result as C<""> (stringification). This operator is overloaded because
it is convenient to interpolate Chrome expressions in double-quoted strings.

Example:

    say "normal ${ Red } red ${ Reset }";

=back

=head1 SEE ALSO

L<AngelPS1::Compiler>: the C<angel-PS1> compiler has special support for
C<AngelPS1::Chrome> values.

=head1 TRIVIA

Did you know that I<chartreuse> is one of the favorite color of Larry Wall?

=head1 AUTHOR

Olivier MenguE<eacute>, L<mailto:dolmen@cpan.org>

=cut
# vim:set et ts=8 sw=4 sts=4:

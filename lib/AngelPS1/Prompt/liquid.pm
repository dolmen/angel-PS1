use strict;
use warnings;

package AngelPS1::Prompt::liquid;

use AngelPS1::Chrome;
use AngelPS1::Plugin::Layout qw< MarginRight MarginLeft >;
use AngelPS1::Shell qw< WorkingDir_Tilde UserPrivSymbol >;

sub _shell_unquote ($)
{
    my $txt = shift;

    # This is a very simplistic implementation that
    # should be enough for liquidprompt configs
        $txt =~ s/^'(.*)'$/$1/
    or ($txt =~ s/^"(.*)"$/$1/ and $txt =~ s/\\./\\/g);

    $txt
}

my %COLOR_TRANSLATION = (
    BLACK       => Black,
    BOLD_GRAY   => Black + Bold,
    WHITE       => White,
    BOLD_WHITE  => White + Bold,
    RED         => Red,
    BOLD_RED    => Red + Bold,
    WARN_RED    => Black / Red,
    CRIT_RED    => White / Red + Bold,
    DANGER_RED  => Yellow / Red + Bold,
    GREEN       => Green,
    BOLD_GREEN  => Green + Bold,
    YELLOW      => Yellow,
    BOLD_YELLOW => Yellow + Bold,
    BLUE        => Blue,
    BOLD_BLUE   => Blue + Bold,
    PURPLE      => Magenta,
    PINK        => Magenta + Bold, # Not BOLD_PURPLE
    CYAN        => Cyan,
    BOLD_CYAN   => Cyan + Bold,
    # Special: not really colors
    NO_COL      => Reset,
    BOLD        => Bold,
);
my $COLORS_RE = join('|', keys %COLOR_TRANSLATION);


sub _translate_color ($)
{
    my $txt = _shell_unquote(shift);
    my $color;
    while ($txt =~ /\$($COLORS_RE|{($COLORS_RE)})/g) {
        my $c = $COLOR_TRANSLATION{$1} || $COLOR_TRANSLATION{$2};
        if (!defined $c) {
            warn "Unknown color ".($2 || $1)."\n";
        }
        $color = defined($color) ? ($color + $c) : $c;
    }
    $color
}

sub read_rc
{
    my $file = shift;
    open my $f, '<:encoding(UTF-8)', $file or die "Can't open $file: $!\n";
    my %conf =
        map { m/LP_([^= ]*)=(.*?)\s*(?:#.*)?$/
            ? do {
                my ($name, $value) = ($1, _shell_unquote $2);
                $value = _translate_color($value) if $name =~ /^COLOR_/;
                ($name => $value)
              }
            : ()
            }
        grep !/^\s*(?:#|$)/,
        <$f>;
    close $f;
    \%conf
}

my $conf = read_rc("$ENV{HOME}/.liquidpromptrc");
my $theme = read_rc("$ENV{HOME}/Code/liquidprompt/liquid.theme");

# LP_PS1 is set? Not supported!
warn "Ignoring LP_PS1" if length $conf->{PS1};

# Colormap is ignored: Load, Battery plugins have their own
delete $theme->{COLORMAP};


# Wrap with a color from the theme
sub Colored
{
    my $name = shift;
    if (@_ && defined $theme->{"COLOR_$name"}) {
        ($theme->{"COLOR_$name"}, [ @_ ])
    } else {
        @_
    }
}

if ($ENV{APS1_DEBUG_LIQUID}) {
    print STDERR "$_=$conf->{$_}\n"
        for sort keys %$conf;
    print STDERR "== Theme ===========================================\n";
    print STDERR "$_=".do{($theme->{$_} // '') =~ s/\e(\[.*m)/\e$1\\e$1\e[m/gr }."\n"
        for sort keys %$theme;
}

my @PS1_DEF = (
    PS1_PREFIX => '',
    TIME => sub {
        # TODO LP_TIME_ANALOG
        require AngelPS1::Plugin::DateTime;
        (Colored(TIME => AngelPS1::Plugin::DateTime::Time()), ' ')
    },
    BATT => sub {
        require AngelPS1::Plugin::Battery;
        MarginRight(AngelPS1::Plugin::Battery::BatteryGauge())
    },
    LOAD => sub {
        require AngelPS1::Plugin::LoadAvg;
        MarginRight(AngelPS1::Plugin::LoadAvg::LoadAvgPercent())
    },
    TEMP => sub {
        # TODO
        ()
    },
    JOBS => sub {
        require AngelPS1::Plugin::Jobs;
        MarginRight(AngelPS1::Plugin::Jobs::Jobs())
    },

    [
        $theme->{MARK_BRACKET_OPEN} // (),
        # User name
        $< ? (scalar getpwuid $<) : (),
        sub { -w $_[0]->{PWD} ? Green : Red }, [ ':' ],
        Colored(PATH => WorkingDir_Tilde),
        $theme->{MARK_BRACKET_CLOSE} // (),
        ' ',
    ],

    GIT => sub {
        require AngelPS1::Plugin::Git;
        MarginRight(AngelPS1::Plugin::Git::GitInfo())
    },

    [
        ($< ? Colored(MARK => UserPrivSymbol)
            : Colored(MARK_ROOT => '#' )),
        ' ',
    ],
);


my @PS1;
my $i=0;
while ($i < @PS1_DEF) {
    my $o = $PS1_DEF[$i];
    my $r = ref $o;
    if (!$r) {
        $i++;
        if ($conf->{"ENABLE_$o"}) {
            my $impl = $PS1_DEF[$i];
            if (!ref $impl) {
                push @PS1, $conf->{$o} // ''
            } else {
                push @PS1, eval { $impl->() };
                warn $@ if $@
            }
            #} else {
            #    warn "$o disabled";
        }
    } elsif ($r eq 'ARRAY') {
        push @PS1, @$o;
    }
    $i++
}
undef $!;
no warnings 'void';
( @PS1 )
__END__
# vim:set et ts=8 sw=4 sts=4:

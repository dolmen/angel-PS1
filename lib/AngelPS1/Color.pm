use strict;
use warnings;

package AngelPS1::Color;

use Exporter 'import';
our @EXPORT = (qw($BLACK $RED $GREEN $YELLOW $BLUE $MAGENTA $CYAN $GRAY),
               qw($NO_COLOR $BOLD));


sub terminfo ($;@); # Pre-declare for recursion

my %terminfo_cache;

sub terminfo ($;@)
{
    my ($capability, @args) = @_;
    if (ref $capability) {
        my $cap0 = $capability->[0];
        if (exists $terminfo_cache{"\0$cap0"}) {
            $capability = $terminfo_cache{"\0$cap0"}
        } else {
            for my $cap (@$capability) {
                my $res = terminfo $cap, @args;
                next if $res eq '';
                $terminfo_cache{"\0$cap0"} = $cap if $cap ne $cap0;
                return $res
            }
            return '';
        }
    }

    my $query = join("\0", $capability, @args);
    return $terminfo_cache{$query} if exists $terminfo_cache{$query};

    my $result = AngelPS1::run(tput => $capability, @args);

    # Cache the result
    $terminfo_cache{$query} = $result;

    $result
}

sub setaf ($) { terminfo [ qw(setaf AF) ], $_[0] }

our ($BLACK, $RED, $GREEN, $YELLOW, $BLUE, $MAGENTA, $CYAN, $GRAY) =
    map { setaf $_ } 0..7;
our $BOLD = terminfo [ qw(bold md) ];
our $NO_COLOR = terminfo [ qw(sgr0 me) ];

'$';
# vim:set et ts=8 sw=4 sts=4:

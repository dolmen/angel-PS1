use strict;
use warnings;

package AngelPS1::System::darwin;

sub nproc
{
    my $cpus = `sysctl -n hw.ncpu`;
    chomp $cpus;
    $cpus;
}

sub gen_loadavg
{
    sub {
        my $uptime = `uptime`;
        $uptime =~ /load averages: (?<up>\d+\.\d+) /;
        $+{up};
    }
}

# If batteries found, returns a closure that returns 2 values:
# - the battery level as a float between 0 and 1
# - a boolean; 1 if charging, else discharging
sub gen_fetch_battery
{
    my $no_batteries = split("\n", `pmset -g batt`) - 1;
    if ($no_batteries < 1) { return; }
    if ($no_batteries != 1) {
        warn "only one battery supported. Patch welcome!"
    }
    return sub {
        my @x = split("\t", `pmset -g batt`);
        my $bat = $x[1];

        $bat =~ /(?<o>\d+)/;
        my $level = $+{o} / 100;
        my $status = ($bat =~ / charging/ || 0);
        return ($level, $status);
    }
}

'$';
# vim:set et ts=8 sw=4 sts=4:

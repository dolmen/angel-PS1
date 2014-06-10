use strict;
use warnings;

package AngelPS1::System::linux;

sub nproc
{
    # Alternative: grep '^processor\t' /proc/cpuinfo

    my $nproc = `nproc`;
    return if $? < 0;
    return if $? & 127;
    chomp $nproc;
    $nproc
}

sub gen_loadavg
{
    sub {
        open my $proc_loadavg, '<', '/proc/loadavg' or die;
        my $loadavg = readline $proc_loadavg;
        substr($loadavg, index($loadavg, ' '), length $loadavg, '');
        $loadavg
    }
}

sub _slurp_line
{
    open my $f, '<', $_[0]
        or return;
    my $line = readline $f;
    chomp $line;
    $line
}

# If batteries found, returns a closure that returns 2 values:
# - the battery level as a float between 0 and 1
# - a boolean; 1 if charging, else discharging
sub gen_fetch_battery
{
    # List devices
    opendir my $power_devices, '/sys/class/power_supply'
        or return;
    my @batteries =
        map { "/sys/class/power_supply/$_" }
        grep { index($_, 'BAT') == 0 }
        readdir $power_devices;
    close $power_devices;
    return unless @batteries;
    if (@batteries != 1) {
        warn "only one battery supported. Patch welcome!"
    }
    my $bat = shift @batteries;

    # Sub that will query the battery status
    if (-f "$bat/capacity") {
        return sub {
            defined(my $capacity = _slurp_line "$bat/capacity") or return;
            defined(my $status = _slurp_line "$bat/status") or return;
            # 'Charging', 'Discharging', 'Full'
            return ($capacity / 100, $status ne 'Discharging');
        }
    }
    return sub {
        defined(my $charge_full = _slurp_line "$bat/charge_full") or return;
        defined(my $charge_now = _slurp_line "$bat/charge_now") or return;
        defined(my $status = _slurp_line "$bat/status") or return;
        # 'Charging', 'Discharging', 'Full'
        return ($charge_now / $charge_full, $status ne 'Discharging');
    }
}

'$';
# vim:set et ts=8 sw=4 sts=4:

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

# This sub is called by AngelPS1::System::gen_count_jobs
#
# Returns a sub that will return a list of:
# - count of suspended childs of the shell
# - count of background childs of the shell
# TODO count detached screen/tmux sessions
sub _gen_count_jobs {
    my $PPID = shift;

    return unless -r "/proc/$PPID/stat";

    sub {
        opendir my $proc_dir, '/proc' or die "/proc: $!";

        my ($suspended, $background) = (0, 0);

        for my $pid ((readdir $proc_dir)) {
            next if $pid !~ /^[1-9]/;
            # Skip ourself
            next if $pid == $$;
            -r "/proc/$pid/stat" or next;
            open my $f, '<:raw', "/proc/$pid/stat" or next;
            # TODO rewrite read with sysread
            # FIXME read the whole file not just the first line
            # because $comm may contain "\n"
            my $stat = <$f>;
            close $f;
            my ($comm, $state, $ppid, $pgrp, $sid) = $stat =~ /\((.*)\) (.) (-?[0-9]+) (-?[0-9]+) (-?[0-9]+) / or die $stat;
            # Only childs of the shell
            next if $ppid ne $PPID;
            #printf "# %5d %5d %5d %5d %s %s\n", $pid, $ppid, $pgrp, $sid, $state, $comm;
            die $stat unless defined $pgrp;
            # Only process group leaders
            next if $pgrp ne $pid;
            if ($state eq 'T') {
                $suspended++
            } else {
                $background++;
            }
            #printf "%4d %s %s\n", $pid, $state, $comm;
        }

        close $proc_dir;

        return ($suspended, $background)
    }
}



'$';
# vim:set et ts=8 sw=4 sts=4:

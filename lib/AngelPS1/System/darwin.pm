use strict;
use warnings;

package AngelPS1::System::darwin;

sub nproc
{
    chomp(my $ncpu = `sysctl -n hw.ncpu`);
    $ncpu
}

sub gen_loadavg
{
    # For testing:
    # perl -Ilib -MAngelPS1::System::darwin -E 'say AngelPS1::System::darwin::gen_loadavg->()'
    sub {
        my $uptime = `LANG=C sysctl vm.loadavg`;
        $uptime =~ /vm.loadavg: \{ ([0-9]+\.[0-9]+) /;
        $1
    }
}

# If batteries found, returns a closure that returns 2 values:
# - the battery level as a float between 0 and 1
# - a boolean; 1 if charging, else discharging
#
# For testing:
#    perl -Ilib -MAngelPS1::System -E 'say for (AngelPS1::System->gen_fetch_battery // exit)->()'
sub gen_fetch_battery
{
    # Count lines of pmset -g batt
    my $lines_count =( )= `pmset -g batt`;
    return if $?;

    # "Now drawing from 'AC Power'" and no battery info
    return if $lines_count == 1;

    # FIXME handle "Battery Warning: Early"
    if ($lines_count > 2) {
        warn "only one battery supported. Patch welcome!"
    }

    return sub {
        my $pmset_batt = `pmset -g batt`;

        # 100%; charged;
        # 37%; AC attached; not charging
        # 8%; charging; 2:46 remaining
        # 9%; discharging; (no estimate)
        # 7%; discharging; 0:13 remaining
        $pmset_batt =~ m/\t([0-9]+)%;.* (dis)?charg(ing|ed)/;
        my $level = $1 / 100;
        my $charging = ! defined $2;
        return ($level, $charging);
    }
}

'$';
# vim:set et ts=8 sw=4 sts=4:

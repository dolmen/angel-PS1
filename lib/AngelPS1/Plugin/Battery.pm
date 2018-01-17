
use utf8;
use strict;
use warnings;

package AngelPS1::Plugin::Battery;

our $VERSION = $AngelPS1::VERSION;

use Exporter 5.57 'import';
our @EXPORT = qw<BatteryPercent BatteryGauge>;

use AngelPS1::Shell;
use AngelPS1::System;
use AngelPS1::Chrome qw<Red Green Blue Bold color>;

# Globals (to allow override)
our $SYMBOL_CHARGING = '⏚';
our $SYMBOL_DISCHARGING = '⌁';
# Fix rendering issue in iTerm: add space after those special chars
if ($^O eq 'darwin' && $ENV{'TERM_PROGRAM'} eq 'iTerm.app') {
    $_ .= ' ' for $SYMBOL_CHARGING, $SYMBOL_DISCHARGING;
}


sub BatteryPercent
{
    my $fetch_battery_gen = AngelPS1::System->can('gen_fetch_battery')
	or return;
    my $fetch_battery = $fetch_battery_gen->()
        or return;

    return sub {
	my @status = $fetch_battery->();
	return if !@status || $status[0] >= 0.80;
	(
	    (
		$status[0] > 0.20
		? Green
		: Red
	    ),
	    [
		sprintf '%s%d',
		    ($status[1] ? $SYMBOL_CHARGING
				: $SYMBOL_DISCHARGING),
		    100 * $status[0]
	    ]
	)
    }
}

use constant {
    SYMBOL_CHARGING         => Blue + Bold,
    SYMBOL_DISCHARGING_HIGH => Green,
    SYMBOL_DISCHARGING_LOW  => Red,
    GAUGE_DISCHARGING_HIGH  => color(22) / color(235),  # Dark green over dark gray
    GAUGE_DISCHARGING_LOW   => color(22) / color(124),  # Dark green over dark red
    GAUGE_CHARGING_HIGH     => Blue / color(235) + Bold,  # Light blue over dark red
    GAUGE_CHARGING_LOW      => Blue / color(124) + Bold,  # Light blue over dark red
};

sub BatteryGauge
{
    my $fetch_battery_gen = AngelPS1::System->can('gen_fetch_battery')
	or return;
    my $fetch_battery = $fetch_battery_gen->()
        or return;

    require AngelPS1::Plugin::Gauges;

    return sub {
	my @status = $fetch_battery->();
	return if !@status || $status[0] >= 0.80;
        my $charging = $status[1];
        #$charging = 1;
	my $high = $status[0] >= 0.3;
	(
	    ($charging ? (
                            SYMBOL_CHARGING, $SYMBOL_CHARGING,
                            $high ? GAUGE_CHARGING_HIGH : GAUGE_CHARGING_LOW,
                         )
		       : (
                            $high ? SYMBOL_DISCHARGING_HIGH : SYMBOL_DISCHARGING_LOW, $SYMBOL_DISCHARGING,
                            $high ? GAUGE_DISCHARGING_HIGH : GAUGE_DISCHARGING_LOW,
                         )
            ),
	    [
		&AngelPS1::Plugin::Gauges::CharGauge($status[0])
	    ],
	)
    }
}

'$';
# vim:set et ts=8 sw=4 sts=4:

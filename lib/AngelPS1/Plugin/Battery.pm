
use utf8;
use strict;
use warnings;

package AngelPS1::Plugin::Battery;

our $VERSION = $AngelPS1::VERSION;

use Exporter 5.57 'import';
our @EXPORT = qw<BatteryPercent BatteryGauge>;

use AngelPS1::Shell;
use AngelPS1::System;
use AngelPS1::Chrome qw<Red Green Bold color>;

# Globals (to allow override)
our $SYMBOL_CHARGING = '⏚';
our $SYMBOL_DISCHARGING = '⌁';

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
    SYMBOL_HIGH  => Green,
    SYMBOL_LOW   => Red,
    GAUGE_HIGH   => color(22) / color(235),  # Dark green over dark gray
    GAUGE_LOW    => color(22) / color(124),  # Dark green over dark red
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
	my $high = $status[0] >= 0.3;
	(
	    (
		$high
		? SYMBOL_HIGH
		: SYMBOL_LOW
	    ),
		($status[1] ? $SYMBOL_CHARGING
			    : $SYMBOL_DISCHARGING),
	    ($high ? GAUGE_HIGH : GAUGE_LOW),
	    [
		&AngelPS1::Plugin::Gauges::CharGauge($status[0])
	    ],
	)
    }
}

'$';
# vim:set et ts=8 sw=4 sts=4:

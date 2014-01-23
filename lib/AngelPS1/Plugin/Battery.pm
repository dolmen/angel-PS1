
use utf8;
use strict;
use warnings;

package AngelPS1::Plugin::Battery;

our $VERSION = $AngelPS1::VERSION;

use Exporter 5.57 'import';
our @EXPORT = qw(BatteryStatus);

use AngelPS1::Shell;
use AngelPS1::System;
use AngelPS1::Chrome qw<Red Green>;

sub BatteryStatus
{
    my $fetch_battery = AngelPS1::System->fetch_battery
	or return;

    return sub {
	my @status = $fetch_battery->();
	return unless @status;
	(
	    (
		$status[0] > 0.20
		? Green
		: Red
	    ),
	    [
		sprintf '%s%d',
		    ($status[1] eq 'charging' ? '⏚' : '⌁'),
		    100 * $status[0]
	    ]
	)
    }
}

'$';
# vim:set et ts=8 sw=4 sts=4:

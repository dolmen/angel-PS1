use utf8;
use strict;
use warnings;

package AngelPS1::Plugin::LoadAvg;

our $VERSION = $AngelPS1::VERSION;

use Exporter 5.57 'import';
our @EXPORT = qw<LoadAvgPercent>;

use AngelPS1;
use AngelPS1::Shell;
use AngelPS1::System;
use AngelPS1::Chrome qw<Red Green Bold color>;

# Globals (to allow override)
our $SYMBOL_LOADAVG = '⌂';
our $LOAD_THRESHOLD = 0.60;

sub LoadAvgPercent
{
    my $loadavg_gen = AngelPS1::System->can('gen_loadavg')
	or return;

    # Plugin disabled if the encoding doesn't support the symbol
    AngelPS1::_str_allowed($SYMBOL_LOADAVG) or return;

    my $loadavg_func = $loadavg_gen->();
    my $nproc = AngelPS1::System->nproc();

    return sub {
	my $loadavg = $loadavg_func->();
	return if !defined($loadavg);
	$loadavg /= $nproc;
	return if $loadavg < $LOAD_THRESHOLD;
	(
	    (
		$loadavg < 0.80
		? Green
		: Red
	    ),
	    [
		sprintf '%s%d',
		    $SYMBOL_LOADAVG,
		    100 * $loadavg,
	    ]
	)
    }
}

'$';
# vim:set et ts=8 sw=4 sts=4:

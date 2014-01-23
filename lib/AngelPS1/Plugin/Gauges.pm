
use utf8;
use strict;
use warnings;

package AngelPS1::Plugin::Gauges;

our $VERSION = $AngelPS1::VERSION;

use Exporter 5.57 'import';
our @EXPORT_OK = qw<
    CharGauge
    ColoredGauge
    StaticGauge
    DynamicGauge
>;


# First char is underscore for 0%
# TODO 100% as <space> in reverse video
use constant GAUGE_VALUES => '_▁▂▃▄▅▆▇█';
use constant GAUGE_COUNT => length(GAUGE_VALUES);


sub CharGauge ($)
{
    my $offset = int((shift)*GAUGE_COUNT);
    substr(GAUGE_VALUES, $offset, 1)
}

sub ColoredGauge ($$)
{
    my $gauge = CharGauge(pop);
    return @_, [ $gauge ];
}

sub StaticGauge ($;$)
{
    my $gauge = CharGauge(pop);
    return $gauge unless @_;
    return @_, [ $gauge ];
}

sub DynamicGauge ($;$)
{
    goto &StaticGauge if (!ref $_[$#_]);
    my $generator = pop;
    if (@_) {
        return (@_, [ sub { CharGauge($generator->()) } ])
    } else {
        return sub { CharGauge($generator->()) }
    }
}

'$';
# vim:set et ts=8 sw=4 sts=4:

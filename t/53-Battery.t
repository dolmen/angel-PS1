#
# Check the BatteryPercent and BatteryGauge
#
# The checks are only visual (humans must check output of 'note' statements)
# for now.
#
use strict;
use warnings;

use Test::More;
use Test::More::UTF8;

use lib 't/lib';

=cut
use Test::More;

use Term::Encoding 'term_encoding';
my $enc = term_encoding();
note $enc;  # Ensure that builder->output is opened
binmode($_, ":encoding($enc)")
    for Test::More->builder->output;

=cut

my @mock_battery = (1, 1);

{
    package AngelPS1::System::MockBattery;
    BEGIN { $INC{'AngelPS1/System/MockBattery.pm'} = __FILE__ }


    sub fetch_battery
    {
	return sub {
	    @mock_battery
	}
    }
}

use AngelPS1::Shell ();
use AngelPS1::System 'MockBattery';
use AngelPS1::Compiler ();
use AngelPS1::Plugin::Battery qw<BatteryPercent BatteryGauge>;

AngelPS1::Shell->use('Raw');

is(AngelPS1::System->name, 'MockBattery');
ok(AngelPS1::System->can('fetch_battery'));

my @PS1 = AngelPS1::Compiler::reduce(
    sub { sprintf ' (%.2f, %d) => ', @mock_battery },
    'BatteryPercent: ', BatteryPercent(),
    '  ',
    'BatteryGauge: ', BatteryGauge(),
);

is(scalar @PS1, 5);

sub show_battery
{
    my ($battery, $plugged) = @_;
    @mock_battery = ($battery, $plugged);

    note scalar AngelPS1::Compiler::reduce(AngelPS1::Compiler::expand({}, @PS1))
}

foreach my $charging (0, 1) {
    foreach my $percent (0..20) {
        show_battery($percent / 20, $charging);
    }
}


done_testing;

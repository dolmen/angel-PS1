use strict;
use warnings;

package AngelPS1::System::linux;

sub loadavg
{
    open my $proc_loadavg, '<', '/proc/loadavg' or die;
    my $loadavg = readline $proc_loadavg;
    substr($loadavg, index($loadavg, ' '), length $loadavg, '');
    $loadavg
}

'$';
# vim:set et ts=8 sw=4 sts=4:

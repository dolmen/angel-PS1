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

sub loadavg
{
    open my $proc_loadavg, '<', '/proc/loadavg' or die;
    my $loadavg = readline $proc_loadavg;
    substr($loadavg, index($loadavg, ' '), length $loadavg, '');
    $loadavg
}

'$';
# vim:set et ts=8 sw=4 sts=4:

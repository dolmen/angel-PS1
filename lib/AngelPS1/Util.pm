use strict;
use warnings;

package AngelPS1::Util;

use Exporter 'import';
our @EXPORT_OK = qw<which run one_line>;

use IPC::Open3 ();
use Symbol 'gensym';


{
    my @PATH;
    BEGIN { @PATH = split /:/, $ENV{'PATH'}; }
    my %which;

    sub which ($)
    {
        my ($name, $no_cache) = @_;

        # Use the cache
        return $which{$name} if exists $which{$name};
        # Already a path with a directory?
        return $name if index($name, '/') >= 0;

        # Search in $PATH
        foreach my $p (@PATH) {
            my $f = "$p/$name";
            if (-x $f && ! -d _) {
                $which{$name} = $f unless $no_cache;
                return $f;
            }
        }
        die "$name: not found";
    }
}

sub run
{
    my $command = which(shift);
    my ($in, $out);
    my $err = gensym;
    my $pid = IPC::Open3::open3(
        $in,
        $out,
        $err,
        $command,
        @_
    );
    my $result = do { local $/; readline $out };
    # TODO UTF-8 decoding
    waitpid($pid, 0);
    return $result
}

sub one_line
{
    # chop
    (my $result = shift) =~ s{\n$}{}s;
    $result
}

'$';
# vim:set et ts=8 sw=4 sts=4:

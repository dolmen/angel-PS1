use strict;
use warnings;

package AngelPS1::Plugin::VCS;

use Exporter 'import';
our @EXPORT = qw<VCSInfo>;

# cygwin has this issue: it doesn't emulate hard links count to directories
use constant NO_DIR_STAT => (stat '..')[3] < 3;

sub _find_vcs_dir
{
    my $dir = shift;
    return if $dir eq '/';
    my @stat = stat $dir;
    my $dev = $stat[0];
    # Look up while we are on the same filesystem
    while ($stat[0] == $dev) {
        if (NO_DIR_STAT || $stat[3] > 3) {
            return (git => $dir) if -d "$dir/.git/objects";
            return (svn => $dir) if -f "$dir/.svn/entries";
            return (hg  => $dir) if -d "$dir/.hg/store";
            return (bzr => $dir) if -d "$dir/.bzr";
            return ('git-bare' => $dir) if substr($dir, -4) eq '.git' && -d "$dir/objects"
        }
        # go up
        substr($dir, rindex($dir, '/'), length($dir), '');
        $dir or last;
        @stat = stat $dir;
    }
    return
}

my %VCS = (
    git => [
        'AngelPS1/Plugin/Git.pm',
        do {
            require AngelPS1::Plugin::Git;
            my @gitinfo = AngelPS1::Plugin::Git::GitInfo();

            sub {
                my ($state, $dir) = @_;
                return (
                    sub {
                        $state->{GIT_DIR} = $dir;
                        ()
                    },
                    @gitinfo,
                    sub {
                        delete $state->{GIT_DIR};
                        ()
                    },
                )
            }
        }
    ],
);

sub VCSInfo
{
    my $options = (@_ && ref($_[0]) eq 'HASH') ? (shift) : {};
    my @enabled_vcs = @_;

    sub {
        my $state = shift;
        my ($vcs, $dir) = _find_vcs_dir($state->{PWD});
        return unless defined $vcs;
        my $vcs_plugin = $VCS{$vcs};
        return unless defined $vcs_plugin;

        require $vcs_plugin->[0];
        return $vcs_plugin->[1]->($state, $dir)
    }
}

1;
__END__
# vim:set et ts=8 sw=4 sts=4:

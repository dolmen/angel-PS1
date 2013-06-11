use strict;
use warnings;

package AngelPS1::Plugin::Git;

use Exporter 5.57 'import';
BEGIN {
    our $VERSION = $AngelPS1::VERSION;
    our @EXPORT = qw(GitInfo);
}

use AngelPS1::Util qw< which run one_line >;
use AngelPS1::Color;

my $git = which 'git';
sub git
{
    # All Git commands we call return a single line. We don't want '\n'
    one_line(run $git, @_)
}

sub GitInfo
{
    my $shell_state = shift;

    my $git_dir = "$shell_state->{'PWD'}/.git";
    unless (-d $git_dir) {
        ($git_dir = git qw(rev-parse --git-dir))
            or return;
    }
    local $ENV{'GIT_DIR'} = $git_dir;

    my @out;
    my $local_commits = 0;

    my $branch = git 'symbolic-ref', 'HEAD';
    if ($branch eq '') {
        ($branch = git 'rev-parse', '--short')
            or return;
    } else {
        $branch =~ s{^refs/heads/}{};

        # Count the number of commits to push ($local_commits)
        if ((my $remote_branch = git qw(config --get), "branch.$branch.merge")
            && (my $remote = git qw(config --get), "branch.$branch.remote")) {

            # Compute the ref of our local image of the remote branch
            (my $remote_branch_ref = $remote_branch) =~ s{^refs/heads/}{refs/remotes/$remote/};

            # Count the commits
            $local_commits =
                git(qw(rev-list --no-merges --count),
                    "$remote_branch_ref..HEAD")
                || 0;
        }
    }

    my $status = git qw(status --porcelain -z);
    my $untracked = $status =~ /(?:^|\0)\?\? /s;

    if (my $shortstat = git qw(diff --shortstat)) {
        my ($ins) = ($shortstat =~ /([0-9]+) insertions?\(/);
        my ($del) = ($shortstat =~ /([0-9]+) deletions?\(/);

        push @out,
            \$RED, $branch, \$NO_COLOR,
            '(',
                \$MAGENTA,
                ($ins ? ("+$ins" . ($del ? "/" : '')) : '') . ($del ? "-$del" : ''),
                ($local_commits ? (\$NO_COLOR, ',', \$YELLOW, $local_commits) : ()),
                \$NO_COLOR,
            ')';
    } elsif ($local_commits) {
        push @out,
            \$YELLOW, $branch, \$NO_COLOR,
            '(', \$YELLOW, $local_commits, \$NO_COLOR, ')';
    } else {
        push @out, \$GREEN, $branch, \$NO_COLOR;
    }

    if (-f "$git_dir/refs/stash") {
        push @out, \$RED, '+', \$NO_COLOR;
    }

    if ($untracked) {
        push @out, \$RED, '*', \$NO_COLOR;
    }

    # TODO Git mark

    @out, ' '
}

'$';
# vim:set et ts=8 sw=4 sts=4:

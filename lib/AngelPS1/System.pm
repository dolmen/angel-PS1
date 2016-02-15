use strict;
use warnings;

package AngelPS1::System;

my %ALIASES = (
    cygwin => 'linux',
);

my $name;

sub name
{
    $name
}

sub use
{
    return if defined $name && @_ < 2;
    my ($class, $system) = @_;
    $system ||= $^O;

    $system = $ALIASES{$system} if exists $ALIASES{$system};
    my $src = "AngelPS1/System/$system.pm";
    require $src;
    our @ISA = ("${class}::$system");
    $name = $system;
}

*import = *use;


# Returns a sub that will return a list of:
# - count of suspended childs of the shell
# - count of background childs of the shell
# TODO count detached screen/tmux sessions
#
# Test manually with those commands:
#    sleep 30
#    kill -STOP %1
#    sudo sleep 30 &
#    sudo sleep 30
#    ^Z
#
# See t/41-count_jobs.t for the test suite
#
sub gen_count_jobs
{
    my $self = shift;
    require AngelPS1;
    my $PPID = shift || $AngelPS1::SHELL_PID;
    my $TTY  = shift || $AngelPS1::TTYNAME;

    # Try all implementations available on this system
    for my $gen_impl ($self->_count_jobs_impl) {
        # Call the generator to get an implementation
        my $sub = $self->$gen_impl($PPID, $TTY)
            or next;
        # Try it once
        my @result = $sub->();
        # Every check ok? We got the one!
        return $sub if @result;
    }

    # None works :(
    #warn "No count_jobs implementation!";
    undef
}

# Ordered list of the available implementations of the generators
# Returns a list of methods that can be called on AngelPS1::System
sub _count_jobs_impl
{
    my $self = shift;
    # _gen_count_jobs can be implemented by an OS specific module
    # _gen_count_jobs_ps is the default, portable (?) implementation
    map { $self->can($_) || () } qw< _gen_count_jobs _gen_count_jobs_ps >
}

# Implementation using ps:
#   ps -o pgid,pid,ppid,stat,cmd --sort pgid,ppid,pid
sub _gen_count_jobs_ps
{
    my (undef, $PPID, $ttyname) = @_;
    #die unless $PPID;
    #die unless $ttyname;

    # We use a ps filter to avoid processing the whole table ourself
    # The filter must not hide process owned by other users.
    # This is the trickiest part because ps flags are not portable.
    my @ps_filter;
    TRY: {
        #chomp(my $sid = `ps -o sid= $$`);
        for my $try (
            [ '--ppid' => $PPID ],  # select by ppid (Linux)
            [ -t => $ttyname ],   # select by tty  (BSD, Linux)
            #[ -g => $sid ],      # select by sid  (Linux)
        ) {
            #warn "ps @$try >/dev/null 2>&1";
            system("ps @$try >/dev/null 2>&1") >> 8
                and next;
            # Success
            @ps_filter = @$try;
            last TRY
        }
        # All tries failed :(
        return
    }

    my $regex = qr/^ *$PPID +([0-9]+) +(?:\1) +(.)/;
    sub {
        my ($suspended, $background) = (0, 0);

        $? = -1;
        open my $ps, "ps -o ppid= -o pgid= -o pid= -o stat= @ps_filter |"
            or return;
        # Check the return code if ever it is already finished
        return if $? >= 256;

        while (my $line = <$ps>) {
            #warn $_;
            next if $line !~ /$regex/ || $1 == $PPID;
            if ($2 eq 'T') {
                $suspended++;
            } else {
                $background++;
            }
        }
        close $ps;
        ($suspended, $background)
    }
}


'$';
# vim:set et ts=8 sw=4 sts=4:

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
sub gen_count_jobs
{
    my $self = shift;
    my $PPID = shift || $AngelPS1::SHELL_PID;

    for my $name (qw< _gen_count_jobs _gen_count_jobs_ps >) {
        my $gen_sub = $self->can($name) or next;
        # Call the generator to get an implementation
        my $sub = $self->$gen_sub($PPID) or next;
        # Try it once
        my @result = $sub->();
        # Every check ok? We got the one!
        return $sub if @result;
    }

    # None works :(
    undef
}

# TODO Implementation using ps:
#   ps -o pgid,pid,ppid,stat,cmd --sort pgid,ppid,pid
sub _gen_count_jobs_ps
{
    my $PPID = $_[1];
    #chomp(my $SID = `ps -o sid= $$`);
    my $regex = qr/^ *$PPID +([0-9]+) +(?:\1) +(.)/;
    sub {
        my ($suspended, $background) = (0, 0);

        # We use a ps filter to avoid processing the whole table ourself
        # The filter must not hide process owned by other users.
        # Test with those commands:
        #    sleep 30
        #    kill -STOP %1
        #    sudo sleep 30 &
        #    sudo sleep 30
        #    ^Z
        #
        # -g => select by sid
        #open my $ps, "ps -g $SID -o ppid= -o pgid= -o pid= -o stat=|"
        # --ppid => select by ppid
        $? = -1;
        open my $ps, "ps --ppid $PPID -o ppid= -o pgid= -o pid= -o stat=|"
            or return;
        # Check the return code if ever it is already finished
        return if $? >= 256;

        while (<$ps>) {
            #warn $_;
            next if !/$regex/ || $1 == $PPID;
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

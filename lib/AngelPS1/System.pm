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
        my $sub = $gen_sub->($PPID) or next;
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
}



'$';
# vim:set et ts=8 sw=4 sts=4:

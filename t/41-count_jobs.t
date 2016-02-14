use strict;
use warnings;

use Test::More;

use AngelPS1;
use AngelPS1::System;

use Sub::Util 1.40 ();   # subname
use List::Util ();       # shuffle
use Time::HiRes qw< gettimeofday tv_interval >;

sub test_count_jobs
{
    my ($test_name, $count_jobs, $expected) = @_;
    my $t0 = [gettimeofday];
    my @counts = $count_jobs->();
    my $elapsed = tv_interval($t0);

    is_deeply(\@counts, $expected, $test_name);
    note sprintf("      time: %.6f", $elapsed);
}

sub test_jobs
{
    my ($suspended, $background, @count_jobs) = @_;

    note "===============================================================================";
    note "Testing with $suspended suspended and $background background jobs...";

    my $total = $suspended + $background;

    subtest 'no jobs before starting' => sub {
	test_count_jobs($_->[0], $_->[1], [0, 0])
	    for @count_jobs;
    };

    note "Spawning jobs...";
    my (@in, @childs);
    for(my $i=0; $i<$total; $i++) {
	my $out;
	pipe($in[$#in+1], $out) or diag "pipe $i failed";
	my $child = fork;
	if ($child == 0) {
	    setpgrp 0, $$;  # This is what distinguish the process as a "job"
	    note "Child $$...\n";
	    print $out "$$\n"; close $out;
	    close $_ for @in;
	    sleep 5;
	    exit 0;
	}
	close $out;
	$child or diag "fork $i failed";
	push @childs, $child;
    }

    my @states = List::Util::shuffle(('T') x $suspended, ('?') x $background);

    while (my $in = shift @in) {
	chomp(my $child = <$in>);
	close $in;
	kill STOP => $child if 'T' eq shift(@states);
    }

    system("ps --ppid $$ -o ppid,pgid,pid,stat,comm");
    subtest "Suspended: $suspended, Background: $background" => sub {
	test_count_jobs($_->[0], $_->[1], [$suspended, $background])
	    for @count_jobs;
    };

    note "Killing jobs...";
    for (@childs) {
	kill CONT => $_;
	kill TERM => $_;
    }
    wait for @childs;

    subtest 'all childs cleaned' => sub {
	test_count_jobs($_->[0], $_->[1], [0, 0])
	    for @count_jobs;
    };
    note "-------------------------------------------------------------------------------";
}




AngelPS1::System->use;

my @gen_count_jobs_impl = AngelPS1::System->_count_jobs_impl;


cmp_ok(scalar @gen_count_jobs_impl, '>=', 1, 'Has available implementations');



my @count_jobs_impl;


my $selected_count_jobs = do {
    # For this test our process is the one controlling the jobs
    # while in AngelPS1, it is the parent process
    local $AngelPS1::SHELL_PID = $$;
    AngelPS1::System->gen_count_jobs()
};
if (ok($selected_count_jobs, "An implementation works")) {
    push @count_jobs_impl, [ "Selected impl" => $selected_count_jobs ];
}


for my $impl (@gen_count_jobs_impl) {

    my $impl_name = Sub::Util::subname($impl);

    # We will count jobs child or our process
    my $count_jobs = AngelPS1::System->$impl($$, $AngelPS1::TTYNAME);

    SKIP: {
	ok($count_jobs, "$impl_name works")
	    or skip "$impl_name doesn't work :(" => 1;
	is_deeply([ $count_jobs->() ], [ 0, 0 ], "Dry run: no jobs")
	    or next;

	push @count_jobs_impl, [ $impl_name => $count_jobs ];
    }
}


if (@count_jobs_impl) {
    note "\$\$: $$";
    note "tty: $AngelPS1::TTYNAME";

    # Count just suspended jobs
    test_jobs 1, 0, @count_jobs_impl;

    # Count just background jobs
    test_jobs 0, 1, @count_jobs_impl;

    note "Random test";
    test_jobs int(rand 10), int(rand 10), @count_jobs_impl;
}

done_testing;

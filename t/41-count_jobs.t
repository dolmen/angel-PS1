use strict;
use warnings;

use Test::More;

use AngelPS1::System;

use Sub::Util 1.40 ();   # subname
use List::Util ();       # shuffle


sub test_jobs ($$$)
{
    my ($count_jobs, $suspended, $background) = @_;

    note "Testing with $suspended suspended and $background background jobs...";

    my $total = $suspended + $background;

    is_deeply([ $count_jobs->() ], [ 0, 0 ], "No jobs before starting");

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
    is_deeply([ $count_jobs->() ], [ $suspended, $background ],
	"Suspended: $suspended, Background: $background");

    note "Killing jobs...";
    for (@childs) {
	kill CONT => $_;
	kill TERM => $_;
    }
    wait for @childs;

    is_deeply([ $count_jobs->() ], [ 0, 0 ], "All childs cleaned.");
}




AngelPS1::System->use;

my @gen_count_jobs_impl = AngelPS1::System->_count_jobs_impl;

plan tests => 1 + 5 * @gen_count_jobs_impl;

cmp_ok(scalar @gen_count_jobs_impl, '>=', 1, 'Has available implementations');




note "\$\$: $$";

for my $impl (@gen_count_jobs_impl) {

    my $impl_name = Sub::Util::subname($impl);

    # We will count jobs child or our process
    my $count_jobs = AngelPS1::System->$impl($$);

    SKIP: {
	ok($count_jobs, "$impl_name works")
	    or skip "$impl_name doesn't work :(" => 4;
	is_deeply([ $count_jobs->() ], [ 0, 0 ], "First run: no jobs")
	    or skip 'basic test failed' => 3;

	test_jobs $count_jobs, int(rand 10), int(rand 10);
    }
}


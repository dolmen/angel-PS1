use strict;
use warnings;

use Test::More;

use AngelPS1::System;

AngelPS1::System->use;

my @gen_count_jobs_impl = AngelPS1::System->_count_jobs_impl;

plan tests => 1 + 6 * @gen_count_jobs_impl;

cmp_ok(scalar @gen_count_jobs_impl, '>=', 1, 'Has available implementations');

note "\$\$: $$";

for my $impl (@gen_count_jobs_impl) {

    # We will count jobs child or our process
    my $count_jobs = AngelPS1::System->$impl($$);

    # TODO show the sub name

    SKIP: {
	ok($count_jobs, 'Implementation is working')
	    or skip 5, 'not working';
	is_deeply([ $count_jobs->() ], [ 0, 0 ], "First run")
	    or skip 4, 'basic test failed';

	if (my $child = fork) {
	    system("ps --ppid $$ -o ppid -o pgid -o pid -o stat");
	    is_deeply([ $count_jobs->() ], [ 0, 1 ], "Background: 1");
	    kill TERM => $child;
	    wait;
	} else {
	    setpgrp 0, $$;
	    note "Sleeping child $$...\n";
	    sleep 1;
	    exit 0;
	}

	is_deeply([ $count_jobs->() ], [ 0, 0 ], "Done.");

	if (my $child = fork) {
	    select undef, undef, undef, 0.25; # Sleep 0.25 second
	    kill STOP => $child;
	    system("ps --ppid $$ -o ppid -o pgid -o pid -o stat");
	    is_deeply([ $count_jobs->() ], [ 1, 0 ], "Suspended: 1");
	    kill CONT => $child;
	    kill TERM => $child;
	    wait;
	} else {
	    setpgrp 0, $$;
	    note "Sleeping child $$...\n";
	    sleep 2;
	    exit 0;
	}

	is_deeply([ $count_jobs->() ], [ 0, 0 ], "Done.");
    }
}


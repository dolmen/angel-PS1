use strict;
use warnings;

use Test::More;

use AngelPS1::System;

use Sub::Util ();

AngelPS1::System->use;

my @gen_count_jobs_impl = AngelPS1::System->_count_jobs_impl;

plan tests => 1 + 7 * @gen_count_jobs_impl;

cmp_ok(scalar @gen_count_jobs_impl, '>=', 1, 'Has available implementations');

note "\$\$: $$";

for my $impl (@gen_count_jobs_impl) {

    my $impl_name = Sub::Util::subname($impl);

    # We will count jobs child or our process
    my $count_jobs = AngelPS1::System->$impl($$);

    SKIP: {
	ok($count_jobs, "$impl_name works")
	    or skip "$impl_name doesn't work :(" => 6;
	is_deeply([ $count_jobs->() ], [ 0, 0 ], "First run")
	    or skip 'basic test failed' => 5;

	my ($in, $out);
	ok(pipe($in, $out), "pipe")
	    or do {
	    diag "\$!: $!";
	    skip "pipe failed" => 4
	};

	if (my $child = fork) {
	    close $out;
	    <$in>; close $in;
	    system("ps --ppid $$ -o ppid -o pgid -o pid -o stat");
	    is_deeply([ $count_jobs->() ], [ 0, 1 ], "Background: 1");
	    kill TERM => $child;
	    wait;
	} else {
	    setpgrp 0, $$;
	    close $in;
	    note "Sleeping child $$...\n";
	    print $out "Ready.\n"; close $out;
	    sleep 1;
	    exit 0;
	}

	is_deeply([ $count_jobs->() ], [ 0, 0 ], "Done.");
	pipe $in, $out;

	if (my $child = fork) {
	    close $out;
	    <$in>; close $in;
	    kill STOP => $child;
	    system("ps --ppid $$ -o ppid -o pgid -o pid -o stat");
	    is_deeply([ $count_jobs->() ], [ 1, 0 ], "Suspended: 1");
	    kill CONT => $child;
	    kill TERM => $child;
	    wait;
	} else {
	    setpgrp 0, $$;
	    close $in;
	    note "Sleeping child $$...\n";
	    print $out "Ready.\n"; close $out;
	    sleep 1;
	    exit 0;
	}

	is_deeply([ $count_jobs->() ], [ 0, 0 ], "Done.");
    }
}


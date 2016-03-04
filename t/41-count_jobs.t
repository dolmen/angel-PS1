use strict;
use warnings;

use Test::More;

use AngelPS1;
use AngelPS1::System;

use Term::Chrome qw< Blue Red Bold >;
use AngelPS1::Plugin::Jobs qw< Jobs >;

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
    my ($suspended, $background, @tests) = @_;

    note "===============================================================================";
    note "Testing with $suspended suspended and $background background jobs...";

    my $total = $suspended + $background;

    subtest 'no jobs before starting' => sub {
	$_->(0, 0) for @tests
    };

    return if $total == 0;

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
	local $_;
	$_->($suspended, $background) for @tests
    };

    note "Killing jobs...";
    for (@childs) {
	kill CONT => $_;
	kill TERM => $_;
    }
    wait for @childs;

    subtest 'all childs cleaned' => sub {
	$_->(0, 0) for @tests
    };
    note "-------------------------------------------------------------------------------";
}




AngelPS1::System->use;

my @tests;

my $chrome_suspended = Blue + Bold;
my $chrome_background = Red + Bold;
my $theme = {
    suspended => $chrome_suspended,
    suspended_symbol => $chrome_suspended,
    background => $chrome_background,
    background_symbol => $chrome_background,
};

my @prompt = do {
    # For this test our process is the one controlling the jobs
    # while in AngelPS1, it is the parent process
    local $AngelPS1::SHELL_PID = $$;
    # The Jobs plugin
    ( Jobs($theme) )
};
if (ok(scalar @prompt, 'Jobs plugin has a working implementation')
    && is(ref($prompt[0]), 'CODE', 'Jobs plugin returned a sub')) {
    my %CHECKS = (
	"0,0" => [ ],
	"1,0" => [ $chrome_suspended => [ '1' ], $chrome_suspended => [ 'z' ] ],
	"0,1" => [ $chrome_background => [ '1' ], $chrome_background => [ '&' ] ],
	"1,1" => [
	    $chrome_suspended => [ '1' ], $chrome_suspended => [ 'z' ],
	    '/',
	    $chrome_background => [ '1' ], $chrome_background => [ '&' ],
	],
    );
    push @tests, sub {
	if (my $check = $CHECKS{"$_[0],$_[1]"}) {
	    my @res = $prompt[0]->();
	    unless (is_deeply(\@res, $check, "Jobs plugin")) {
		#if (eval { require JSON::MaybeXS; 1 }) {
		    diag "Got: ", explain(\@res);
		    #}
	    }
	} else {
	    note "Jobs plugin: not tested";
	}
    }
}


for my $impl (AngelPS1::System->_count_jobs_impl) {

    my $impl_name = Sub::Util::subname($impl);

    # We will count jobs child or our process
    my $count_jobs = AngelPS1::System->$impl($$, $AngelPS1::TTYNAME);

    SKIP: {
	ok($count_jobs, "$impl_name works")
	    or skip "$impl_name doesn't work :(" => 1;
	is_deeply([ $count_jobs->() ], [ 0, 0 ], "Dry run: no jobs")
	    or next;

	push @tests, sub {
	    my $expected = [ @_ ];
	    test_count_jobs($impl_name, $count_jobs, $expected)
	};
    }
}


if (@tests) {
    note "\$\$: $$";
    note "tty: $AngelPS1::TTYNAME";

    # Count just suspended jobs
    test_jobs 1, 0, @tests;

    # Count just background jobs
    test_jobs 0, 1, @tests;

    test_jobs 1, 1, @tests;

    note "Random test";
    test_jobs int(rand 10), int(rand 10), @tests;
}

done_testing;

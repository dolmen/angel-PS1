use utf8;
use strict;
use warnings;

package AngelPS1::Plugin::Jobs;

use AngelPS1;
our $VERSION = $AngelPS1::VERSION;

use Exporter 5.57 'import';
our @EXPORT = qw<Jobs>;

use AngelPS1::System;
use AngelPS1::Chrome qw< Bold Yellow >;

sub Jobs
{
    my $count_jobs = AngelPS1::System->gen_count_jobs()
	or return;
    # https://github.com/dolmen/angel-PS1/issues/18
    #my $color_suspended  = $_[1] || (Yellow+Bold);
    #my $color_background = $_[2] || (Yellow+Bold);
    my $color_suspended  = defined($_[1]) ? $_[1] : Yellow+Bold;
    my $color_background = defined($_[2]) ? $_[2] : Yellow+Bold;

    return sub {
	my ($suspended, $background) = $count_jobs->();
	return if !defined($suspended) || $suspended+$background == 0;
	my @res;
	push @res, $color_suspended, [ "${suspended}z" ] if $suspended;
	push @res, '/' if $suspended && $background;
	push @res, $color_background, [ "${background}&" ] if $background;
	@res
    }
}

1;

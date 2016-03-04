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
    my $theme = $_[0] || {};
    my $chrome_suspended_count = $theme->{suspended} || (Yellow+Bold);
    my @symbol_suspended = ( ($theme->{suspended_symbol} || Yellow), [ 'z' ] );
    my $chrome_background_count = $theme->{background} || (Yellow+Bold);
    my @symbol_background = ( ($theme->{background_symbol} || Yellow), [ '&' ] );
    my @separator = exists $theme->{separator}
		  ? ( $theme->{separator}, [ '/' ])
		  : ( '/' );

    return sub {
	my ($suspended, $background) = $count_jobs->();
	return if !defined($suspended) || $suspended+$background == 0;
	my @res;
	push @res, $chrome_suspended_count, [ $suspended ], @symbol_suspended
	    if $suspended;
	push @res, @separator if $suspended && $background;
	push @res, $chrome_background_count, [ $background ], @symbol_background
	    if $background;
	@res
    }
}

1;

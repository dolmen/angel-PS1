use strict;
use warnings;

package AngelPS1::Plugin::Core;

our $VERSION = $AngelPS1::VERSION;

use Exporter 5.57 'import';
our @EXPORT = qw(Escape MarginLeft);

use AngelPS1::Plugin;


sub Escape
{
    my @content = compact(@_);
    sub {
        my @result = interp @content;
        \ compact(@result);
    }
}

sub MarginLeft
{
    my $code = pop;
    my $margin = shift;
    $margin = ' ' unless defined $margin;
    sub {
        my @result = interp $code;
        return unless @result;
        ($margin, @result)
    }
}

'$';

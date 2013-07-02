use strict;
use warnings;

package AngelPS1::Plugin::Core;

our $VERSION = $AngelPS1::VERSION;

use Exporter 5.57 'import';
our @EXPORT = qw(Escape MarginLeft);

use AngelPS1::Compiler;


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
    die 'MarginLeft: not a CODEREF' unless ref($code) eq 'CODE';
    my $margin = shift;
    $margin = ' ' unless defined $margin;
    sub {
        my @result = interp @_, $code;
        return unless @result;
        ($margin, @result)
    }
}

'$';
# vim:set et ts=8 sw=4 sts=4:

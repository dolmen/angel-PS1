use strict;
use warnings;

package AngelPS1::Plugin::Core;

our $VERSION = $AngelPS1::VERSION;

use Exporter 5.57 'import';
our @EXPORT = qw(MarginLeft);

use AngelPS1::Compiler;



sub MarginLeft ($;$)
{
    my $code = pop;
    if (!ref($code)) {
        return length($code) ? " $code" : $code;
    }
    die 'MarginLeft: not a CODEREF' unless ref($code) eq 'CODE';
    my @margin = @_;
    @margin = (' ') unless @margin;
    sub {
        my @result = expand(@_, $code);
        return unless @result;
        (@margin, @result)
    }
}

'$';
# vim:set et ts=8 sw=4 sts=4:

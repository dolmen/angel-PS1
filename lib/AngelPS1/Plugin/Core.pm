use strict;
use warnings;

package AngelPS1::Plugin::Core;

our $VERSION = $AngelPS1::VERSION;

use Exporter 5.57 'import';
our @EXPORT = qw(MarginLeft MarginRight);

use AngelPS1::Compiler qw(expand);

# Usages:
#    MarginLeft(sub { ... })   # default margin: ' '
#    MarginLeft($margin, sub { ... })
sub MarginLeft ($;$)
{
    my $code = pop;
    if (!ref($code)) {
        return defined($code) && length($code) ? " $code" : ();
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

sub MarginRight ($;$)
{
    my $code = pop;
    if (!ref($code)) {
        return defined($code) && length($code) ? "$code " : ();
    }
    die 'MarginLeft: not a CODEREF' unless ref($code) eq 'CODE';
    my @margin = @_;
    @margin = (' ') unless @margin;
    sub {
        my @result = expand(@_, $code);
        return unless @result;
        (@result, @margin)
    }
}

'$';
# vim:set et ts=8 sw=4 sts=4:

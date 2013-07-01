use strict;
use warnings;

package AngelPS1::Compiler;

use Exporter 'import';
our @EXPORT = qw<compact interp ps1_is_static>;

use AngelPS1::Shell ();
use AngelPS1::Color '$NO_COLOR';


sub interp
{
    my $state = shift;
    my @args = @_;
    for(my $i=0; $i<=$#args; $i++) {
        if (ref($args[$i]) eq 'CODE') {
            splice @args, $i, 1, interp($state, $args[$i]->($state));
            redo; # A dynamic part can return dynamic parts!
        }
    }
    return @args
}



# Compact a @PS1 definition: bare scalar are expanded to their escaped result
# and scalar refs are concatenated, and colors (ARRAY) are expanded.
# CODE refs are preserved as is, so we can do a multiple step compilation.
sub compact
{
    my @template = @_;
    my @out;
    while (@template) {
        my $v = shift @template;
        my $r = ref $v;
        if ($r eq 'CODE') {
            push @out, $v;
            next;
        }
        # ARRAY followed by a scalar or scalar ref
        # => replace by the colored expanded result
        if ($r eq 'ARRAY' && @template) {
            my $r = ref $template[0];
            if ($r && $r ne 'SCALAR') {
                push @out, $v, shift @template;
                next;
            }
            # Expand the color
            $v = colored($v, shift @template);
            $r = ref $v;
        }
        if ($r) {
            $v = $$v;
        } else {
            $v = AngelPS1::Shell->ps1_escape($v);
        }
        if (@out && ref($out[$#out]) eq 'SCALAR') {
            ${$out[$#out]} .= $v
        } else {  # CODE refs (and anything else) are preserved
            push @out, \$v;
        }
    }
    return @out if wantarray;
    die "invalid state after compact" if @out != 1 || ref $out[0] ne 'SCALAR';
    ${pop @out}
}

# Process a list of mixed scalar, scalar refs and ARRAYs.
# ARRAYS are specifications for colors that must be applied to the following
# Returns a scalar ref that represents shell escaped text.
sub colored
{
    my @args = @_;
    my $out = '';
    my $color_str;
    while (@args) {
        my $v = shift @args;
        my $r = ref $v;
        if ($r eq 'ARRAY') {
            $color_str = $v->[0];
            # TODO ensure that color strings are already PS1-escaped
            $out .= compact(AngelPS1::Shell->ps1_invisible($color_str));
            next;
        }
        #print STDERR "$r $v\n";
        $out .= $r ? $$v : AngelPS1::Shell->ps1_escape($v);
        if (defined $color_str) {
            $out .= compact(AngelPS1::Shell->ps1_invisible($NO_COLOR));
            undef $color_str;
        }
    }
    return \$out
}


sub ps1_is_static
{
    my $PS1 = shift;
    $#$PS1 == 0 && (ref $PS1->[0]) eq 'SCALAR'
}


'$';
# vim:set et ts=8 sw=4 sts=4:

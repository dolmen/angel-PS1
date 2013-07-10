use strict;
use warnings;

package AngelPS1::Compiler;

use Exporter 'import';
our @EXPORT = qw< reduce expand ps1_is_static >;

use AngelPS1::Shell ();
use AngelPS1::Color '$NO_COLOR';


sub expand
{
    my $state = shift;
    my @args = @_;
    LOOP: for(my $i=0; $i<=$#args; $i++) {
        if (ref($args[$i]) eq 'CODE') {
            splice @args, $i, 1, expand($state, $args[$i]->($state));
            redo LOOP; # A dynamic part can return dynamic parts!
        }
    }
    return @args
}



# Reduce a @PS1 definition:
# - bare scalar are expanded to their escaped result
# - scalar refs are concatenated
# - colors (ARRAY) are expanded
# - CODE refs are preserved as is (for multiple step compilation)
# In scalar context the result of that process is expected to be a single
# scalar ref (which implies that no CODE appeared in the original arguments)
# and that dereferenced scalar is returned.
sub reduce
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
            $r = ref(my $content = shift @template);
            if ($r && $r ne 'SCALAR') {
                push @out, $v, $content;
                next;
            }
            # Expand the color
            unshift @template,
                AngelPS1::Shell->ps1_invisible($v->[0]),
                $content,
                AngelPS1::Shell->ps1_invisible($NO_COLOR);
            redo;
        }
        if ($r) {
            $v = $$v;
        } else {
            $v = AngelPS1::Shell->ps1_escape($v);
        }
        if (@out && ref($out[-1]) eq 'SCALAR') {
            ${$out[-1]} .= $v
        } else {  # CODE refs (and anything else) are preserved
            push @out, \$v;
        }
    }
    return @out if wantarray;
    return '' unless @out;
    die "invalid state after reduce" if @out != 1 || ref $out[0] ne 'SCALAR';
    ${pop @out}
}


sub ps1_is_static
{
    my $PS1 = shift;
    $#$PS1 == 0 && (ref $PS1->[0]) eq 'SCALAR'
}


'$';
# vim:set et ts=8 sw=4 sts=4:

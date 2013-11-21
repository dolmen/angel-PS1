use strict;
use warnings;

package AngelPS1::Compiler;

use Exporter 'import';
our @EXPORT = qw< reduce expand ps1_is_static >;

use AngelPS1::Shell ();
use AngelPS1::Chrome ();
use Scalar::Util ();


sub expand
{
    my $state = shift;
    my @args = @_;
    LOOP: for(my $i=0; $i<=$#args; $i++) {
        #warn $i;
        if (ref($args[$i]) eq 'CODE') {
            #use B 'svref_2object';
            #my $GV = svref_2object($args[$i])->GV;
            #warn('expanding sub '.$GV->SAFENAME.' defined at '.$GV->FILE.' line '.$GV->LINE);
            #undef $GV;

            splice @args, $i, 1, $args[$i]->($state);
            #warn "OK";
            redo LOOP; # A dynamic part can return dynamic parts!
        }
    }
    return @args
}

sub reduce;

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
        if ($r) {
            # Keep subs as they must be explicitely expanded using expand()
            if ($r eq 'CODE') {
                push @out, $v;
                next;
            # Scalar refs are for raw (non-escaped) strings
            } elsif ($r eq 'SCALAR') {
                $v = $$v;
            # Array refs are only expanded after a chrome spec. See below
            } elsif ($r eq 'ARRAY') {
                warn "ARRAY unexpected in reduced prompt\n" unless wantarray;
                push @out, [ reduce(@$v) ];
                next;
            }
            # => replace by the colored expanded result
            elsif (Scalar::Util::blessed($v) && $v->isa('AngelPS1::Chrome')) {
                if (@template && ref($template[0]) eq 'ARRAY') {
                    unshift @template,
                        AngelPS1::Shell->ps1_invisible("$v"),
                        # flatten the ARRAY
                        @{ shift @template },
                        AngelPS1::Shell->ps1_invisible(AngelPS1::Chrome::Reset->term);
                } else {
                    # Expand the color
                    unshift @template, AngelPS1::Shell->ps1_invisible("$v");
                }
                redo;
            } else {
                warn "unexpected $r item in prompt";
                next;
            }
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
    die "invalid state after reduce: @out" if @out != 1 || ref $out[0] ne 'SCALAR';
    ${pop @out}
}


sub ps1_is_static
{
    my $PS1 = shift;
    $#$PS1 == 0 && (ref $PS1->[0]) eq 'SCALAR'
}


'$';
# vim:set et ts=8 sw=4 sts=4:

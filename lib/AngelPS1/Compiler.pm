use strict;
use warnings;

package AngelPS1::Compiler;

use Exporter 'import';
our @EXPORT = qw< reduce expand ps1_is_static >;

use AngelPS1::Shell ();
use Term::Chrome 2.000 ();
use Scalar::Util ();


sub expand
{
    my $state = shift;
    die "expand(): invalid arg" unless ref($state) eq 'HASH';
    my @args = @_;
    LOOP: for(my $i=0; $i<=$#args; $i++) {
        #warn $i;
        my $r = ref $args[$i];
        if ($r eq 'CODE') {
            #use B 'svref_2object';
            #my $GV = svref_2object($args[$i])->GV;
            #warn('expanding sub '.$GV->SAFENAME.' defined at '.$GV->FILE.' line '.$GV->LINE);
            #undef $GV;
            my @tmp = $args[$i]->($state);
            splice @args, $i, 1, @tmp;
            #warn "OK";
            redo LOOP; # A dynamic part can return dynamic parts!
        } elsif ($r eq 'ARRAY') {
            $args[$i] = [ expand($state, @{$args[$i]}) ];
        }
    }
    return @args
}

sub reduce;

# Reduce a @PS1 definition:
# - bare scalar are expanded to their escaped result
# - scalar refs are concatenated
# - Term::Chrome are expanded to their ANSI sequence representation
# - Term::Chrome followed by ARRAY are expanded to the ANSI sequence,
#   the recursive reduce of the flattened array, and the ANSI sequence of
#   the reverse Chrome
# - undef are skipped
# - CODE refs are preserved as is (for multiple step compilation)
# In scalar context the result of that process is expected to be a single
# scalar ref (which implies that no CODE appeared in the original arguments)
# and that dereferenced scalar is returned.
sub reduce
{
    my @template = @_;
    my @out;
    LOOP: while (@template) {
        my $v = shift @template;
        if (my $r = ref $v) {
            # Scalar refs are for raw (non-escaped) strings
            if ($r eq 'SCALAR') {
                $v = $$v;
            }
            # => replace by the colored expanded result
            elsif (Scalar::Util::blessed($v) && $v->isa('Term::Chrome')) {
                if (@template && ref($template[0]) eq 'ARRAY') {
                    unshift @template,
                        AngelPS1::Shell->ps1_invisible($v->term),
                        # flatten the ARRAY
                        @{ shift @template },
                        # close the colored part with the reverse of $v
                        AngelPS1::Shell->ps1_invisible((!$v)->term);
                } else {
                    # Expand the color
                    unshift @template, AngelPS1::Shell->ps1_invisible($v->term);
                }
                redo LOOP;
            } else {
                if (wantarray) {
                    # Keep subs as they must be explicitely expanded using expand()
                    if ($r eq 'CODE') {
                        push @out, $v;
                        next LOOP;
                    # Array refs are only expanded after a chrome spec. See below
                    } elsif ($r eq 'ARRAY') {
                        push @out, [ reduce(@$v) ];
                        next LOOP;
                    }
                }
                warn "unexpected $r item in prompt\n";
                next LOOP;
            }
        } else {
            # Skip if undef
            next unless defined $v;

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
    die "invalid state after reduce: @out\n" if @out != 1 || ref $out[0] ne 'SCALAR';
    ${pop @out}
}


sub ps1_is_static
{
    my $PS1 = shift;
    $#$PS1 == 0 && (ref $PS1->[0]) eq 'SCALAR'
}


'$';
# vim:set et ts=8 sw=4 sts=4:

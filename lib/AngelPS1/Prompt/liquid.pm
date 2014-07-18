use strict;
use warnings;

package AngelPS1::Prompt::liquid;

sub _shell_unescape ($)
{
    my $txt = shift;

    # This is a very simplistic implementation that
    # should be enough for liquidprompt configs
        $txt =~ s/^'(.*)'$/$1/
    or ($txt =~ s/^"(.*)"$/$1/ and $txt =~ s/\\./\\/g);

    $txt
}

sub read_rc
{
    my $file = shift;
    open my $f, '<:encoding(UTF-8)', $file or die "Can't open $file: $!\n";
    my %conf =
        map { m/LP_(.*?)=(.*?)\s*$/ ? ($1 => _shell_unescape $2) : () }
        grep /LP_.*=/,
        grep !/^\s*(?:#|$)/,
        <$f>;
    close $f;
    \%conf
}

my $conf = read_rc "$ENV{HOME}/.liquidpromptrc";
print STDERR "$_=$conf->{$_}\n" for keys %$conf;

# Delegate to the default prompt, for now
# FIXME
do 'AngelPS1/Prompt/Default.pm';
__END__
# vim:set et ts=8 sw=4 sts=4:

use strict;
use warnings;

package AngelPS1::Shell;

my %ALIASES = (
    dash  => 'POSIX',
    ksh   => 'mksh',
    ksh88 => 'mksh',
    ksh93 => 'mksh',
);


my $name;

#
# Call: AngelPS1::Shell->name
#
sub name
{
    $name
}

#
# Call: AngelPS1::Shell->use('bash')
#
sub use
{
    my ($class, $shell) = @_;
    if ($shell) {
        $shell = $ALIASES{$shell} if exists $ALIASES{$shell};
        my $src = "AngelPS1/Shell/$shell.pm";
        unless (exists $INC{$src}) {
            # TODO try to distinguish load errors (file not found) from compile errors
            # by pushing a sub on @INC that will be called.
            die "$shell is not a supported shell.\n" unless eval { require $src };
            my $pkg = "${class}::$shell";
            # Make AngelPS1::Shell a sub class of $pkg
            our @ISA = ($pkg);
            $name = $shell;
        }
    }
}

'$';
# vim:set et ts=8 sw=4 sts=4:

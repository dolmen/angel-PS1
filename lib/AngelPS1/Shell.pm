use strict;
use warnings;

package AngelPS1::Shell;

my %ALIASES = (
    dash  => 'POSIX',
    ksh   => 'ksh93',
    # Not tested
    ksh88 => 'POSIX',
);


my $name;

#
# Call: AngelPS1::Shell->name
#
sub name
{
    $name
}

# Exporter: allows to use AngelPS1::Shell plugins as functions
# instead of only as methods of AngelPS1::Shell
#
# Ex:
#    use AngelPS1::Shell qw<WorkingDir_Tilde>;
sub import
{
    return unless @_ > 1;

    no strict 'refs';
    shift;
    my $pkg = (caller)[0];
    my @subs = @_;
    foreach my $s (@subs) {
        my $proto;
        $s =~ s/(\(.*\))\z// and $proto = $1;

        if (defined $name && ! AngelPS1::Shell->can($s) ) {
            require Carp;
            Carp::croak("can't import '$s'");
        }

        *{"$pkg\::$s"} = sub { AngelPS1::Shell->$s(@_) };
    }
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
            eval { require $src }
                or die "$shell is not a supported shell: $@.\n";
        }

        # Make AngelPS1::Shell a sub class of the loaded module
        our @ISA = ("${class}::$shell");
        $name = $shell;
    }
}


sub detect
{
    require AngelPS1::Util;
    # Extract the name of $PPID

    my $ppid = getppid;
    my $shell;

    GET_CMD: {
        # Linux/cygwin shortcut
        for my $comm_file ("/proc/$ppid/comm", "/proc/$ppid/cmdline") {
            next unless -f $comm_file && -r _;
            open my $comm, '<', $comm_file or next;
            $shell = <$comm>;
            $shell =~ s/\0.*$//s;  # /proc/*/cmdline under cygwin
            last GET_CMD if length $shell;
        }
        # Other platforms
        $shell = AngelPS1::Util::run(ps => qw(-o comm=), $ppid)
    }
    $shell = AngelPS1::Util::one_line($shell);

    # Login shells may begin with a '-': '-bash'
    $shell =~ s/^-//;

    return $shell
}

'$';
# vim:set et ts=8 sw=4 sts=4:

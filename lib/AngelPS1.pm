package AngelPS1;

use POSIX ();

our $VERSION = '0.95';

# The process id of the shell
# (this module must be loaded before forking)
our $SHELL_PID = getppid;

# The angel's name (which is used as the controller command)
our $NAME = 'angel';

# Verbosity level: boolean
our $VERBOSE = 0;

# Terminal's device name, without the '/dev/' prefix
(our $TTYNAME = POSIX::ttyname(0)) =~ s{^/dev/}{};

# Encoding name for the locale (LC_CTYPE)
our $ENCODING;

my $encoding;

# This function is experimental.
# Its name is subject to future change.
sub _str_allowed
{
    my $str = shift;
    $encoding ||= do {
	require Encode;
	Encode::find_encoding($ENCODING)
    };
    local $@;
    eval { Encode::encode($encoding, $str, Encode::FB_CROAK()) };
    # Return true if no exception was thrown
    !$@
}

1;
__END__

=encoding UTF-8

=head1 NAME

AngelPS1 - The Angel's Prompt

=head1 SYNOPSIS

Use C<L<angel-PS1>> in your shell:

    $ eval $(angel-PS1)

Get the documentation:

    $ perldoc angel-PS1

=head1 DESCRIPTION

C<angel-PS1> is a prompt engine for your shell.

The man page for L<angel-PS1> contains most of the high level documentation.
This page is the index for documentation to go further in the C<angel-PS1>
APIs to get the best of it!

=head1 FAQ

=head2 What is a I<shell prompt>?

Look for I<C<PS1>> in your Bourne-like Unix shell (bash, zsh, ksh, dash...).

=head2 How to write my own shell prompt using C<angel-PS1>?

See L<AngelPS1::Prompt>.

=head2 How can I share my prompt definition with other users?

See L<AngelPS1::Prompt>.

=head2 What is an C<angel-PS1> I<plugin>?

A plugin for C<angel-PS1> is a kind of function library that can be re-used
and shared. A plugin exports bricks that can be used to a customized
C<angel-PS1> prompt.

See for example L<AngelPS1::Plugin::Git>.


Each of theese functions must return a list value that can be inserted in a
prompt definition.

=head2 How to write a plugin?

A plugin is a classical Perl 5 package in a .pm file.
See L<AngelPS1::Plugin> for details.

=head2 How do I share plugins?

Distributing them through CPAN can be convenient for Perl developers.

Distributing just the .pm file will target a larger audience...

=head2 What about C<angel-PS1> internals?

Those APIs are documented (if they are :) ) only for developpers contributing
to the core of L<angel-PS1>.

See L<AngelPS1::Compiler> for how the prompt list in compiled into a prompt
string.

See L<AngelPS1::Shell> for pluggable shell support.

See L<AngelPS1::System> for pluggable operating support for querying the system
state in plugins.

=head1 AUTHOR

L<Olivier Mengué|mailto:dolmen@cpan.org>

=head1 COPYRIGHT AND LICENSE

`angel-PS1` itself is distributed under the GNU Affero General Public License
version 3 or later. See the F<COPYING> file in the distribution for details.

`angel-PS1` plugins must be distributed under the
[Artistic License 2.0](http://opensource.org/licenses/Artistic-2.0).
This basically allows to reuse the code of plugins either to improve the
`angel-PS1` core or for any other usage in Perl programs, not just `angel-PS1`.

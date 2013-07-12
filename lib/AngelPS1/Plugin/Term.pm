use strict;
use warnings;

package AngelPS1::Plugin::Term;

our $VERSION = $AngelPS1::VERSION;

use Exporter 5.57 'import';
our @EXPORT = qw(TermTitle);

use AngelPS1::Shell;

use constant {
    TITLE_BEGIN => "\e]0;",
    TITLE_END   => "\a",
};

sub TermTitle
{
    if (AngelPS1::Shell->name eq 'fish') {
        require Carp;
        Carp::carp("TermTitle is not supported on fish. See instead fish_title in the fish manual");
        return
    }
    # TODO use tsl/fsl from terminfo, if the terminfo definition has them
    # TODO Truncate to wsl
    # TODO check eslok and escape if necessary
    AngelPS1::Shell->ps1_invisible(TITLE_BEGIN, @_, TITLE_END)
}

'$';
# vim:set et ts=8 sw=4 sts=4:

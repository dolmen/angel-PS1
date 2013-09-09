use strict;
use warnings;

use Test::More tests => 2;

use encoding ();

# Check if encoding::_get_locale_encoding is available
# as this is a private APIs (/^_/)

our $TODO = 'Non-blocking test';

SKIP: {
    ok(encoding->can('_get_locale_encoding'), '_get_locale_encoding')
	or skip 'Missing encoding::_get_locale_encoding', 1;

    my $encoding = encoding::_get_locale_encoding();
    ok($encoding , '_get_locale_encoding works') and note "Encoding: $encoding";
}



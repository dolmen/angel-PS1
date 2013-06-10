#!/usr/bin/env perl

use 5.010;
use strict;
use warnings;

# Only to fail early if the tool is missing
use App::FatPacker ();
use Carp 'croak';
use File::Copy 'copy';

# Create the script
#system '(echo "#!/usr/bin/env perl"; fatpack file; cat bin/angel-PS1) > 'angel-PS1';
open my $script, '>:raw', 'angel-PS1';
print $script "#!/usr/bin/perl\n";
close $script;
system "fatpack file >> angel-PS1";
open $script, '>>:raw', 'angel-PS1';
copy('bin/angel-PS1', $script);
close $script;

chmod 0755, 'angel-PS1';

say 'Done.';

#!/usr/bin/env perl
use utf8;

use constant COPYRIGHT => <<END;

#    Copyright © 2013 Olivier Mengué
#    Original source code is available at https://github.com/dolmen/angel-PS1
#
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU Affero General Public License as
#    published by the Free Software Foundation, either version 3 of the
#    License, or (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU Affero General Public License for more details.
#
#    You should have received a copy of the GNU Affero General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.

END

use 5.010;
use strict;
use warnings;

# Only to fail early if the tool is missing
use App::FatPacker ();
use Carp 'croak';
use File::Copy 'copy';

# Create the script
#system '(echo "#!/usr/bin/env perl"; fatpack file; cat bin/angel-PS1) > 'angel-PS1';
open my $script, '>:utf8', 'angel-PS1';
print $script "#!/usr/bin/perl\n", COPYRIGHT;
close $script;
system "fatpack file >> angel-PS1";
open $script, '>>:raw', 'angel-PS1';
copy('bin/angel-PS1', $script);
close $script;

chmod 0755, 'angel-PS1';

say 'Done.';

#!perl

use strict;
use warnings;

use Test::More 0.98;
use AngelPS1::Shell;
use AngelPS1::Compiler qw< reduce >;

AngelPS1::Shell->use('bash');

is(AngelPS1::Shell->name, 'bash', '->name');
is(AngelPS1::Shell->ps1_escape('xy'), 'xy', '->ps1_escape');
is(scalar reduce(AngelPS1::Shell->ps1_invisible('xy')), '\[xy\]', '->ps1_invisible');


done_testing;

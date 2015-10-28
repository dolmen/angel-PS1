
# CPAN requirements
# -----------------
# See https://metacpan.org/pod/cpanfile
#
# To install dependencies for development:
#    cpanm Module::CPANfile
#    cpanfile-dump --develop | cpanm


# External modules that will be fatpacked
requires 'Term::Chrome' => '1.011';
# Core modules:
requires 'Pod::Usage';
requires 'Getopt::Long';
requires 'Encode';
requires 'Exporter' => '5.57';
requires 'File::Spec';
requires 'IPC::Open3';
requires 'FindBin';
requires 'POSIX';
requires 'Symbol';
requires 'Scalar::Util';

on test => sub {
    requires 'Test::More' => '0.98';
    requires 'Test::More::UTF8';
    recommends 'Test::MockTime';
    requires 'Term::Encoding';
    requires 'Env::PS1'; # examples/EnvPS1.PS1
};

# Stuff for the maintainer to make releases (see 'dist' script)
on develop => sub {
    # dist
    requires 'App::Prove';
    requires 'App::FatPacker';
    requires 'Perl::Strip';
    requires 'Module::CoreList';
    requires 'File::Copy';
    requires 'Git::Sub';
    # xt/
    requires 'Test::Pod';
    requires 'Test::Spelling';
    requires 'Test::Pod::No404s';
};

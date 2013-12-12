![angel-PS1 logo][1] angel-PS1 - The Angel's Prompt
===================================================

   [1]: doc/images/angel-PS1_64.png

`angel-PS1` is your guardian angel for the Unix world.


The implementation is a
[*daemon*](https://en.wikipedia.org/wiki/Daemon_%28computing%29),
a background process, that will service your shell every time it needs to
display the prompt.

This is a daemon, but not a nasty demon. So it is an angel. Like a
guardian angel, attached to the shell and who gives him precious
information about the world around that you can't see. You'll not see him,
but he is there. Always around, but always discreet.

### Build status

`release`: [![Build status](https://travis-ci.org/dolmen/angel-PS1.png?branch=release)](https://travis-ci.org/dolmen/angel-PS1)

`devel`: [![Build status](https://travis-ci.org/dolmen/angel-PS1.png?branch=devel)](https://travis-ci.org/dolmen/angel-PS1)

### Basic usage

#### Download and install

    wget https://github.com/dolmen/angel-PS1/raw/release/angel-PS1
    chmod u+x angel-PS1

That'it! Easy, isn't?

#### Run

Try this in your Unix/Linux shell to get a fancy prompt with the default
settings:

[`bash`](https://www.gnu.org/software/bash/)/[`zsh`](http://www.zsh.org/)/[`mksh`](https://www.mirbsd.org/mksh.htm)/[`dash`](http://gondor.apana.org.au/~herbert/dash/)/[`ksh93`](http://www.kornshell.com/)/[`tcsh`](http://tcsh.org/):

    eval `./angel-PS1`

[`fish`](http://fishshell.com):

    eval (./angel-PS1)

**Note:** this project is still very young and is constantly evolving. I
recommend to *not yet* load it from `~/.bashrc`.

You can also try other examples from the repository:

    git clone https://github.com/dolmen/angel-PS1.git
    cd angel-PS1
    eval `./angel-PS1 -c examples/Powerline-basic.PS1`

#### Documentation

    perldoc ./angel-PS1

Sorry, the documentation is quite light at the moment.

### Supported shells

#### First class

- `bash`
- `mksh`
- `dash`
- `ksh93`
- `zsh`
- `fish`

#### Experimental

- `tcsh`: see [issue #1](https://github.com/dolmen/angel-PS1/issues/1) (major issue)

### Features

Angel's Prompt is not just another new fancy prompt for your Unix shell.
This is also:

* **A powerful, but still fast, prompt.** Thanks an original architecture,
  you are not limited anymore by the speed of your shell and the cost of
  forking processes.
* **Not just *my* prompt, but *your* prompt.** You can configure your own
  look using plugins.
* **A prompt written in Perl.** Perl is the powerful companion to your
  sysadmin tasks, but also an expressive general programming language that has
  access the C Unix API. Perl is available on every Unix-like operating system,
  and usually installed among core packages.
* **A prompt building framework.** The API will help you to easily build your
  own prompt using plugins, and to build plugins that you'll share with others.
  With a powerful engine that allows you to easily specify colors and to
  transparently escape shell special characters.
* **[CPAN](https://metacpan.org/) power.** Thanks to Perl and its community,
  you have access to the thousands of Perl modules on the CPAN to efficiently
  and/or portably retrieve information that you will show in the prompt.
* **Write once, run anywhere.** Write your prompt configuration once, and use
  it in any shell supported by `angel-PS1`. And `angel-PS1` is a single file,
  easy to move from machine to machine and run with any Perl, from 5.8.3 to
  5.18+. As your prompt definition is also written in Perl, it has the
  same portability.

### News

Follow <a href="https://twitter.com/nglPS1">@nglPS1</a> on Twitter.

### Support

* IRC: [irc.perl.org, channel #angel-PS1](irc://irc.perl.org/angel-PS1)
* [issues on Github](https://github.com/dolmen/angel-PS1/issues)

### Copyright & license

Copyright 2013 Olivier Mengué.

`angel-PS1` itself is distributed under the GNU Affero General Public License
version 3 or later. See [COPYING](COPYING) for details.

`angel-PS1` plugins must be distributed under the
[Artistic License 2.0](http://opensource.org/licenses/Artistic-2.0).
This basically allows to reuse the code of plugins either to improve the
`angel-PS1` core or for any other usage in Perl programs, not just `angel-PS1`.


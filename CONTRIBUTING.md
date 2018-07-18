Contributing to The Angel's Prompt
==================================


The public stable branch for end users is `release`.

On `release` the angel-PS1 file is the result of a build. The sources for
the build are on the `devel` branch. This is on top of this branch that you
must write your patches.


Setup your work environment
---------------------------

    $ git clone -b devel -o upstream git://github.com/dolmen/angel-PS1.git
    $ cd angel-PS1

    # Install a Perl development environment
    $ git clone https://github.com/tokuhirom/plenv.git ~/.plenv
    # See ~/.plenv/README.md for persistent install
    $ eval "$(~/.plenv/bin/plenv init -)"
    $ git clone https://github.com/tokuhirom/Perl-Build.git ~/.plenv/plugins/perl-build/
    $ plenv install 5.20.3
    $ plenv global 5.20.3
    $ plenv install-cpanm
    $ plenv rehash

    # Install the develop dependencies from Perl's CPAN
    $ cpanm Module::CPANfile
    $ cpanfile-dump --develop | cpanm

    # Run the test suite
    $ prove -l

How to synchronize your repo with the latest changes?
-----------------------------------------------------

    $ git checkout devel

    $ git remote update
    $ git rebase upstream/devel

    # Update the CPAN dependencies
    $ cpanfile-dump --develop | cpanm
    # Run the test suite
    $ prove -l

    # Build ./angel-PS1
    $ ./dist

How to do make a patch?
-----------------------

    $ git checkout devel

    # Run angel-PS1 and check that your issue is still on that branch
    $ eval $(perl -Ilib bin/angel-PS1)


    # Prepare a fix (include the issue number in the branch name if an issue
    # already exists)
    $ git checkout -b fix/my-fix
    # Prepare a new feature
    $ git checkout -b feature/my-feature

    # Hack, commit, hack, commit...

    # Check that your changes pass the test suite
    $ prove -l

    # Ready for submission?

    # Fork the project on GitHub (if you haven't yet)

    # Add the remote target for pushes
    $ git remote add github git@github.com:$GITHUB_USER/angel-PS1.git
    # Enable Travis-CI on your fork. See http://travis-ci.org/

    # Check that your local repo is up to date
    $ git fetch
    # Rebase your work on the latest state of `devel`
    $ git rebase upstream/devel

    # Push your commits
    $ git push github fix/my-fix
    $ git push github fix/my-feature

    # Create the pull request on GitHub. Check that Github chose the `devel`
    # branch as the starting point for your branch.


How to make a good pull request?
--------------------------------

1. Check that your Git authorship settings are correct:

        $ git config -l | grep ^user\.

2. All the commits in the pull request must be on the same topic. If instead
   you propose fixes on different topics, use separate branches in your repo
   and make a pull request for each.
3. Good commit messages:
     - first line must be 72 chars max and is a summary of the commit
     - second line must be empty
     - following lines (72 chars max) are optional and take this space freely
       to express what that changes does.
       Use references to GitHub issues number (ex: `#432`) if applicable
4. Use a good title for your pull request.
5. Put details, web links, in the pull request body. Use Markdown fully to
   format the content (see
   [Markdown syntax](http://daringfireball.net/projects/markdown/syntax)).
   For example use triple backquotes for code blocks.


Never, ever, merge the branches `devel` or `release` of the main repo into one
of your own branches. Instead, always rebase your own work on top the `devel`
branch (`git rebase upstream/devel`).

How my patch will be applied?
-----------------------------

Before being applied, your pull request will be reviewed, by the maintainer
and also by other users. You can also help the project by reviewing others
pull requests.

If your patch is accepted it will be applied either:
- by "merging" your branch
- by cherry-picking your commit on top of the `devel` branch. This makes the
  history linear, and so easier to track.

In any case, your authorship will be preserved in the commit.

What if my patch is not applied?
--------------------------------

If you don't even get a review, add a "ping" comment with increasing delay
between pings: 1 week, 2 weeks, then every month.

If a stable version is released while your pull request has still not been
merged on any working branch of the main repo, it would be helpful to ease
the maitainer's work by rebasing your branch on top of the latest `devel`
and push it again to your GitHub repo. Be careful (for example create a
branch or a tag before your rebase) because your may lose all your work in
that process.


Olivier Mengué, maintainer.
http://github.com/dolmen

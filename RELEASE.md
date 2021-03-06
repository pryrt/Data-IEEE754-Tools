[![](https://img.shields.io/cpan/v/Data-IEEE754-Tools.svg?colorB=00CC00 "metacpan")](https://metacpan.org/pod/Data::IEEE754::Tools)
[![](http://cpants.cpanauthors.org/dist/Data-IEEE754-Tools.png "cpan testers")](http://matrix.cpantesters.org/?dist=Data-IEEE754-Tools)
[![](https://img.shields.io/github/release/pryrt/Data-IEEE754-Tools.svg "github release")](https://github.com/pryrt/Data-IEEE754-Tools/releases)
[![](https://img.shields.io/github/issues/pryrt/Data-IEEE754-Tools.svg "issues")](https://github.com/pryrt/Data-IEEE754-Tools/issues)
[![](https://ci.appveyor.com/api/projects/status/a9yylnhnufr2g9ug?svg=true "appveyor build status")](https://ci.appveyor.com/project/pryrt/data-ieee754-tools)
[![](https://travis-ci.org/pryrt/Data-IEEE754-Tools.svg?branch=master "travis build status")](https://travis-ci.org/pryrt/Data-IEEE754-Tools)
[![](https://coveralls.io/repos/github/pryrt/Data-IEEE754-Tools/badge.svg?branch=master "coveralls test coverage")](https://coveralls.io/github/pryrt/Data-IEEE754-Tools?branch=master)

# Releasing Data::IEEE754::Tools

This describes some of my methodology for releasing a distribution.  To help with testing and coverage, I've integrated the [GitHub repo](https://github.com/pryrt/Data-IEEE754-Tools/) with [Travis-CI](https://travis-ci.org/pryrt/Data-IEEE754-Tools) and [coveralls.io](https://coveralls.io/github/pryrt/Data-IEEE754-Tools)

## My Methodology

I use a local svn client to checkout the GitHub repo.  All these things can be done with a git client, but the terminology changes, and I cease being comfortable.

* **Development:**

    * **GitHub:** create a branch

    * **svn:** switch from trunk to branch

    * `prove -l t` for normal tests, `prove -l xt` for author tests
    * use `berrybrew exec` or `perlbrew exec` on those `prove`s to get a wider suite
    * every `svn commit` to the GitHub repo should trigger Travis-CI build suite

* **Release:**

    * **Verify Documentation:**
        * make sure versioning is correct
        * verify POD and README
            * `pod2text lib/Data/IEEE754/Tools.pm README`, then edit so that only
            NAME, DESCRIPTION, COMPATIBILITY, INSTALLATION, AUTHOR, COPYRIGHT, LICENSE
            remain
            * or, with README.pod instead: `podselect -section "NAME|SYNOPSIS|DESCRIPTION|COMPATIBILITY|INSTALLATION|AUTHOR|COPYRIGHT|LICENSE/!IEEE 754 Encoding" lib\Data\IEEE754\Tools.pm > README.pod`, then `pod2markdown README.pod README.md`
            * or `dmake README.md`
        * verify CHANGES (history)

    * **Build Distribution**

            dmake realclean                         # clear out all the extra junk
            perl Makefile.PL                        # create a new makefile
            dmake                                   # copy the library to ./blib/lib...
            dmake distcheck                         # if you want to check for new or removed files
            dmake manifest                          # if distcheck() showed discrepancies
            dmake disttest                          # optional, if you want to verify that make test will work for the CPAN audience
            set MM_SIGN_DIST=1                      # enable signatures for build
            set TEST_SIGNATURE=1                    # verify signatures during `disttest`
            perl Makefile.PL && dmake distauthtest  # recreate Makefile and re-run distribution test with signing & test-signature turned on
            set TEST_SIGNATURE=                     # clear signature verification during `disttest`
            dmake dist                              # actually make the tarball
            dmake realclean                         # clean out this directory
            set MM_SIGN_DIST=                       # clear signatures after build

    * **svn:** final commit of the development branch

    * **svn:** switch back to trunk (master) repo

    * **GitHub:** make a pull request to bring the branch back into the trunk
        * This should trigger Travis-CI approval for the pull request
        * Once Travis-CI approves, need to approve the pull request, then the branch will be merged back into the trunk
        * If that branch is truly done, delete the branch using the pull-request page (wait until AFTER `svn switch`, otherwise `svn switch` will fail)

    * **GitHub:** [create a new release](https://help.github.com/articles/creating-releases/):
        * Releases > Releases > Draft a New Release
        * tag name = `v#.###`
        * release title = `v#.###`

    * **PAUSE:** [upload distribution tarball to CPAN/PAUSE](https://pause.perl.org/pause/authenquery?ACTION=add_uri) by browsing to the file on my computer.
        * Watch <https://metacpan.org/author/PETERCJ> and <http://search.cpan.org/~petercj/> for when it updates
        * Watch CPAN Testers

    * **GitHub:** Clear out any [issues](https://github.com/pryrt/Data-IEEE754-Tools/issues/) that were resolved by this release


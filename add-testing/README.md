# debian-add-testing


Taken from [this serverfault answer](http://serverfault.com/a/382101) by [Brendan Byrd](http://serverfault.com/users/106037/brendan-byrd). A copy of the answer has been provided below.

Note: A small modification provided by [this answer](http://serverfault.com/a/653552) has been made.

Many people seem to be afraid of mixing stable with testing, but frankly, testing is fairly stable in its own right, and with proper preferences and solution checking, you can avoid the "stability drift" that puts your core packages on the unstable path.

*"Testing is fairly stable??"*, you ask.  Yes.  In order for a package to migrate from unstable to testing, it has to have zero open bugs for 10 consecutive days.  Chances are that, especially for the more popular packages, somebody is going to submit a bug report for an unstable version if something is wrong.

Even if you don't want to mix the environments, it's still nice to have the option there in case you run into some thing that requires a newer version than what is in stable.  

**Here's what I recommend for setting this up:**

First, create the following files in `/etc/apt/preferences.d`:

**`security.pref`**:

    Package: *
    Pin: release l=Debian-Security
    Pin-Priority: 1000

**`stable.pref`**:

    Package: *
    Pin: release a=stable
    Pin-Priority: 900

**`testing.pref`**:

    Package: *
    Pin: release a=testing
    Pin-Priority: 750

**`unstable.pref`**:

    Package: *
    Pin: release a=unstable
    Pin-Priority: 50

**`experimental.pref`**:

    Package: *
    Pin: release a=experimental
    Pin-Priority: 1

(Don't be afraid of the unstable/experimental stuff here.  The priorities are low enough that it's never going to automatically install any of that stuff.  Even the testing branch will behave, as it's only going to install the packages you want to be in testing.)

Now, creating a matching set for `/etc/apt/sources.list.d`:

**`security.list`**:

    deb     http://security.debian.org/         stable/updates  main contrib non-free
    deb     http://security.debian.org/         testing/updates main contrib non-free

**`stable.list`**:

    deb     http://mirror.steadfast.net/debian/ stable main contrib non-free
    deb-src http://mirror.steadfast.net/debian/ stable main contrib non-free
    deb     http://ftp.us.debian.org/debian/    stable main contrib non-free
    deb-src http://ftp.us.debian.org/debian/    stable main contrib non-free

**`testing.list`**: Same as `stable.list`, except with `testing`.

**`unstable.list`**: Same as `stable.list`, except with `unstable`.

**`experimental.list`**: Same as `stable.list`, except with `experimental`.

You can replace the steadfast.net mirror with whatever you want.  I'd recommend using `netselect-apt` to figure out the fastest mirror, and use that for your first choice.  The `ftp.us.debian.org` can be used as a backup.  It's also important to use the terms `stable`, `testing`, `unstable`, etc., instead of `squeeze`, `wheezy`, `sid`, etc., since `stable` is a moving target and when it comes time to upgrade to the latest stable, apt/aptitude will figure that out automatically.

You can also add a `oldstable` in `sources.lists.d` and `preferences.d` (use a priority of 1), though this moniker will tend to expire and disappear before the next stable cycle.  In cases like that, you can use `http://archive.debian.org/debian/` and "hardcode" the Debian version (etch, lenny, etc.).

To install the testing version of a package, simply use `aptitude install lib-foobar-package/testing`, or just jump into aptitude's GUI and select the version inside of the package details (hit enter on the package you're looking at).

If you get complaints of package conflicts, look at the solutions first.  In most cases, the first one is going to be "don't install this version".  Learn to use the per-package accept/reject resolver choices.  For example, if you're installing foobar-package/testing, and the first solution is "don't install foobar-package/testing", then mark that choice as rejected, and the other solutions will never veer to that path again.  In cases like these, you'll probably have to install a few other testing packages.

If it's getting too hairy (like it's trying to upgrade libc or the kernel or some other huge core system), then you can either reject those upgrade paths or just back out of the initial upgrade altogether.  Remember that it's only going to upgrade stuff to testing/unstable if you allow it to.
RuneScape Unix/Linux Client (rsu-client)
==========

This is the git repository for the RSU-Client, all development happens
here before updates are pushed to the client and other repositories.
This repository does not include the jawt.dll file neccessary for running
the game through Wine, however you can run it natively.
If you require Wine support you should instead install the stable client
from one of the following repositories:

* [ArchLinux AUR Repository](https://aur.archlinux.org/packages.php?ID=59362 "ArchLinux AUR Repository")
* [Launchpad Ubuntu/Mint PPA](https://launchpad.net/~hikariknight/+archive/unix-runescape-client/ "Launchpad PPA")
* [Universal tar.gz Archive](https://dl.dropbox.com/u/11631899/opensource/Perl/unix-runescape-client.tar.gz "Universal tar.gz Archive")



About the Project
----------
Development of the RSU-Client started in late October 2011.
Back then it was designed as a Linux port of the
Official RuneScape Client for Windows.

It quickly gained support for the windows client __runescape.prm__ file
and its own __settings.conf__ file which would let users enable and disable
built-in fixes to make the game work just as good on Linux as it does on
Windows.

In December 2011 the RSU-Client became a Unix client, working on almost
any Unix platform with Perl and Java installed, and in January 2012
The RSU-Client was able to run on Windows too!

Later the RSU-Client got its own graphical settings editor for the
__settings.conf__ and __runescape.prm__ with a jagexcache cleaner included.

And finally the client got support for modules, which lets anyone
add their own functionality to the client
(although not inside the client window due to license restrictions!)


Features
----------
* Optimized runescape.prm file (using 512mb for java heap space and 2mb stacksize by default instead of 256mb heap)
* Built-in fixes (Uses Java6 instead of Java7 on Mac OSX if Java6 exists, and fixes opengl with java7 on Linux)
* Settings editor (Easily edit the runescape.prm or settings.conf to tweak the client to optimal performance) - _requires WxPerl_
* Working Language Settings! (Previously the language settings would not work on Linux on the client)
* Ability to change which Java to run the Client with
* Crossplatform! (works natively in Windows, MacOSX and Linux, may also run on Solaris and BSD but with limited support)
* Integrates with both Mac and Linux (the __install-desktop-icons__ script makes a launcher for the client in the systems native format)
* Built in updater! (Lets you easily update __jagexappletviewer.jar__ easily whenever jagex updates their client!)
* Script updater! (If you use the tar.gz archive version, it will let you update the scripts through the updater)
* Module support (Lets you make your own modules to add functionality to the script part of the client Ex: calculators)
* Works on several architectures (64bit/amd64, 32bit/i386, armel, lpia, arm32, arm64, sparc32, sparc64) - _NOTE: arm support only tested on Linux, as perl is not compiled for arm on windows yet!_
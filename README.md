RuneScape Unix/Linux Client (rsu-client)
==========

This is the git repository for the RSU-Client, all development happens
here before updates are pushed to the client and other repositories.
This repository does not include the jawt.dll file neccessary for running
the game through Wine, however you __can run the game__ natively __without that file__.
If you require Wine support you should instead install the stable client
from one of the following repositories:

__Linux Repositories__
* [ArchLinux AUR Repository](https://aur.archlinux.org/packages/unix-runescape-client/ "ArchLinux AUR Repository")
* [Launchpad Ubuntu/Mint PPA](https://launchpad.net/~hikariknight/+archive/unix-runescape-client/ "Launchpad PPA")
* [Repository for Centos, Fedora, RHEL, OpenSuse, SL and SLE](https://software.opensuse.org/download.html?project=home%3Afusion809&package=unix-runescape-client)

__Installers (Powered by [BitRock](http://bitrock.com/))__
* [Installers](https://github.com/HikariKnight/rsu-client/releases/latest)

*NOTE: The installers require an active internet connection to download the latest client files.*

*DROPBOX NOTE: Dropbox links are no longer available as dropbox removed my ability to make the installers public.*

__Universal Archive/Zipped versions (If you dont want an installer)__
* [Universal tar.gz Archive](https://github.com/HikariKnight/rsu-client/archive/master.tar.gz "Universal tar.gz Archive")
* [Universal zip Archive](https://github.com/HikariKnight/rsu-client/archive/master.zip "Universal zip Archive")

*__[RuneScape](http://runescape.com) is a registred trademark of [Jagex Ltd](http://jagex.com).__*

Install instructions
----------
__Installation on Debian__

1. Open the Terminal program and type in the following commands:
```bash
echo "deb http://ppa.launchpad.net/hikariknight/unix-runescape-client/ubuntu trusty main" | sudo tee -a /etc/apt/sources.list
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 9BA73CFA
sudo apt-get update && sudo apt-get install unix-runescape-client
```

__Installation on Ubuntu or Linux Mint__

* Open the Terminal program and type in the following command:
```bash
sudo apt-add-repository ppa:hikariknight/unix-runescape-client
```
* Then once that is done type in the following commands:
```bash
sudo apt-get update && sudo apt-get install unix-runescape-client
```

__Installation on ArchLinux__

* Open the Terminal program and type in the following command:
```bash
yaourt -S unix-runescape-client
```

__Installation on Fedora__

* Install dependent packages
```bash
sudo dnf install perl "perl(List::MoreUtils)" "perl(Config::IniFiles)" "perl(Archive::Extract)" "perl-Wx"
```

* Download and extract the universal archive.

__Installation on openSUSE__

* Install dependent packages
```bash
sudo zypper in perl perl-List-MoreUtils perl-Config-IniFiles perl-Archive-Extract perl-Wx
```

* Download and extract the universal archive.

__Installation on Gentoo Linux__

* Follow JohnPeel's guide [here](https://github.com/JohnPeel/dgby-overlay/wiki/Installing-rsu-client-on-Gentoo) on how to install the RSU-Client on Gentoo

or:

* Install [Layman](https://wiki.gentoo.org/wiki/Layman), if it is not already installed, with:
```bash
sudo emerge -av layman
```
* Add the [`sabayon`](https://github.com/Sabayon/for-gentoo) overlay with:
```bash
sudo layman -a sabayon
```
* Emerge the RSU Client:
```bash
sudo emerge -av games-rpg/unix-runescape-client
```

__Installation on Sabayon__

Provided the sabayonlinux.org repository is enabled, merely run:
```bash
sudo equo i games-rpg/unix-runescape-client
```

__Other Linux systems__

Please use the bitrock installer or universal archive.
The RSU-Client is not officially supported on other Linux systems
due to the lack of package maintainers for those systems.
Also the RSU-Client may not work correctly on other Linux systems due to missing packages

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

![alt text](http://i.imgur.com/zWn4sSQ.png "RSU Client Launcher Window")


Features
----------
* Optimized runescape.prm file (using 512mb for java heap space and 2mb stacksize by default instead of 256mb heap)
* MultiCore loading of map chunks
* Launcher that contains the RuneScape NewsFeed
* Able to launch both the main game and oldschool, without the need to mess with files!
* Built-in fixes (Uses Java6 instead of Java7 on Mac OSX if Java6 exists, and fixes opengl with java7 on Linux)
* Settings editor (Easily edit the runescape.prm or settings.conf to tweak the client to optimal performance) - _requires WxPerl_
* Working Language Settings! (Previously the language settings would not work on Linux on the client)
* Ability to change which Java to run the Client with
* Crossplatform! Works natively in Windows, MacOSX and Linux (may also run on Solaris, ChromeOS and BSD __but with no testing or support from me__)
* Integrates with both Mac and Linux (the __install-desktop-icons__ script makes a launcher for the client in the systems native format)
* Built in updater! (Lets you easily update __jagexappletviewer.jar__ easily whenever jagex updates their client!)
* Script updater! (If you use the tar.gz archive version, it will let you update the scripts through the updater)
* Module support (Lets you make your own modules to add functionality to the script part of the client Ex: calculators)
* Tested and works on several architectures 64bit/amd64/x86_64 and 32bit/x86 (may work on armel, lpia, arm32, arm64, sparc32, sparc64 but without support from me due to lack of access to said architecture and may lack working libraries for the client or scripts)


Contribution
-----------
If you want to contribute to the project you can do that in several ways.
Either do a pull request and contribute through that (make sure you only commit to the development branch!)

If you contribute code you can also get your name or nickname in the contributors list below (if you want)

Developers, Contributors and people that have helped the project
-----------
* HikariKnight - _Developer_
* [ivanpu](https://github.com/ivanpu) - _Aur Repository_
* [fusion809](https://github.com/fusion809) - _RPM based Repository_
* chroot - _force pulseaudio_
* [Ethoxyethaan (nick.hermans.be+rsu@gmail.com)](mailto:nick.hermans.be+rsu@gmail.com) - _original bash script for launching the jagexappletviewer.jar on Linux_
* Jmb71 - _findjavalib regex_
* Test6125 - _stacksize fix in prm_
* [Fallen_Unia](https://github.com/Unia) - _Zenity support in the Updater_
* Kalio - _Portable jagexcache_
* [loganom](https://github.com/loganom) - Patches and bugfixes
* [Salubrious](https://twitter.com/salubriousrs) - FunOrb support
* [JohnPeel](https://github.com/JohnPeel) - Gentoo repository
* [byadamsbeard](https://www.reddit.com/user/byadamsbeard)
* [Deranext](https://www.reddit.com/user/Deranext)
* [RS Linux Community](http://services.runescape.com/m=forum/forums.ws?25,26,5,65329684,goto,99999) - Without you people I would not be developing this client!
* [Jagex](http://jagex.com) - _Making the official client and providing the sourcecode (plus adding the rsu client to_ [downloads](http://runescape.com/downloads)_!)_

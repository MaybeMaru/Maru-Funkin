# Friday Night Funkin
This is the repository for Friday Night Funkin, a game originally made for Ludum Dare 47 "Stuck In a Loop".
Play the Ludum Dare prototype here: https://ninja-muffin24.itch.io/friday-night-funkin
Play the Newgrounds one here: https://www.newgrounds.com/portal/view/770371
Support the project on the itch.io page: https://ninja-muffin24.itch.io/funkin

IF YOU MAKE A MOD AND DISTRIBUTE A MODIFIED / RECOMPILED VERSION, YOU MUST OPEN SOURCE YOUR MOD AS WELL

## Credits / shoutouts
### Funkin' Team
- [ninjamuffin99](https://twitter.com/ninja_muffin99) - Programmer
- [PhantomArcade3K](https://twitter.com/phantomarcade3k) - Animation
- [Evilsk8r](https://twitter.com/evilsk8r) - Art
- [Kawaisprite](https://twitter.com/kawaisprite) - Musician

This game was made with love to Newgrounds and its community. Extra love to Tom Fulp.

## Build instructions

THESE INSTRUCTIONS ARE FOR COMPILING THE GAME'S SOURCE CODE!!!

IF YOU WANT TO JUST DOWNLOAD AND INSTALL AND PLAY THE GAME NORMALLY, GO TO [ITCH.IO](https://ninja-muffin24.itch.io/funkin) TO DOWNLOAD THE GAME FOR PC, MAC, AND LINUX!!

IF YOU WANT TO COMPILE THE GAME YOURSELF, CONTINUE READING!!!

### Installing the Required Programs

First, you need to install Haxe and HaxeFlixel. I'm too lazy to write and keep updated with that setup (which is pretty simple).

1. [Install Haxe 4.2.5](https://haxe.org/download/version/4.2.5/)
2. [Install HaxeFlixel](https://haxeflixel.com/documentation/install-haxeflixel/)

Other installations you'd need are the additional libraries, a fully updated list will be in `Project.xml` in the project root. Currently, these are all of the things you need to install:

1. Download [git-scm](https://git-scm.com/downloads). Works for Windows, Mac, and Linux, just select your build.
2. Follow instructions to install the application properly.
3. Run these commands in the CMD

```
haxelib install flixel 5.3.0
haxelib install flixel-addons
haxelib install flixel-ui
haxelib install hscript
haxelib git discord_rpc https://github.com/Aidan63/linc_discord-rpc
```
You should have everything ready for compiling the game!

### Compiling game

NOTE: If you see any messages relating to deprecated packages, ignore them. They're just warnings that don't affect compiling

Once you have all those installed, it's pretty easy to compile the game. You just need to run `lime test html5 -debug` in the root of the project to build and run the HTML5 version. (command prompt navigation guide can be found here: [https://ninjamuffin99.newgrounds.com/news/post/1090480](https://ninjamuffin99.newgrounds.com/news/post/1090480))

To run it from your desktop (Windows, Mac, Linux) it can be a bit more involved. For Linux, you only need to open a terminal in the project directory and run `lime test linux -debug` and then run the executable file in export/release/linux/bin. For Windows, you need to install Visual Studio Community 2019. While installing VSC, don't click on any of the options to install workloads. Instead, go to the individual components tab and choose the following:

* MSVC v142 - VS 2019 C++ x64/x86 build tools
* Windows SDK (10.0.17763.0)

Once that is done you can open up a command line in the project's directory and run `lime test windows -debug`. Once that command finishes (it takes forever even on a higher end PC), you can run FNF from the .exe file under export\release\windows\bin

As for Mac, 'lime test mac -debug' should work, if not the internet surely has a guide on how to compile Haxe stuff for Mac.

### Additional guides
- [Command line basics](https://ninjamuffin99.newgrounds.com/news/post/1090480)
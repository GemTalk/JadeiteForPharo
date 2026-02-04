Jadeite for Pharo is an IDE for GemStone Smalltalk application development in Pharo. Jadeite for Pharo connects to a GemStone Rowan repository to manage code in Rowan projects, using git repositories to store tonel-format files on disk. Jadeite for Pharo can also be used without Rowan, to develop code that can be managed manually using fileout, and in the future in Metacello/Monticello packages. 

Jadeite for Pharo has basic functionality complete but is alpha-level code under active development. Help and support are provided by the GemTalk's customer forum at gemstone-smalltalk@lists.gemtalksystems.com, or the GLASS forum at glass@lists.gemtalksystems.com.  Users of Jadeite for Pharo should exercise due caution for unexpected issues and unknown bugs. 

GemStone/Rowan server setup and Jadeite /Pharo client setup instructions are provided below: 
* [Setup instructions for Jadeite using Rowan](#using-jadeite-for-pharo-with-rowan)
* [Setup instructions for Jadeite without Rowan](#using-jadeite-for-pharo-without-rowan)

These instructions assume basic understanding of GemStone server setup. For more on GemStone server setup, see the Installation Guides on the [GemTalk website](https://gemtalksystems.com/products/gs64/versions37x/).

# Using Jadeite For Pharo with Rowan

With a GemStone Rowan server, Jadeite manages rowanized code in Rowan projects and packages which are stored on disk in an underlying git repository, which handles  version control. Jadeite provides some basic git operations, and independent third party git tools can be used to manage the git repositories themselves. 

## GemStone Server Setup - Rowan 3

GemStone v3.7.5 includes a Rowan3 extent, which must be used to provide the Rowan server environment. The tools to install Rowan3 into an existing extent are not yet available. 

To setup a GemStone Rowan server: 
- Install GemStone v3.7.5 
- Set the path and $GEMSTONE environment variables
- Create a GemStone/Rowan server using extent `$GEMSTONE/bin/extent0.rowan3.dbf` from the GemStone/64 product distribution. 
- Start up the Stone and NetLDI

## Client setup - Pharo and Jadeite
### Make git clones

- Select or create a directory for your git clones. It is recommended, but not required, to define the environment variable $ROWAN_PROJECTS_HOME to refer to this directory. 
- On the client, clone the required projects, or update checkouts to the latest on the correct branch. The required projects are:
    * JadeiteForPharo, branch main375 
    * RemoteServiceReplication, branch main-v2
    * PharoGemStoneFFI, branch main   

```
  git clone -b main375 https://github.com/GemTalk/JadeiteForPharo
  git clone -b main-v2 https://github.com/GemTalk/RemoteServiceReplication
  git clone -b main https://github.com/GemTalk/PharoGemStoneFFI
```

### Setup clientlibs directory
- Select or create a directory for the clientlibs.
- Ensure that this directory contains the correctly structured clientlibs for 3.7.5. Jadeite expects a directory structure with the shared libraries under &lt;clientLibsDir&gt;/&lt;versionNumber&gt;/64bit|32bit/   
	These can be downloaded from the GemTalk website; the zip contains a folder with the version number, which can be copied into your clientlibs directory.
**The unreleased v3.7.5 libraries are not publically available; contact GemTalk for alpha or prerelease libraries**.
   * Linux: https://downloads.gemtalksystems.com/pub/GemStone64/3.7.5/GemStoneClientLibs3.7.5-x86_64.Linux.zip   
   * Windows: https://downloads.gemtalksystems.com/pub/GemStone64/3.7.5/GemStoneClientLibs3.7.5-x86.Windows_NT.zip
   * Mac: https://downloads.gemtalksystems.com/pub/GemStone64/3.7.5/GemStoneClientLibs3.7.5-arm64.Darwin.dmg


### Install Pharo and create a Pharo image
- Download the launcher or launcher installer for the given platform from https://pharo.org/download, and install.
- Run pharo-launcher or PharoLauncher to open the Launcher.
- Create an image: Click on ✲ New, and select Official Distributions and Pharo 13.0 - 64bit, and press the ✲Create Image button.

### Import Jadeite into Pharo
- After creating the pharo image, copy startup.st from the root directory of the JadeiteForPharo project checkout into the new Pharo image directory.
- Restart the new Pharo image.
    * If $ROWAN_PROJECTS_HOME is set, startup.st installs Jadeite for Pharo from the local git repository clones in that directory.
    * If $ROWAN_PROJECTS_HOME is not set, startup.st opens a file dialog allowing the user to choose the directory containing the clones.

Upon successful completion of startup.st, a Jadeite Connection Launcher window will open.

  - Save your image

## Log in

The Jadeite Connection Launcher can be opened using the Library/Jadeite Launcher menu item.
In the launcher, fill in the required fields and connect.

With Rowan, the System Browser displayes classes organized by Project and Package or SymbolDictionary.


----------------------------------------------------------------------
# Using Jadeite For Pharo without Rowan

Jadeite for Pharo can connect to a standard GemStone repository (based on extent0.dbf), by installing the Rowan stub. This provides a way to view and edit 
GemStone smalltalk code but Rowan is not present, and there is no source code management.  You may file in and file out code to an external source code
management system.

## Server setup - GemStone and Rowan

 -   Locate or create a GemStone v3.7.5 server installation.
 -   Set the GEMSTONE environment variable and path to this install.
 -   Start stone and netldi
 -   Define a .topazini file with the login parameters for this stone as SystemUser.
 -   In the same directory as the .topazini, execute:   
     `   os> $GEMSTONE/examples/jadeite/bin/installRowanStub_topaz.sh`

## Client setup - Pharo and Jadeite
### Make git clones

- select or create a directory for your git clones. It is recommended, but not required, to define the environment variable $ROWAN_PROJECTS_HOME to refer to this directory. 
- On the client, clone the required projects, or update checkouts to the latest on the correct branch. The required projects are:
    * JadeiteForPharo, branch main375 
    * RemoteServiceReplication, branch main-v2
    * PharoGemStoneFFI, branch main   

```
  git clone -b main375 https://github.com/GemTalk/JadeiteForPharo
  git clone -b main-v2 https://github.com/GemTalk/RemoteServiceReplication
  git clone -b main https://github.com/GemTalk/PharoGemStoneFFI
```

### Setup clientlibs directory
- Select or create a directory for the clientlibs.
- Ensure that this directory contains the correctly structured clientlibs for 3.7.5. Jadeite expects a directory structure with the shared libraries under &lt;clientLibsDir&gt;/&lt;versionNumber&gt;/64bit|32bit/   
	These can be downloaded from the GemTalk website; the zip contains a folder with the version number, which can be copied into your clientlibs directory.
**The unreleased v3.7.5 libraries are not publically available; contact GemTalk for alpha or prerelease libraries**.
   * Linux: https://downloads.gemtalksystems.com/pub/GemStone64/3.7.5/GemStoneClientLibs3.7.5-x86_64.Linux.zip   
   * Windows: https://downloads.gemtalksystems.com/pub/GemStone64/3.7.5/GemStoneClientLibs3.7.5-x86.Windows_NT.zip
   * Mac: https://downloads.gemtalksystems.com/pub/GemStone64/3.7.5/GemStoneClientLibs3.7.5-arm64.Darwin.dmg


### Install Pharo and create a Pharo image
- Download the launcher or launcher installer for the given platform from https://pharo.org/download, and install.
- Run pharo-launcher or PharoLauncher to open the Launcher.
- Create an image: Click on ✲ New, and select Official Distributions and Pharo 13.0 - 64bit, and press the ✲Create Image button.

### Import Jadeite into Pharo
- After creating the pharo image, copy startup.st from the root directory of the JadeiteForPharo project checkout into the new Pharo image directory.
- Restart the new Pharo image.
    * If $ROWAN_PROJECTS_HOME is set, startup.st installs Jadeite for Pharo from the local git repository clones in that directory.
    * If $ROWAN_PROJECTS_HOME is not set, startup.st opens a file dialog allowing the user to choose the directory containing the clones.

Upon successful completion of startup.st, a Jadeite Connection Launcher window will open.
  - Save your image

## Log in

The Jadeite Connection Launcher can be opened using the Library/Jadeite Launcher menu item.
In the launcher, fill in the required fields and connect.

Without Rowan, the System Browser displayes classes organized by SymbolDictionary and Class Category.




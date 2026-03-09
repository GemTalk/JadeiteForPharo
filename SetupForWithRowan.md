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

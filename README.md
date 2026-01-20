# Disclaimer!!! Jadeite for Pharo is still in active development
* No official support provided.
* Any code imported (such as a user's project) must be "rowanized". Filein and Fileout have limited support; see the Jadeite Help (on the Tools menu) for details.
* Jadeite for Pharo is not traits aware.
* Internal GemStone users: see the wiki page Jadeite/Rowan_for_GemStone_Server_Development

# JadeiteForPharo
IDE for GemStone Smalltalk application development in Pharo.

Jadeite for Pharo is early alpha-quality code under development, with known issues.

## Setup the GemStone server

This branch of Jadeite For Pharo should work with GemStone 3.7.4.1 or 3.7.5. Version 3.7.5 is unreleased and not publically available.

- Install the GemStone server, and set the path and $GEMSTONE environment variable.
- Create a GemStone/Rowan server using extent `extent0.rowan3.dbf` from the GemStone/64 product bin subdirectory
- Set the env variable $ROWAN_PROJECTS_HOME to the directory in which you will clone the github projects. 
- Clone these git projects to $ROWAN_PROJECTS_HOME on your local server disk:
	* RemoteServiceReplication, branch main-v2:   
            `git clone -b main-v2 https://github.com/GemTalk/RemoteServiceReplication`
 	* RowanClientServices, branch main3741 or main375; one of the following:   
            `git clone -b main3741 https://github.com/GemTalk/RowanClientServices RowanClientServicesV3`   
            `git clone -b main375 https://github.com/GemTalk/RowanClientServices RowanClientServicesV3`
	* Announcements:   
           `git clone -b main https://github.com/GemTalk/Announcements`

- Setup a .topazini file for SystemUser with your Stone's login parameters
- Start up the Stone and NetLDI
- Connect to the latest RowanClientServices code by running the followings scripts, from a directory with above topazini file
	* `$GEMSTONE/rowan3/bin/installProject.stone file:$ROWAN_PROJECTS_HOME/RemoteServiceReplication/rowan/specs/RemoteServiceReplication.ston --projectsHome=$ROWAN_PROJECTS_HOME`
	* `$GEMSTONE/rowan3/bin/installProject.stone file:$ROWAN_PROJECTS_HOME/RowanClientServices/rowan/specs/RowanClientServicesV3.ston --projectsHome=$ROWAN_PROJECTS_HOME`

## To load JadeiteForPharo into a Pharo image:

- Install Pharo 12 Smalltalk. Jadeite for Pharo currently is only compatible with Pharo 12.

- The env variable $ROWAN_PROJECTS_HOME should be set to the directory containing the checkouts of github clones on local disk.  If you will run the client on the same node as the host, you may use the git repositories previously cloned.
- Clone these git projects to $ROWAN_PROJECTS_HOME on your local disk: 
	* JadeiteForPharo, branch main3741 or main375; one of the following:   
          `git clone -b main3741 https://github.com/GemTalk/JadeiteForPharo`   
          `git clone -b main375 https://github.com/GemTalk/JadeiteForPharo`
	* PharoGemStoneFFI, branch main:   
	  `git clone -b main https://github.com/GemTalk/PharoGemStoneFFI`
	* RemoteServiceReplication, branch main-v2:   
         `git clone -b main-v2 https://github.com/GemTalk/RemoteServiceReplication`

- setup a clientlibs directory containing the correct version shared libraries. Jadeite expects a directory structure with the shared libraries under &lt;clientLibsDir&gt;/&lt;versionNumber&gt;/64bit|32bit/   
The unreleased v3.7.5 libraries are not publically available; to download 3.7.4.1:   

   * Linux: https://downloads.gemtalksystems.com/pub/GemStone64/3.7.4.1/GemStoneClientLibs3.7.4.1-x86_64.Linux.zip   
   * Windows: https://downloads.gemtalksystems.com/pub/GemStone64/3.7.4.1/GemStoneClientLibs3.7.4.1-x86.Windows_NT.zip
   * Mac: https://downloads.gemtalksystems.com/pub/GemStone64/3.7.4.1/GemStoneClientLibs3.7.4.1-arm64.Darwin.dmg

- create a new Pharo 12 image.
- Copy `startup.st` from the root directory of the JadeiteForPharo project checkout into the Pharo image directory.
- Startup the new Pharo image.
	* If $ROWAN_PROJECTS_HOME is set, `startup.st` will attempt to install Jadeite for Pharo from the local git repository clones in that directory.
 	* If $ROWAN_PROJECTS_HOME is not set, `startup.st` will open a file dialog allowing the user to choose the directory
  * Upon successful completion of `startup.st`, a Jadeite Connection Launcher window will open. 

# Using JadeiteForPharo without Rowan

Jadeite for Pharo can connect to a standard GemStone repository (based on extent0.dbf), by installing the Rowan stub. This provides a way to view and edit 
GemStone smalltalk code but Rowan is not present, and there is no source code management.  You may file in and file out code to an external source code
management system.

## Server setup - GemStone and Rowan

 -   Locate or create a GemStone v3.7.5 server installation.
 -   Set the GEMSTONE environment variable and path to this install.
 -   Start stone and netldi
 -   Define a .topazini file with the login parameters for this stone as SystemUser.
 -  In the same directory as the .topazini, execute:   
     `   os> $GEMSTONE/examples/jadeite/bin/installRowanStub_topaz.sh`

## Client setup - Pharo and Jadeite
### Make git clones

- On the client, clone the required projects, or update checkouts to the latest on the correct branch. The required projects are:
    * JadeiteForPharo, branch main375
    * RemoteServiceReplication, branch main-v2
    * PharoGemStoneFFI, branch main   

```
  git clone -b main375 https://github.com/GemTalk/JadeiteForPharo
  git clone -b main-v2 https://github.com/GemTalk/RemoteServiceReplication
  git clone -b main https://github.com/GemTalk/PharoGemStoneFFI
```

- You can define the environment variable $ROWAN_PROJECTS_HOME to refer to this directory, but it is not required.

### Setup clientlibs directory
- Select or create a directory for the clientlibs.
- Ensure that this directory contains the clientlibs for 3.7.5. Jadeite expects a directory structure with the shared libraries under <clientLibsDir>/<3.7.5>/64bit/. 
	These can be downloaded from the GemTalk website; the zip contains a folder with the version number, which can be copied into your clientlibs directory.

### Install Pharo and create a Pharo image
- Download the launcher or launcher installer for the given platform from https://pharo.org/download, and install.
- Run pharo-launcher or PharoLauncher to open the Launcher.
- Create an image: Click on ✲ New, and select Official Distributions and Pharo 12.0 or 13.0, and press the Create Image button.

### Import Jadeite into Pharo
- After creating the pharo image, copy startup.st from the root directory of the JadeiteForPharo project checkout into the new Pharo image directory.
- Start your Pharo image.
    * If $ROWAN_PROJECTS_HOME is set, startup.st will attempt to install Jadeite for Pharo from the local git repository clones in that directory.
    * If $ROWAN_PROJECTS_HOME is not set, startup.st will open a file dialog allowing the user to choose the directory

Upon successful completion of startup.st, a Jadeite Connection Launcher window will open.

  - Save your image

## Log in
Use the Library/Jadeite Launcher menu item to open a launcher and fill in the required fields. 



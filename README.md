# Disclaimer!!! Jadeite for Pharo is still in active development
* No official support provided.
* Any code imported (such as a user's project) must be "rowanized". Filein and Fileout have limited support; see the Jadeite Help (on the Tools menu) for details.
* Jadeite for Pharo is not traits aware.

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
           `git clone https://github.com/GemTalk/Announcements`

- Setup a .topazini file for SystemUser with your Stone's login parameters
- Start up the Stone and NetLDI
- Connect to the latest RowanClientServices code by running the followings scripts from a directory with above topazini file
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
- Shut down and restart your Pharo image.
	* If $ROWAN_PROJECTS_HOME is set, `startup.st` will attempt to install Jadeite for Pharo from the local git repository clones in that directory.
 	* If $ROWAN_PROJECTS_HOME is not set, `startup.st` will open a file dialog allowing the user to choose the directory
  * Upon successful completion of `startup.st`, a Jadeite Connection Launcher window will open. 

## Using JadeiteForPharo without Rowan
JadeiteForPharo is usable without Rowan if code is loaded correctly into a GemStone image. This is still under development. 

- To enable Jadeite for Pharo without Rowan:
	* Open a Settings Browser in Pharo.
 	* Uncheck Jadeite for Pharo>Rowan Available


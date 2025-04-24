# Disclaimer!!! Jadeite for Pharo is still in active development
* No official support provided.
* Any code imported (such as a user's project) must be "rowanized". Filein and Fileout have limited support; see the Jadeite help for details.
* Only SystemUser is supported currently.
* Jadeite for Pharo is not traits aware.

# JadeiteForPharo
IDE for GemStone Smalltalk application development in Pharo

The current Jadeite for Pharo is a first alpha release with known issues.

## Setup the GemStone server

Jadeite For Pharo is only tested for use with GemStone 3.7.2. 

- Install GemStone 3.7.2, and set the path and $GEMSTONE environment variable.
- Create a GemStone/Rowan server using extent `extent0.rowan3.dbf` from the GemStone/64 3.7.2 release directory
- Set the env variable $ROWAN_PROJECTS_HOME to the directory in which you will clone the github projects. 
- Clone these git projects to $ROWAN_PROJECTS_HOME on your local server disk:
	* RemoteServiceReplication, branch main-v2, `git clone -b main-v2 https://github.com/GemTalk/RemoteServiceReplication`
 	* RowanClientServices, branch JfpAlpha372, `git clone -b JfpAlpha372 https://github.com/GemTalk/RowanClientServices.git RowanClientServices`
	* Announcements, `git clone https://github.com/GemTalk/Announcements`

- Setup a .topazini file for SystemUser with your Stone's login parameters 
- Connect to the latest RowanClientServices code by running the followings scripts from a directory with above topazini file
	* `$GEMSTONE/rowan3/bin/installProject.stone file:$ROWAN_PROJECTS_HOME/RemoteServiceReplication/rowan/specs/RemoteServiceReplication.ston --projectsHome=$ROWAN_PROJECTS_HOME`
	* `$GEMSTONE/rowan3/bin/installProject.stone file:$ROWAN_PROJECTS_HOME/RowanClientServicesV3/rowan/specs/RowanClientServices.ston --projectsHome=$ROWAN_PROJECTS_HOME`

## To load JadeiteForPharo into a Pharo image:

- Install Pharo 12 Smalltalk.
  * Jadeite for Pharo only works with Pharo 12
  * Recommended build -
    * Pharo-12.0.0+SNAPSHOT.build.1546.sha.30427d35e51ff0351e1dc860306faf36d9d8931c (64 Bit)

- The env variable $ROWAN_PROJECTS_HOME must be set to the directory containing the checkouts of github clones on local disk.  If you will run the client on the same node as the host, you may use the git repositories previously cloned.
- Clone these git projects to $ROWAN_PROJECTS_HOME on your local disk: 
	* JadeiteForPharo, branch JfpAlpha372, `git clone -b JfpAlpha372 https://github.com/GemTalk/JadeiteForPharo`
	* PharoGemStoneFFI, branch main, `git clone -b main https://github.com/GemTalk/PharoGemStoneFFI`
	* RemoteServiceReplication, branch main-v2, `git clone -b main-v2 https://github.com/GemTalk/RemoteServiceReplication`
 	* RowanClientServices, branch JfpAlpha372, `git clone -b JfpAlpha372 https://github.com/GemTalk/RowanClientServices`

- setup a clientlibs directory containing 3.7.2 shared libraries\
Download for Linux:\
https://downloads.gemtalksystems.com/pub/GemStone64/3.7.2/GemStoneClientLibs3.7.2-x86_64.Linux.zip\
...or download for Windows:\
https://downloads.gemtalksystems.com/pub/GemStone64/3.7.2/GemStoneClientLibs3.7.2-x86.Windows_NT.zip.

- create a new Pharo 12 image.
- Copy `startup.st` from the root directory of the JadeiteForPharo project checkout into the Pharo image directory.
- Shut down and restart your Pharo image.
	* If $ROWAN_PROJECTS_HOME is set, `startup.st` will attempt to install Jadeite for Pharo from the local git repository clones in that directory.
 	* If $ROWAN_PROJECTS_HOME is not set, `startup.st` will open a file dialog allowing the user to choose the directory
  * Upon successful completion of `startup.st`, a Jadeite Connection Launcher window will open. 

## Using JadeiteForPharo without Rowan
Support for using JadeiteForPharo without Rowan is still under development and may contain significant bugs or limitations.

- To use Jadeite for Pharo without Rowan:
	* Open a Settings Browser in Pharo.
 	* Uncheck Jadeite for Pharo>Rowan Available


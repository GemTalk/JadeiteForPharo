# Disclaimer!!! Jadeite for Pharo is still in active development
* No official support provided
* Any code imported (such as a user's project) must be "rowanized" first
* Only SystemUser is supported currently
* Jadeite for Pharo is not traits aware

# JadeiteForPharo
IDE for GemStone Smalltalk application development in Pharo.
Jadeite for Pharo (and these instructions) should be considered pre-alpha quality at the current time. 

Jadeite For Pharo is only tested for use with GemStone 3.7.2. 

## To load JadeiteForPharo into a Pharo image:

- Install Pharo 12 Smalltalk.
  - Jadeite for Pharo only works with Pharo 12
  - Recommended build -
    - Pharo-12.0.0+SNAPSHOT.build.1546.sha.30427d35e51ff0351e1dc860306faf36d9d8931c (64 Bit)
- Create a Rowan server using extent `extent0.rowan3.dbf` from the GemStone/64 3.7.2 release directory
- Set the env variable $ROWAN_PROJECTS_HOME to the directory containing the checkouts of all github clones on local disk
- Clone these git projects to $ROWAN_PROJECTS_HOME on your local disk: 
	* JadeiteForPharo, branch `main`, `git clone git@github.com:GemTalk/JadeiteForPharo.git`
	* PharoGemStoneFFI, branch `main`, `git clone git@github.com:GemTalk/PharoGemStoneFFI.git`
	* RemoteServiceReplication, branch `main-v2`, `git clone git@github.com:GemTalk/RemoteServiceReplication.git`
 	* RowanClientServices, branch `mainV3.0`, `RowanClientServices, branch mainV3.0, git clone git@github.com:GemTalk/RowanClientServices.git -b mainV3.0 RowanClientServicesV3`
- Connect to the latest RowanClientServices code by running these scripts in a directory with a .topazini file setup with your stone's information:
	* `<Gemstone install directory>/rowan3/bin/installProject.ston file:$ROWAN_PROJECTS_HOME/RemoteServiceReplication/rowan/specs/RemoteServiceReplication.stone --projectsHome=$ROWAN_PROJECTS_HOME`
	* `<Gemstone install directory>/rowan3/bin/installProject.ston file:$ROWAN_PROJECTS_HOME/RowanClientServices/rowan/specs/RowanClientServices.stone --projectsHome=$ROWAN_PROJECTS_HOME`

- Copy `startup.st` from this repository into the directory where your Pharo image resides.
- Start your Pharo image normally.
	* If $ROWAN_PROJECTS_HOME is set, `startup.st` will attempt to install Jadeite for Pharo from the local git repository clones in that directory.
 	* If $ROWAN_PROJECTS_HOME is not set, `startup.st` will open a file dialog allowing the user to choose the directory
  	* Upon successful completion of `startup.st`, a Jadeite Connection Launcher window will open. 

- Optional - If you wish to use Jadeite for Pharo without Rowan, 
	* Open a Settings Browser in Pharo.
 	* Uncheck Jadeite for Pharo>Rowan Available
  	* Running Jadeite for Pharo without Rowan is still in development

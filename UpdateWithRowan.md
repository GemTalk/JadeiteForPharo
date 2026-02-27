## Updating to a New Jadeite Version

Jadeite on the client operates by invoking server operations that are implemented in RowanClientServices (RCS), a 
separate project that is loaded into the GemStone server. New versions of Jadeite, provided outside of a GemStone 
server release, usually require additional updates to the GemStone server to get corresponding updated RCS and 
possibly other projects. A Jadeite/RCS mismatch is likely to make Jadeite unusable.

### Updating GemStone for a new version of Jadeite 

The GemStone distribution includes source for the specific versions of RCS (and other projects, such as Rowan) that 
were distributed with the server release. The distribution source cannot be updated. 

To get the updated version, you need to clone the target branch of the git project, and reinstall the project, 
which both updates your GemStone repository to point to this clone rather than the distribution files, and 
reloads the project. This task is done by the installProject script, which is in the GemStone distribution. 

This is the process to load a new branch of a project from a git clone into your repository. 
This example is for RowanClientServices, but the process is the same for any of the projects.

- Choose a directory for your git clones.
- Clone the github project into that directory. For example, to clone the main375 branch of RowanClientServices, use:
   ```
   git clone -b main375 https://github.com/GemTalk/RowanClientServices RowanClientServicesV3
   ```
The target name, RowanClientServicesV3, must match the name of the project within the server code.  
- Set the ROWAN_PROJECTS_HOME environment variable to point to the directory containing the git clone/s (in addition to setting $GEMSTONE and your path): 
- Define a .topazini file with the login parameters for the stone, as SystemUser.
- Install the project, using
     $GEMSTONE/rowan3/bin/installProject.stone file:$ROWAN_PROJECTS_HOME/RowanClientServicesV3/rowan/specs/RowanClientServices.ston --projectsHome=$ROWAN_PROJECTS_HOME --debug -- -l -I .topazini

### Updating Jadeite

Minor changes in Jadeite may not require changes in RCS, and vice versa, but often bug fixes in Jadeite require a corresponding 
change in RCS, and you would see unexpected errors if you do not upgrade both Jadeite and RCS. 

To get a new version of jadeite, it is recommended to update the server as needed, then on the client, update the git clones, 
create a new Pharo image, and install Jadeite. 

Jadeite updates may be done within the running Pharo image, using Pharo tools. However, if the jadeite changes break the 
interface to the server, this risks making jadeite unusable in this Pharo image. 


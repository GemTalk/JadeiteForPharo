## Updating to a New Jadeite Version (without Rowan)

Jadeite on the client operates by invoking server operations that are implemented in the RowanStubForJadeite that is 
loaded into the GemStone server. New versions of Jadeite, provided outside of a GemStone server release, usually 
require additional updates to the GemStone server to get corresponding server changes. A Jadeite/RowanStubForJadeite 
mismatch may make Jadeite unusable.

If an updated version of the RowanStubForJadeite is to be installed, or if you are upgrading to a later version of GemStone 
with a later version of the RowanStubForJadeite (for example, after a release such as 3.7.6), setting several environment 
variables allows reinstalling the code for the Rowan Stub.

### Installing an updated version of the RowanStubForJadeite

Between GemStone releases, bugs are likely to be fixed in the RowanStubForJadeite, in particular for Jadeite changes that 
depend on RowanClientServices and other Rowan code. You can install newer set of RowanStubForJadeite .gs files using the
following process.  This assumes the directory <i>&lt;pathToUpdatedInstallFiles&gt;</i> contains the updated .gs files.

- Set the following environment variables (in addition to $GEMSTONE and your path):
   ```
   export ROWAN_STUB_INTENTIONAL_OVERRIDE=true
   export ROWAN_STUB_GS_DIRECTORY=<pathToUpdatedFiles>
   ```
- Define a .topazini file with the login parameters for the upgraded stone, as SystemUser. 
- In the same directory as the .topazini, execute: 
   ```
   $GEMSTONE/examples/jadeite/bin/installRowanStub_topaz.sh -L
   ```

### Upgrading RowanStubForJadeite after a GemStone upgrade

GemStone upgrade will remove some methods that are important for the Rowan Stub to operate. 

After you have upgraded GemStone, you will need to install the version of the RowanStubForJadeite that is part of the upgraded version distribution.  Note that this 
is likely to require a new version of Jadeite, since Jadeite relies on functions implemented in RowanClientServices. 

To install the version of RowanStubForJadeite that is included in the upgraded version distribution, do the following: 

- Set the following environment variables (in addition to $GEMSTONE and your path):
   ```
   export ROWAN_STUB_INTENTIONAL_OVERRIDE=true
   export ROWAN_STUB_GS_DIRECTORY=$GEMSTONE/examples/jadeite/gs
   ```
- Define a .topazini file with the login parameters for the upgraded stone, as SystemUser. 
- In the same directory as the .topazini, execute: 
   ```
   $GEMSTONE/examples/jadeite/bin/installRowanStub_topaz.sh -L
   ```

###Updating Jadeite

Minor changes in Jadeite may not require changes in the Rowan Stub, and vice versa, but often bug fixes in Jadeite require a corresponding change in the Rowan Stub, and you would see unexpected errors if you do not upgrade both Jadeite and the Rowan Stub.

To get a new version of jadeite, it is recommended to update the server as needed, then on the client, update the git clones, create a new Pharo image, and install Jadeite. A link to Instructions are in the [README][2].

Jadeite updates may be done within the running Pharo image, using Pharo tools. However, if the jadeite changes break the interface to the server, this risks making jadeite unusable in this Pharo image.
  
[2]: README.md

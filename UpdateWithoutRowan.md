## Updating to a New Jadeite Version (without Rowan)

New versions of Jadeite, provided outside of a GemStone server release, require additional updates to the GemStone server, in order to get corresponding updated versions of the server code that Jadeite depends on.

Jadeite on the client operates by invoking GemStone server operations that are supported by RowanStubForJadeite in the non-Rowan base extent GemStone repository. While some changes in Jadeite do not require changes in RCS, and vice versa, often bug fixes in Jadeite require a corresponding change in RCS and you would see unexpected errors if you do not upgrade both Jadeite and RCS. 

The RowanStubForJadeite install process normally disallows reinstallation. If an updated version of the RowanStubForJadeite 
is to be installed, or if you are upgrading to a later version of GemStone with a later version of the
RowanStubForJadeite (for example, after a release such as 3.7.6), setting several environment variables allows reinstalling 
the Rowan Stub.

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


  

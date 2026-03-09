# Jadeite for Pharo

Jadeite for Pharo is an IDE for GemStone Smalltalk application development in Pharo. Jadeite for Pharo connects to a GemStone Rowan repository to manage code in Rowan projects, using git repositories to store tonel-format files on disk. Jadeite for Pharo can also be used without Rowan, to develop code that can be managed manually using fileout, and in the future in Metacello/Monticello packages. 

Jadeite for Pharo has basic functionality complete but is alpha-level code under active development. Help and support are provided by the GemTalk's customer forum at gemstone-smalltalk@lists.gemtalksystems.com, or the GLASS forum at glass@lists.gemtalksystems.com.  Users of Jadeite for Pharo should exercise due caution for unexpected issues and unknown bugs.

For information and help on Jadeite and getting started, see the online help: http://docs.gemtalksystems.com/current/JadeiteHelp.

## Setup and installation

GemStone/Rowan server setup and Jadeite / Pharo client setup instructions are provided with the links below. The process is different if using a Rowan extent, or a base extent with the Rowan stub.
* [Setup instructions for Jadeite using Rowan](SetupForWithRowan.md)
* [Setup instructions for Jadeite without Rowan](SetupForWithoutRowan.md)

## GemStone requirements

Jadeite allows you to login to a GemStone repository. Basic understanding of GemStone, Smalltalk, and the GemStone server setup is required. 
For more on GemStone server setup, see the Installation Guides on the [GemTalk website](https://gemtalksystems.com/products/gs64/versions37x/).

These instructions provide installation into GemStone/S 64 Bit v3.7.5, which is not yet released (expected March of 2026). This branch of Jadeite will work not with earlier versions of GemStone/S 64 Bit. 

This branch of Jadeite is only expected to work with Pharo 13. 

## Updated versions of Jadeite

To use a new version of Jadeite, you usually need to do updates on Rowan or Rowan Stub code in the GemStone server before installing the new version of Jadeite 
* [Rowan updates for a new version of Jadeite using Rowan](UpdateWithRowan.md)
* [RowanStubForJadeite for a new version of Jadeite without Rowan](UpdateWithoutRowan.md)
  
## Reporting Issues

Issue reports are welcome. Please include the git shas (Abort > Git Commit Ids), as well as screen shots and/or stack traces. 



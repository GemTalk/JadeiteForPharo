# JadeiteForPharo
IDE for GemStone Smalltalk application development in Pharo using Rowan code management. Note that Jadeite for Pharo requires Rowan 3. 

## To load JadeiteForPharo into a Pharo image:

* Install Pharo 12 Smalltalk. (Currently, only Pharo 12 is supported)
* Create a Rowan server using extent `extent0.rowan3.dbf`
* If you want to use the latest RowanClientServices code, you'll need to run the .../rowan3/bin/attachRowanDevClones.stone script
* Clone these git projects to your local disk with a common directory: 
	* JadeiteForPharo, branch `main`, `git clone git@github.com:GemTalk/JadeiteForPharo.git`
	* PharoGemStoneFFI, branch `main`, `git clone git@github.com:GemTalk/PharoGemStoneFFI.git`
	* RemoteServiceReplication, branch `main-v2`, `git clone git@github.com:GemTalk/RemoteServiceReplication.git`

* Run the script below in a Pharo 12 image playground
* Go to Library>Jadeite Launcher to open a connection browser
```

| directory jfpRepo icePackage sourceDirectory packageDir |
directory := UIManager default
	             chooseDirectory: 'Choose Jadeite Repositories directory'
	             from: nil.
directory ifNil: [ ^ self ].
{  'PharoGemStoneFFI'. 'RemoteServiceReplication' . 'JadeiteForPharo'}
	do: [ :projectName |
		| projectDir iceRepository |
		projectDir := (directory childrenMatching: projectName) first.
		projectDir isDirectory ifFalse: [
			^ self notify: projectName , ' git checkout not found' ].
		[
		(iceRepository := IceRepositoryCreator new
			 location: projectDir;
			 subdirectory: String new;
			 createRepository) register ]
			on: IceDuplicatedRepository
			do: [ "nothing" ].
			 ].
jfpRepo := IceRepository repositoryNamed:  'JadeiteForPharo'.
icePackage := jfpRepo packageNamed: 'BaselineOfJadeiteForPharo'.
	sourceDirectory := icePackage repository project sourceDirectory.
	sourceDirectory ifEmpty: [ sourceDirectory := '.' ].

	packageDir := (icePackage repository location / sourceDirectory)
		              fullName.

	Metacello new
		repository: 'gitlocal://' , packageDir;
		baseline: icePackage metacelloBaselineName;
		onUpgrade: [ :e |
			| policy |
			policy := self chooseUpgradePolicyFor: e.
			policy ifNotNil: [ e perform: policy ] ];
		onConflict: [ :e |
			| policy |
			policy := self chooseConflictPolicyFor: e.
			policy ifNotNil: [ e perform: policy ] ];
		load: #().
		

```

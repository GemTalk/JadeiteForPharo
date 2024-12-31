# JadeiteForPharo
IDE for GemStone Smalltalk application development in Pharo.
Jadeite for Pharo (and these instructions) should be considered alpha quality at the current time. 
These instructions are written assuming the user is using a GemStone server with Rowan installed. 

## To load JadeiteForPharo into a Pharo image:

- Install Pharo 12 Smalltalk.
  - Currently, only Pharo 12 is supported
  - Recommended build -
    - Pharo-12.0.0+SNAPSHOT.build.1546.sha.30427d35e51ff0351e1dc860306faf36d9d8931c (64 Bit)
- Create a Rowan server using extent `extent0.rowan3.dbf`
- Set the env variable $ROWAN_CLIENT_SERVICES to the directory containing the checkouts of all github clones on local disk
- Clone these git projects to $ROWAN_CLIENT_SERVICES on your local disk: 
	* JadeiteForPharo, branch `main`, `git clone git@github.com:GemTalk/JadeiteForPharo.git`
	* PharoGemStoneFFI, branch `main`, `git clone git@github.com:GemTalk/PharoGemStoneFFI.git`
	* RemoteServiceReplication, branch `main-v2`, `git clone git@github.com:GemTalk/RemoteServiceReplication.git`
 	* RowanClientServices, branch `mainV3.0`, `git clone git@github.com:GemTalk/RowanClientServices.git`
- Connect to the latest RowanClientServices code by running this script in a directory with a .topazini file setup with your stone's information:
	* \<Gemstone install directory\>/rowan3/bin/attachRowanDevClones.stone script 	   

- Run the script below in a Pharo 12 image playground
- If you wish to use Jadeite for Pharo without Rowan, 
	* Open a Settings Browser in Pharo.
 	* Uncheck Jadeite for Pharo>Rowan Available  
- Go to Library>Jadeite Launcher to open a connection browser
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

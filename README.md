# JadeiteForPharo
IDE for GemStone Smalltalk application development in Pharo using Rowan code management 

## To load JadeiteForPharo into a Pharo image:
(Currently, Pharo 11 is supported)
After a Rowan server is created, clone git projects 'PharoGemStoneFFI' 'RemoteServiceReplication' 'JadeiteForPharo' to your local disk with a common parent directory. 
Then, run the following script in a Pharo image playground

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
		
"Go to Library>Jadeite Launcher to open a connection browser"
```


| directory jfpRepo icePackage sourceDirectory packageDir |

(IceRepository repositoryNamed:  'JadeiteForPharo') ifNotNil: [^self].  "do not install the JfP project if it already exists in image"

[(directory := PlatformResolver forCurrentPlatform directoryFromEnvVariableNamed: 'ROWAN_PROJECTS_HOME') isDirectory ifTrue: [directory] ifFalse: [nil] ] on: Error do: [ :ex | nil ].

directory ifNil: [
directory := UIManager default
	             chooseDirectory: 'Choose directory which holds Jadeite git repositories'
	             from: nil].
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
		
(Smalltalk at: #JadeiteConnectionApplication ) new start

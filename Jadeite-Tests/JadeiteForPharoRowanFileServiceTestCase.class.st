Class {
	#name : 'JadeiteForPharoRowanFileServiceTestCase',
	#superclass : 'JadeiteForPharoRowanServiceTestCase',
	#category : 'Jadeite-Tests',
	#package : 'Jadeite-Tests'
}

{ #category : 'support' }
JadeiteForPharoRowanFileServiceTestCase >> setUp [

	updater := RowanServiceUpdater current.
	JadeiteConnectionProfile connectionProfile disconnect.
	JadeiteConnectionProfile connectionProfile connect.
	session := GciSession current
]

{ #category : 'tests' }
JadeiteForPharoRowanFileServiceTestCase >> test_exists [
	"`exists` blocks when it goes to the server. The test should not continue until it has an answer"

	| fileService path exists |
	path := session executeString:
		        '(System performOnServer: ''echo $HOME'') trimTrailingSeparators'.
	fileService := RowanFileServiceClient new
		               path: path;
		               session: session.
	self assert: fileService answer equals: nil.
	exists := fileService exists.
	self assert: exists equals: true
]

{ #category : 'tests' }
JadeiteForPharoRowanFileServiceTestCase >> test_expandPath [

	| fileService path |
	path := session executeString:
		        '(System performOnServer: ''echo $ROWAN_PROJECTS_HOME'') trimTrailingSeparators'.
	fileService := RowanFileServiceClient new.
	fileService
		command: #expandPath;
		path: '$ROWAN_PROJECTS_HOME'.
	updater
		issueCommand: fileService
		session: session
		onCompletion: [ self assert: fileService answer equals: path ].

	path := session executeString:
		        '(System performOnServer: ''echo $HOME'') trimTrailingSeparators'.
	fileService := RowanFileServiceClient new.
	fileService
		command: #expandPath;
		path: '$HOME'.
	updater
		issueCommand: fileService
		session: session
		onCompletion: [ self assert: fileService answer equals: path ]
]

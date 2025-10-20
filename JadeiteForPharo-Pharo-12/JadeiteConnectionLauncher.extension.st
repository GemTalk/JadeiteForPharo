Extension { #name : 'JadeiteConnectionLauncher' }

{ #category : '*JadeiteForPharo-Pharo-12' }
JadeiteConnectionLauncher >> importProfileDirectory [

	| directoryRef |
	"confusing not to see files"
	self possiblyDisconnect ifFalse: [ ^ self ].
	directoryRef := UIManager default
		                chooseDirectory:
		                'Select directory containing only connection profiles'
		                path: self class lastImportDirectory.
	directoryRef ifNil: [ ^ self ].
	self basicImportProfileDirectory: directoryRef
]

{ #category : '*JadeiteForPharo-Pharo-12' }
JadeiteConnectionLauncher >> setPath [

	| path |
	path := UIManager default
		        chooseDirectory: 'Choose Client Library Directory'
		        path: JadeiteGCIConnectionProfile clientLibrariesPath.
	path ifNil: [ ^ nil ].
	JadeiteGCIConnectionProfile clientLibrariesPath: path fullName.
	pathText text: path fullName
]

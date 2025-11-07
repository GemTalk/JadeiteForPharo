Extension { #name : 'JadeiteConnectionLauncher' }

{ #category : '*JadeiteForPharo-Pharo-13' }
JadeiteConnectionLauncher >> exportProfile [

	| fileRef |
	fileRef := self uiManager
		           chooseForSaveFileReference: 'Export Connection File'
		           extensions: nil
		           path:
		           FileSystem workingDirectory / self suggestedExportName.
	fileRef ifNil: [ ^ self ].
	self basicExportProfile: fileRef
]

{ #category : '*JadeiteForPharo-Pharo-13' }
JadeiteConnectionLauncher >> importProfileDirectory [

	| directoryRef |
	"confusing not to see files"
	self possiblyDisconnect ifFalse: [ ^ self ].
	directoryRef := self application newOpenFile
		                title:
			                'Select directory containing only connection profiles';
		                path: self class lastImportDirectory;
		                beOpenDirectory;
		                openModal.

	directoryRef ifNil: [ ^ self ].
	self basicImportProfileDirectory: directoryRef
]

{ #category : '*JadeiteForPharo-Pharo-13' }
JadeiteConnectionLauncher >> setPath [

	| path dialog |
	dialog := self application newOpenFile
		          title: 'Choose Client Library Directory';
		          path:
			          JadeiteGCIConnectionProfile clientLibrariesPath
				          asFileReference;
		          beOpenDirectory.
	path := dialog openModal.
	path ifNil: [ ^ nil ].
	JadeiteGCIConnectionProfile clientLibrariesPath: path fullName.
	pathText text: path fullName
]

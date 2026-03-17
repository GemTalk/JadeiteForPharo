Extension { #name : 'JadeiteConnectionLauncher' }

{ #category : '*JadeiteForPharo-Pharo-13' }
JadeiteConnectionLauncher >> exportProfile [

	| fileRef |
	fileRef := self
		           jadeiteChooseSaveFileReference: 'Export Connection File'
		           extensions: nil
		           path: self class lastImportDirectory asFileReference
			           / self suggestedExportName.
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
JadeiteConnectionLauncher >> importProfileFile [

	| presenter |
	self possiblyDisconnect ifFalse: [ ^ self ].
	presenter := JadeiteOpenFilePresenter new
		             openFolder:
			             self class lastImportDirectory asFileReference;
		             title: 'Select connection profile file to import'.
	presenter okAction: [ :fileRef |
		self basicImportProfileFromPath: fileRef pathString ].
	^ presenter openDialog
]

{ #category : '*JadeiteForPharo-Pharo-13' }
JadeiteConnectionLauncher >> jadeiteChooseSaveFileReference: title extensions: exts path: pathReference [

	(ProvideAnswerNotification signal: 'choose save file reference')
		ifNotNil: [ :answer | ^ answer ].
	^ self uiManager
		  chooseForSaveFileReference: 'Export Connection File'
		  extensions: exts
		  path: pathReference asJadeiteFileReference
]

{ #category : '*JadeiteForPharo-Pharo-13' }
JadeiteConnectionLauncher >> setClientLibrariesPath [

	| path dialog libPathRef |
	libPathRef := self validLibPathReference.
	dialog := self application newOpenFile
		          title: 'Choose Client Library Directory';
		          path: libPathRef;
		          beOpenDirectory.
	path := dialog openModal.
	path ifNil: [ ^ nil ].
	JadeiteGCIConnectionProfile clientLibrariesPath: path fullName.
	clientLibPathText text: path fullName
]

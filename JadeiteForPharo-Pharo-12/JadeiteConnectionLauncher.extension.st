Extension { #name : 'JadeiteConnectionLauncher' }

{ #category : '*JadeiteForPharo-Pharo-12' }
JadeiteConnectionLauncher >> exportProfile [

	| fileRef suggestedFileName |
	suggestedFileName := self suggestedExportName.
	fileRef := UIManager default theme
		           jadeiteChooseForSaveFileReferenceIn: Smalltalk ui
		           title: 'Export Connection File'
		           extensions: nil
		           filename: suggestedFileName
		           preview: nil.
	fileRef ifNil: [ ^ self ].
	fileRef exists ifTrue: [
		(UIManager default confirm: 'Overwrite existing file?') ifFalse: [
			^ self ] ].
	self basicExportProfile: fileRef
]

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
JadeiteConnectionLauncher >> importProfileFile [

	| fileStream fileWindow |
	self possiblyDisconnect ifFalse: [ ^ self ].
	fileWindow := FileDialogWindow basicNew.
	fileWindow
		previewType: nil;
		initialize;
		title: 'Select connection profile file to import';
		answerOpenFile.
	self class lastImportDirectory ifNotNil: [ :dir |
		fileWindow selectDirectory: dir asFileReference ].
	fileStream := fileWindow
		              openModal;
		              answer.
	fileStream ifNil: [ ^ self ].
	self basicImportProfileFromPath: fileWindow selectedPathName
]

{ #category : '*JadeiteForPharo-Pharo-12' }
JadeiteConnectionLauncher >> setClientLibrariesPath [

	| path libPathRef |
	libPathRef := self validLibPathReference.
	path := UIManager default
		        chooseDirectory: 'Choose Client Library Directory'
		        from: libPathRef.
	path ifNil: [ ^ nil ].
	JadeiteGCIConnectionProfile clientLibrariesPath: path fullName.
	pathText text: path fullName
]

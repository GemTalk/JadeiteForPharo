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
JadeiteConnectionLauncher >> setPath [

	| path |
	path := UIManager default
		        chooseDirectory: 'Choose Client Library Directory'
		        from:
		        JadeiteGCIConnectionProfile clientLibrariesPath
			        asFileReference.
	path ifNil: [ ^ nil ].
	JadeiteGCIConnectionProfile clientLibrariesPath: path fullName.
	pathText text: path fullName
]

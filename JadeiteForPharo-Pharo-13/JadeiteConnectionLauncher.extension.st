Extension { #name : 'JadeiteConnectionLauncher' }

{ #category : '*JadeiteForPharo-Pharo-13' }
JadeiteConnectionLauncher >> setPath [

	| path |
	path := self application newOpenFile
		        title: 'Choose Client Library Directory';
		        path:
			        JadeiteGCIConnectionProfile clientLibrariesPath
				        asFileReference;
		        beOpenDirectory;
		        openModal.
	path ifNil: [ ^ nil ].
	JadeiteGCIConnectionProfile clientLibrariesPath: path fullName.
	pathText text: path fullName
]

Class {
	#name : 'JadeiteLoadProjectDialog',
	#superclass : 'JadeiteServerFileSelectorDialog',
	#category : 'Jadeite-FileDialog',
	#package : 'Jadeite-FileDialog'
}

{ #category : 'initialization' }
JadeiteLoadProjectDialog class >> setLastPath: aString [

	JadePresenter possiblySetLastLoadProjectPath: aString
]

{ #category : 'instance creation' }
JadeiteLoadProjectDialog class >> showOnSession: aGciSession defaultPath: defaultPath shellName: shellName [

	(ProvideAnswerNotification signal: defaultPath) ifNotNil: [
		:theAnswer | ^ theAnswer ].
	^ self
		  basicShowOnSession: aGciSession
		  defaultPath: defaultPath
		  shellName: shellName
]

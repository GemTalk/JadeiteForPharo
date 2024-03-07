Class {
	#name : 'JadeitePreferencesWorkspace',
	#superclass : 'JadeiteWorkspace',
	#category : 'Jadeite-TextPanes'
}

{ #category : 'as yet unclassified' }
JadeitePreferencesWorkspace class >> browseJadeitePrefs: session [
	"Open Jadeite.prefs in the working directory"

	| path setDefaultPrefs fileStream |
	path := JadeitePreferences preferencesPath.
	setDefaultPrefs := false.
	(File exists: path) ifFalse: [
		(MessageBox confirm: 'Jadeite.prefs does not exist in '
			 , JadeitePreferences preferencesPath , '. Create it?')
			ifTrue: [ setDefaultPrefs := true ]
			ifFalse: [ ^ self ] ].
	setDefaultPrefs ifTrue: [
		fileStream := (FileSystem disk open: path writable: true) reference
			              writeStream.
		[
		fileStream
			nextPutAll: JadeitePreferences preferencesFileDefaultContents;
			flush ] ensure: [ fileStream close ] ].
	^ (self open: path onSession: session) caption:
		  'Jadeite Preferences File: ' , path
]

{ #category : 'as yet unclassified' }
JadeitePreferencesWorkspace >> basicResetPreferences [
	self value: JadeitePreferences preferencesFileDefaultContents
]

{ #category : 'as yet unclassified' }
JadeitePreferencesWorkspace >> openPreferencesOptionsWorkspace [
	| workspace |
	workspace := JadeiteWorkspace showOnSession: self gciSession.
	workspace model value: JadeitePreferences preferencesFileDefaultContents.
	workspace
		isModified: false;
		caption: 'Default Preferences'.
	workspace codePane documentPresenter view setReadOnly: true.
	^workspace
]

{ #category : 'as yet unclassified' }
JadeitePreferencesWorkspace >> resetPreferences [
	(MessageBox confirm: 'Really reset jadeite.prefs file to default settings?') ifFalse: [^self].
	self basicResetPreferences.
	self isModified: true. 
]

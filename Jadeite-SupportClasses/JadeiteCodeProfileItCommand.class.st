Class {
	#name : 'JadeiteCodeProfileItCommand',
	#superclass : 'JadeiteCodeExecutionCommand',
	#category : 'Jadeite-SupportClasses',
	#package : 'Jadeite-SupportClasses'
}

{ #category : 'default' }
JadeiteCodeProfileItCommand class >> defaultDescription [

	^ 'Profile the selection and print the profile results.'
]

{ #category : 'defaults' }
JadeiteCodeProfileItCommand class >> defaultIconName [

	^ #smallProfile
]

{ #category : 'default' }
JadeiteCodeProfileItCommand class >> defaultName [

	^ 'Profile it'
]

{ #category : 'defaults' }
JadeiteCodeProfileItCommand class >> defaultShortcutKey [
	"shortcut key not working, returning nil for now"
	"^ $p shift command mac
		| $p shift control win
		| $p shift control unix"
	^super defaultShortcutKey
]

{ #category : 'enumerating' }
JadeiteCodeProfileItCommand >> evaluate: aString andDo: aBlock [

	[
	Cursor wait showWhile: [
		self context
			executeSelectionOrLine: (self profileCodeFor: aString)
			shouldDebug: false
			onCompileError: [  ]
			showResult: false
			onCompletion: [ :answeringService |
				| workspace outputStream |
				answeringService answer first
					ifTrue: [
						Cursor wait showWhile: [
							outputStream := WriteStream on: String new.
							outputStream
								nextPutAll: 'Profile code: ';
								cr;
								nextPutAll: (self profileCodeFor: aString);
								cr;
								cr;
								nextPutAll: (answeringService answer at: 3).
							workspace := JadeiteWorkspace showOnSession:
								             self context gciSession.
							workspace value: outputStream contents.
							workspace
								isModified: false;
								caption: 'Profile Results' ] ]
					ifFalse: [
						| offset |
						offset := (answeringService answer at: 2) first at: 2.
						(answeringService answer at: 2) first at: 2 put: offset - 28 "overhead of profile code up to error" ] ] ] ]
		fork
]

{ #category : 'enumerating' }
JadeiteCodeProfileItCommand >> profileCodeFor: aString [

	^ '| block service |
block := [' , aString , ']. 
service := RowanAnsweringService new profile: block. 
service answer'
]

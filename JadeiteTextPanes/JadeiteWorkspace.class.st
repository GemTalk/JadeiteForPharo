"
model is an instance of GciSession
"
Class {
	#name : 'JadeiteWorkspace',
	#superclass : 'JadeiteTextDocument',
	#category : 'JadeiteTextPanes'
}

{ #category : 'instance creation' }
JadeiteWorkspace class >> showOnSession: aSession [
	"for legacy imported tests"
	^JadeiteWorkspaceApplication showOnSession: aSession library
	
	
]

{ #category : 'private' }
JadeiteWorkspace >> codePane [
	"Private -  for testing"

	^codePane
]

{ #category : 'menu handlers' }
JadeiteWorkspace >> editRevert [
	codePane documentPresenter value: lastSave
]

{ #category : 'actions' }
JadeiteWorkspace >> inspectOop: anOop [

	^ JadeiteInspectorApplication
		  show: anOop
		  onSession:
		  gciSession library
]

{ #category : 'public' }
JadeiteWorkspace >> queryCommand: aCommandQuery [

	| cmd |
	
	cmd := aCommandQuery commandSymbol.
	(cmd == #'setEnvironment0' and: [environment == 0]) ifTrue: [aCommandQuery isChecked: true; isEnabled: false. ^true].
	(cmd == #'setEnvironment1' and: [environment == 1]) ifTrue: [aCommandQuery isChecked: true; isEnabled: false. ^true].
	(cmd == #'setEnvironment2' and: [environment == 2]) ifTrue: [aCommandQuery isChecked: true; isEnabled: false. ^true].
	^super queryCommand: aCommandQuery
]

{ #category : 'public' }
JadeiteWorkspace >> setEnvironment0 [

	self setEnvironment: 0.
]

{ #category : 'public' }
JadeiteWorkspace >> setEnvironment1 [

	self setEnvironment: 1.
]

{ #category : 'public' }
JadeiteWorkspace >> setEnvironment2 [

	self setEnvironment: 2.
]

{ #category : 'public' }
JadeiteWorkspace >> setEnvironment: anInteger [

	environment := anInteger.
	codePane documentPresenter parentPresenter environment: anInteger.
	self updateCaption.

]

{ #category : 'private' }
JadeiteWorkspace >> updateCaption [

	| string |
	string := self filename isNil
		ifTrue: ['(Untitled)']
		ifFalse: [self filename].
	string := gciSession titleBarFor: string.
	environment ~~ 0 ifTrue: [string := string , ' @env' , environment printString].
	self caption: string.

]

{ #category : 'accessing' }
JadeiteWorkspace >> value [ 
	^self
]

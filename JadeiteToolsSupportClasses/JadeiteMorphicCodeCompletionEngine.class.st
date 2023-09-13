Class {
	#name : 'JadeiteMorphicCodeCompletionEngine',
	#superclass : 'SpMorphicCodeCompletionEngine',
	#category : 'JadeiteToolsSupportClasses'
}

{ #category : 'initialization' }
JadeiteMorphicCodeCompletionEngine class >> initialize [

	super initialize. 
	RubSmalltalkEditor completionEngineClass: self
]

{ #category : 'initialization' }
JadeiteMorphicCodeCompletionEngine >> initialize [

	super initialize.
	contextClass := JadeiteCompletionContext
]

{ #category : 'menu morph' }
JadeiteMorphicCodeCompletionEngine >> menuClosed [
	"don't nil the context"
	menuMorph := nil.

]

{ #category : 'menu morph' }
JadeiteMorphicCodeCompletionEngine >> openMenu [
	| theMenu |
	self stopCompletionDelay.

	context := self createContext.
	context completion filter completionString: self completionToken.
	context completion fetcher reset. 
	theMenu := self menuMorphClass
				engine: self
				position: (editor selectionPosition: context completionToken).

	theMenu isClosed ifFalse: [ menuMorph := theMenu ]
]

{ #category : 'keyboard' }
JadeiteMorphicCodeCompletionEngine >> updateCompletionAfterEdition: aParagraphEditor [

	(aParagraphEditor isNil or: [ self isMenuOpen not ]) ifTrue: [
		^ self ].

	aParagraphEditor atCompletionPosition ifFalse: [ ^ self closeMenu ].
	context completion results removeAll. 
	context completion filter completionString: self completionToken.
	context completion fetcher reset. 
	context narrowWith: aParagraphEditor wordAtCaret.
	menuMorph refreshSelection
]

Class {
	#name : 'JadeiteCompletionEngine',
	#superclass : 'SpMorphicCodeCompletionEngine',
	#category : 'Jadeite-SupportClasses'
}

{ #category : 'initialization' }
JadeiteCompletionEngine >> initialize [

	super initialize.
	contextClass := JadeiteCompletionContext
]

{ #category : 'menu morph' }
JadeiteCompletionEngine >> menuClosed [
	"don't nil the context"
	menuMorph := nil.

]

{ #category : 'menu morph' }
JadeiteCompletionEngine >> openMenu [
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
JadeiteCompletionEngine >> updateCompletionAfterEdition: aParagraphEditor [

	(aParagraphEditor isNil or: [ self isMenuOpen not ]) ifTrue: [
		^ self ].

	aParagraphEditor atCompletionPosition ifFalse: [ ^ self closeMenu ].
	context completion results removeAll. 
	context completion filter completionString: self completionToken.
	context completion fetcher reset. 
	context narrowWith: aParagraphEditor wordAtCaret.
	menuMorph refreshSelection
]

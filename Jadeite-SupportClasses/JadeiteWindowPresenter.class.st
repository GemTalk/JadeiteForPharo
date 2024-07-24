Class {
	#name : 'JadeiteWindowPresenter',
	#superclass : 'SpWindowPresenter',
	#category : 'Jadeite-SupportClasses',
	#package : 'Jadeite-SupportClasses'
}

{ #category : 'specs' }
JadeiteWindowPresenter class >> adapterName [

	^ #JadeiteMorphicWindowAdapter
]

{ #category : 'private' }
JadeiteWindowPresenter >> okToChange [

	self flag: #TODO. "Maybe wrong?"
	self presenter canDiscardEdits ifFalse: [ ^ false ].
	"Solicit cancel from view"
	self changed: #wantToChange.  
	^ self canDiscardEdits
]

{ #category : 'testing' }
JadeiteWindowPresenter >> okToClose [ 

	^self presenter okToClose
]

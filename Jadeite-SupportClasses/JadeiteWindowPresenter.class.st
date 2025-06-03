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

{ #category : 'testing' }
JadeiteWindowPresenter >> okToClose [ 

	^self presenter okToClose
]

{ #category : 'private' }
JadeiteWindowPresenter >> title: aString [

	aString ifNil: [ ^ self ].
	^ super title: aString
]

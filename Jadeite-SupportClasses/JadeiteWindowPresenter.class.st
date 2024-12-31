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

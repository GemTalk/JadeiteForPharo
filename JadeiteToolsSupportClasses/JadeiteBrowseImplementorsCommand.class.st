Class {
	#name : 'JadeiteBrowseImplementorsCommand',
	#superclass : 'JadeiteCommand',
	#category : 'JadeiteToolsSupportClasses'
}

{ #category : 'execution' }
JadeiteBrowseImplementorsCommand >> execute [
	^context browseImplementors 
]

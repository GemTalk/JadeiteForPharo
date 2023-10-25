Class {
	#name : 'JadeiteBrowseImplementorsCommand',
	#superclass : 'SpBrowseImplementorsCommand',
	#category : 'JadeiteToolsSupportClasses'
}

{ #category : 'accessing' }
JadeiteBrowseImplementorsCommand >> name [
	| dynamicName |
	dynamicName := self context selectedSelector ifNil: [ 'it' ].
	^'Implementors of ', dynamicName 
]

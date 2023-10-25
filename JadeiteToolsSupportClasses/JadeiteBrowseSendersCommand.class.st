Class {
	#name : 'JadeiteBrowseSendersCommand',
	#superclass : 'SpBrowseSendersCommand',
	#category : 'JadeiteToolsSupportClasses'
}

{ #category : 'accessing' }
JadeiteBrowseSendersCommand >> name [
	| dynamicName |
	dynamicName := self context selectedSelector ifNil: [ 'it' ].
	^'Senders of ', dynamicName 
]

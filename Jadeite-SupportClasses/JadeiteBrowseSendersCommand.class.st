Class {
	#name : 'JadeiteBrowseSendersCommand',
	#superclass : 'JadeiteBrowseSelectorCommand',
	#category : 'Jadeite-SupportClasses',
	#package : 'Jadeite-SupportClasses'
}

{ #category : 'execution' }
JadeiteBrowseSendersCommand >> execute [

	self context doBrowseSenders: fullSelector
]

{ #category : 'accessing' }
JadeiteBrowseSendersCommand >> name [

	^ 'Senders of ' , self jadeiteMenuNameFromSelector
]

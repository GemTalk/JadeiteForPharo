Class {
	#name : 'JadeiteBrowseSendersCommand',
	#superclass : 'JadeiteBrowseCommand',
	#category : 'Jadeite-SupportClasses',
	#package : 'Jadeite-SupportClasses'
}

{ #category : 'execution' }
JadeiteBrowseSendersCommand >> execute [

	self context doBrowseSenders: selectedText
]

{ #category : 'accessing' }
JadeiteBrowseSendersCommand >> name [

	^ 'Senders of ' , self jadeiteMenuNameFromSelector
]

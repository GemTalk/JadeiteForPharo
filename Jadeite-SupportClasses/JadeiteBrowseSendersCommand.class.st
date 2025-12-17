Class {
	#name : 'JadeiteBrowseSendersCommand',
	#superclass : 'JadeiteBrowseSelectorCommand',
	#category : 'Jadeite-SupportClasses',
	#package : 'Jadeite-SupportClasses'
}

{ #category : 'defaults' }
JadeiteBrowseSendersCommand class >> defaultShortcutKey [

	^ $n command mac | $n control win | $n control unix
]

{ #category : 'execution' }
JadeiteBrowseSendersCommand >> execute [

	self context doBrowseSenders: fullSelector
]

{ #category : 'accessing' }
JadeiteBrowseSendersCommand >> name [

	^ 'Senders of ' , self jadeiteMenuNameFromSelector
]

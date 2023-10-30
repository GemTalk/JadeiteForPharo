Class {
	#name : 'JadeiteBrowseSendersCommand',
	#superclass : 'SpBrowseSendersCommand',
	#category : 'JadeiteToolsSupportClasses'
}

{ #category : 'accessing' }
JadeiteBrowseSendersCommand >> name [

	^ 'Senders of ' , self jadeiteMenuNameFromSelector
]

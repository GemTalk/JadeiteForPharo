Class {
	#name : 'JadeiteBrowseSendersCommand',
	#superclass : 'SpBrowseSendersCommand',
	#category : 'Jadeite-SupportClasses',
	#package : 'Jadeite-SupportClasses'
}

{ #category : 'accessing' }
JadeiteBrowseSendersCommand >> name [

	^ 'Senders of ' , self browseMenuItemName
]

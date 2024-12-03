Class {
	#name : 'JadeiteBrowseClassCommand',
	#superclass : 'SpBrowseClassCommand',
	#category : 'Jadeite-SupportClasses',
	#package : 'Jadeite-SupportClasses'
}

{ #category : 'accessing' }
JadeiteBrowseClassCommand >> name [

	^ 'Browse ' , self browseMenuItemName
]

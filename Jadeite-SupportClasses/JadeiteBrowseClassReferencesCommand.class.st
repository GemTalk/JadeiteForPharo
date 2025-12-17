Class {
	#name : 'JadeiteBrowseClassReferencesCommand',
	#superclass : 'JadeiteBrowseCommand',
	#category : 'Jadeite-SupportClasses',
	#package : 'Jadeite-SupportClasses'
}

{ #category : 'defaults' }
JadeiteBrowseClassReferencesCommand class >> defaultShortcutKey [

	^ $n shift command mac 
		| $n shift control win
		| $n shift control unix
]

{ #category : 'execution' }
JadeiteBrowseClassReferencesCommand >> execute [

	self context doBrowseClassReferences: selectedText
]

{ #category : 'accessing' }
JadeiteBrowseClassReferencesCommand >> name [

	^ 'Browse class references to ' , self browseMenuItemName
]

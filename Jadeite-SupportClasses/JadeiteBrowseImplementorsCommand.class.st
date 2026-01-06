Class {
	#name : 'JadeiteBrowseImplementorsCommand',
	#superclass : 'JadeiteBrowseSelectorCommand',
	#category : 'Jadeite-SupportClasses',
	#package : 'Jadeite-SupportClasses'
}

{ #category : 'defaults' }
JadeiteBrowseImplementorsCommand class >> defaultShortcutKey [

	^ $m command mac | $m control win | $m control unix
]

{ #category : 'execution' }
JadeiteBrowseImplementorsCommand >> execute [

	super execute.
	self context doBrowseImplementors: fullSelector
]

{ #category : 'accessing' }
JadeiteBrowseImplementorsCommand >> name [

	^ 'Implementors of ' , self jadeiteMenuNameFromSelector
]

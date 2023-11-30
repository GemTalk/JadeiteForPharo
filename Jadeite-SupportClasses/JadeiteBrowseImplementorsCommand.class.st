Class {
	#name : 'JadeiteBrowseImplementorsCommand',
	#superclass : 'SpBrowseImplementorsCommand',
	#category : 'Jadeite-SupportClasses'
}

{ #category : 'accessing' }
JadeiteBrowseImplementorsCommand >> name [

	^ 'Implementors of ' , self jadeiteMenuNameFromSelector
]

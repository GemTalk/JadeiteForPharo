Class {
	#name : 'JadeiteBrowseImplementorsCommand',
	#superclass : 'SpBrowseImplementorsCommand',
	#category : 'Jadeite-ToolsSupportClasses'
}

{ #category : 'accessing' }
JadeiteBrowseImplementorsCommand >> name [

	^ 'Implementors of ' , self jadeiteMenuNameFromSelector
]

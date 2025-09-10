Class {
	#name : 'JadeiteTreeMultipleSelectionMode',
	#superclass : 'SpTreeMultipleSelectionMode',
	#category : 'Jadeite-SupportClasses',
	#package : 'Jadeite-SupportClasses'
}

{ #category : 'selection' }
JadeiteTreeMultipleSelectionMode >> selectPath: aPath [
	"ensure we trigger a selection change."

	self unselectAll.
	aPath ifEmpty: [ ^ self ].
	presenter itemAtPath: aPath ifAbsent: [ ^ self ].

	selection := selection copyWith: aPath
]

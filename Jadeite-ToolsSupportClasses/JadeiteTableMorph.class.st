Class {
	#name : 'JadeiteTableMorph',
	#superclass : 'SpFTTableMorph',
	#instVars : [
		'selectionConfirmationBlock'
	],
	#category : 'Jadeite-ToolsSupportClasses'
}

{ #category : 'selection' }
JadeiteTableMorph >> selectIndexes: anArray andMakeVisibleIf: shouldEnsureVisibleSelection [
	self selectionConfirmationBlock value ifFalse:[^self]. 
	^super selectIndexes: anArray andMakeVisibleIf: shouldEnsureVisibleSelection
]

{ #category : 'accessing' }
JadeiteTableMorph >> selectionConfirmationBlock [

	^ selectionConfirmationBlock ifNil: [
		  selectionConfirmationBlock := [ true ] ]
]

{ #category : 'accessing' }
JadeiteTableMorph >> selectionConfirmationBlock: anObject [

	selectionConfirmationBlock := anObject
]

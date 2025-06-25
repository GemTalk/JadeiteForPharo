Class {
	#name : 'JadeiteTableMorph',
	#superclass : 'SpFTTableMorph',
	#instVars : [
		'selectionConfirmationBlock'
	],
	#category : 'Jadeite-SupportClasses',
	#package : 'Jadeite-SupportClasses'
}

{ #category : 'accessing' }
JadeiteTableMorph class >> defaultSecondarySelectionColor [
	^ self defaultSelectionColor
]

{ #category : 'accessing' }
JadeiteTableMorph >> defaultContainer [

	^ JadeiteTableContainerMorph new
]

{ #category : 'selection' }
JadeiteTableMorph >> mouseLeaveDragging: event [

	highlightedIndexes := {  }.
	self refresh.
	^ super mouseLeaveDragging: event
]

{ #category : 'private' }
JadeiteTableMorph >> recalculateVerticalScrollBar [

	(self dataSource class canUnderstand: #listModel) ifTrue: [
		self dataSource listModel ifNil: [ ^ self ] ].
	^ super recalculateVerticalScrollBar
]

{ #category : 'accessing - colors' }
JadeiteTableMorph >> secondarySelectionColor [

	^Color veryLightGray lighter 
]

{ #category : 'private' }
JadeiteTableMorph >> selectIndex: index event: event [

	self selectedIndex = index ifTrue: [
		(event shiftPressed or: [ event controlKeyPressed ]) ifTrue: [
			self deselectAll ].
		^ self ].
	index
		ifNotNil: [ self selectionStrategy selectIndex: index event: event ]
		ifNil: [ self deselectAll ]
]

{ #category : 'selection' }
JadeiteTableMorph >> selectIndexes: anArray andMakeVisibleIf: shouldEnsureVisibleSelection [

	self selectionConfirmationBlock value ifFalse: [ ^ self ].
	highlightedIndexes := { }. 
	^ super
		  selectIndexes: anArray
		  andMakeVisibleIf: shouldEnsureVisibleSelection
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

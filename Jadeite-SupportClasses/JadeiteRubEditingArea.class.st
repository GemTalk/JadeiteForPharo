Class {
	#name : 'JadeiteRubEditingArea',
	#superclass : 'RubEditingArea',
	#instVars : [
		'lastClickPosition'
	],
	#category : 'Jadeite-SupportClasses',
	#package : 'Jadeite-SupportClasses'
}

{ #category : 'accessing' }
JadeiteRubEditingArea >> lastClickPosition [

	^ lastClickPosition
]

{ #category : 'accessing' }
JadeiteRubEditingArea >> lastClickPosition: anObject [

	lastClickPosition := anObject
]

{ #category : 'event handling' }
JadeiteRubEditingArea >> mouseDown: evt [

	lastClickPosition := evt position.
	^ super mouseDown: evt
]

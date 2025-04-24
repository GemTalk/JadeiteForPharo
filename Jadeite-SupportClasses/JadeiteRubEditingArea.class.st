Class {
	#name : 'JadeiteRubEditingArea',
	#superclass : 'RubEditingArea',
	#instVars : [
		'lastClickPosition'
	],
	#category : 'Jadeite-SupportClasses',
	#package : 'Jadeite-SupportClasses'
}

{ #category : 'formatting' }
JadeiteRubEditingArea >> formatMethodCode [
	"don't do formatting via Ctrl-Shift-F - use Alt-F"

	
]

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

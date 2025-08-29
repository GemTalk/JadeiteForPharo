Class {
	#name : 'JadeiteRubEditingArea',
	#superclass : 'RubEditingArea',
	#instVars : [
		'lastClickPosition'
	],
	#category : 'Jadeite-SupportClasses',
	#package : 'Jadeite-SupportClasses'
}

{ #category : 'drawing' }
JadeiteRubEditingArea >> drawSubMorphOn: aCanvas [

	[ ^ super drawSubmorphsOn: aCanvas ]
		on: Error
		do: [ :ex |
			ex traceCr "quit showing red screens of death but at least give some indication something happened to the user " ]
]

{ #category : 'formatting' }
JadeiteRubEditingArea >> formatMethodCode [
	"Ctrl-Shift-F is always find class in JfP
	Do nothing. Shortcut (and format) should be handled appropriately elsewhere"

	
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

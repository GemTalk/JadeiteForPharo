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
	"Ctrl-Shift-F is always find class in JfP
	 Alt-F is format source.
	This is awful code. Let's hope we can find a way to override this shortcut! "

	| presenter |
	presenter := model model owner owner.
	(presenter class canUnderstand: #findClass) ifTrue: [
		presenter findClass ]
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

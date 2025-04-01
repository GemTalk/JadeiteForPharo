Class {
	#name : 'JadeiteBreakpointCommand',
	#superclass : 'JadeiteCommand',
	#instVars : [
		'stepPoint',
		'lastClickPosition'
	],
	#category : 'Jadeite-SupportClasses',
	#package : 'Jadeite-SupportClasses'
}

{ #category : 'instance creation' }
JadeiteBreakpointCommand class >> forSpecContext: anObject lastClickPosition: aPoint [

	^ (self new lastClickPosition: aPoint)
		  context: anObject;
		  asSpecCommand
]

{ #category : 'testing' }
JadeiteBreakpointCommand >> canBeExecuted [

	stepPoint := self selectedStepPoint.
	^ stepPoint notNil and: [ stepPoint isNumber ]
]

{ #category : 'accessing' }
JadeiteBreakpointCommand >> lastClickPosition [

	^ lastClickPosition
]

{ #category : 'accessing' }
JadeiteBreakpointCommand >> lastClickPosition: anObject [

	lastClickPosition := anObject
]

{ #category : 'accessing' }
JadeiteBreakpointCommand >> selectedStepPoint [

	| stepPointRanges range offset |
	context adapter ifNil: [ ^ self "not built yet" ].
	context methodService ifNil: [ ^ self "not built yet" ].
	offset := (context adapter widget paragraph characterBlockAtPoint:
		           lastClickPosition) stringIndex.
	stepPointRanges := context methodService stepPointRanges.
	range := stepPointRanges
		         detect: [ :theRange | theRange includes: offset ]
		         ifNone: [  ].
	^ range ifNil: [ '*' ] ifNotNil: [ stepPointRanges indexOf: range ]
]

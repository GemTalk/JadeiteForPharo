Class {
	#name : 'JadeiteBreakpointCommand',
	#superclass : 'JadeiteCommand',
	#instVars : [
		'stepPoint'
	],
	#category : 'Jadeite-SupportClasses'
}

{ #category : 'testing' }
JadeiteBreakpointCommand >> canBeExecuted [
	stepPoint := context selectedStepPoint. 
	^stepPoint notNil
]

{ #category : 'accessing' }
JadeiteBreakpointCommand >> selectedStepPoint [

	| stepPointRanges range |
	context adapter ifNil: [ ^ self "not built yet" ].
	stepPointRanges := context methodService stepPointRanges.
	range := stepPointRanges
		         detect: [ :theRange |
			         theRange includes:
				         context adapter widget scrollPane textArea startIndex ]
		         ifNone: [  ].
	^ range ifNil: [ '*' ] ifNotNil: [ stepPointRanges indexOf: range ]
]

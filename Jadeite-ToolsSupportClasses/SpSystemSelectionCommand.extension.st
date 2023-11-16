Extension { #name : 'SpSystemSelectionCommand' }

{ #category : '*Jadeite-ToolsSupportClasses' }
SpSystemSelectionCommand >> jadeiteMenuNameFromSelector [

	| dynamicName abbreviatedName |
	dynamicName := self context selectedSelector ifNil: [ 'it' ].
	abbreviatedName := dynamicName
		                   copyFrom: 1
		                   to: (dynamicName size min: 40).
	abbreviatedName = dynamicName ifFalse: [
		abbreviatedName := abbreviatedName , ' ...' ].
	^ abbreviatedName
]

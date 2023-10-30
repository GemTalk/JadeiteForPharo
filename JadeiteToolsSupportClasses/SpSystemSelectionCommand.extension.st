Extension { #name : 'SpSystemSelectionCommand' }

{ #category : '*JadeiteToolsSupportClasses' }
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

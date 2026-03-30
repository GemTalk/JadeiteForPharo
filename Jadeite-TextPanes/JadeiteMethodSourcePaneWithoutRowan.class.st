Class {
	#name : 'JadeiteMethodSourcePaneWithoutRowan',
	#superclass : 'JadeiteMethodSourcePane',
	#traits : 'JadeiteMethodsTrait + JadeiteClassTrait + JadeiteFindClassTrait',
	#classTraits : 'JadeiteMethodsTrait classTrait + JadeiteClassTrait classTrait + JadeiteFindClassTrait classTrait',
	#category : 'Jadeite-TextPanes',
	#package : 'Jadeite-TextPanes'
}

{ #category : 'as yet unclassified' }
JadeiteMethodSourcePaneWithoutRowan class >> registerFormatSourceCommandWith: commandGroup [
	"format source requires RBParser in server.
	When RBParser is available in a rowan-stubbed server, remove this method"

	
]

{ #category : 'private' }
JadeiteMethodSourcePaneWithoutRowan >> findClassService: classService [

	(self owner class canUnderstand: #findClassService:)
		ifTrue: [ ^ self owner findClassService: classService ]
		ifFalse: [ self owner owner findClassService: classService ]
]

{ #category : 'initialization' }
JadeiteMethodSourcePaneWithoutRowan >> initializePresenters [
	"When RBParser is available again in a rowan-stubbed server, remove this method"

	self bindKeyCombination: $f shift ctrl toAction: [ self findClass ]
]

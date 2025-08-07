Class {
	#name : 'JadeiteMethodSourcePaneWithoutRowan',
	#superclass : 'JadeiteMethodSourcePane',
	#traits : 'JadeiteMethodsTrait + JadeiteClassTrait',
	#classTraits : 'JadeiteMethodsTrait classTrait + JadeiteClassTrait classTrait',
	#category : 'Jadeite-TextPanes',
	#package : 'Jadeite-TextPanes'
}

{ #category : 'as yet unclassified' }
JadeiteMethodSourcePaneWithoutRowan class >> registerFormatSourceCommandWith: commandGroup [
	"format source requires RBParser in server.
	When RBParser is available in a rowan-stubbed server, remove this method"

	
]

{ #category : 'initialization' }
JadeiteMethodSourcePaneWithoutRowan >> initializePresenters [
	"When RBParser is available again in a rowan-stubbed server, remove this method"

	self bindKeyCombination: $f shift ctrl toAction: [ self findClass ]
]

"
This class contains tests for Jadeite for Pharo that (presumably) should pass. 

Other tests in the JadeiteAbstractTestCase hierarchy were ported from Jadeite for Dolphin and are not known to work in pharo yet. 
"
Class {
	#name : 'JadeiteForPharoTestCase',
	#superclass : 'JadeiteAbstractTestCase',
	#instVars : [
		'workspace'
	],
	#category : 'JadeiteTests'
}

{ #category : 'support' }
JadeiteForPharoTestCase >> dismissPopoverAndPrint [

	SpCodePopoverPrintPresenter allInstances do: [ :popup |
		popup dismissAndPrint ]
]

{ #category : 'support' }
JadeiteForPharoTestCase >> displayAndPrint [

	workspace codePane jadeDisplay.
	self dismissPopoverAndPrint
]

{ #category : 'support' }
JadeiteForPharoTestCase >> tearDown [
	super tearDown.
	workspace
		ifNotNil: 
			[workspace isModified: false.
			self destroy: workspace]
]

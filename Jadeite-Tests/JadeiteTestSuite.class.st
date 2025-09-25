Class {
	#name : 'JadeiteTestSuite',
	#superclass : 'TestSuite',
	#classVars : [
		'RandomSeed'
	],
	#category : 'Jadeite-Tests',
	#package : 'Jadeite-Tests'
}

{ #category : 'accessing' }
JadeiteTestSuite class >> randomSeed [

	RandomSeed ifNil: [
		| seed |
		seed := self uiManager request: 'Enter random seed'.
		RandomSeed := (seed isNil or: [ seed isEmpty ])
			              ifTrue: [ Random new seed ]
			              ifFalse: [ seed asInteger ].
		('----- Test started with random seed ' , RandomSeed printString
		 , ' -----') traceCr ].
	^ RandomSeed
]

{ #category : 'accessing' }
JadeiteTestSuite class >> randomSeed: anInteger [

	RandomSeed := anInteger 
]

{ #category : 'initialization' }
JadeiteTestSuite >> initialize [

	super initialize.
	randomGenerator seed: self class randomSeed
]

{ #category : 'running' }
JadeiteTestSuite >> resultClass [

	^ JadeiteTestAsserter classForTestResult
]

{ #category : 'running' }
JadeiteTestSuite >> shuffledTests [
	
	^ self tests shuffledBy: randomGenerator
]

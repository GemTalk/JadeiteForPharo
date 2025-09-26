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
	"Use this randomSeed to run JfP tests with Dr Tests
	self randomSeed: 1234567"

	RandomSeed ifNil: [
		| seed |
		seed := self uiManager request:
			        'Enter random seed (leave blank for new random seed)'.
		seed isNil ifTrue: [ ^ JadeiteTestSuiteError signal ].
		RandomSeed := (seed isNil or: [ seed isEmpty ])
			              ifTrue: [ Random new seed ]
			              ifFalse: [ seed asInteger ] ].
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

	('----- Test started with random seed '
	 , self class randomSeed printString , ' -----') traceCr.
	^ self tests shuffledBy: (Random new seed: self class randomSeed)
]

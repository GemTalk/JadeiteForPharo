Class {
	#name : 'GsTestMethod',
	#superclass : 'Object',
	#instVars : [
		'methodName',
		'result'
	],
	#category : 'Jadeite-SUnitBrowser'
}

{ #category : 'as yet unclassified' }
GsTestMethod class >> icon [
	"Answers an <Icon> that can be used to represent this class"

	^Icon fromId: 'COMInterface.ico'
]

{ #category : 'as yet unclassified' }
GsTestMethod class >> name: aString [

	^super new initialize
		methodName: aString;
		yourself
]

{ #category : 'as yet unclassified' }
GsTestMethod >> icon [

	result ifNil: [^self class icon].

	(result = 'passed') ifTrue: [^True icon].
	(result = 'failure') ifTrue: [^Warning icon].
	(result = 'error') ifTrue: [^False icon].

	^self class icon

	
]

{ #category : 'as yet unclassified' }
GsTestMethod >> methodName [
	^methodName
]

{ #category : 'as yet unclassified' }
GsTestMethod >> methodName: anObject [
	methodName := anObject
]

{ #category : 'as yet unclassified' }
GsTestMethod >> result [
	^result
]

{ #category : 'as yet unclassified' }
GsTestMethod >> result: anObject [
	result := anObject
]

{ #category : 'as yet unclassified' }
GsTestMethod >> setError [

	result := 'error'

	
]

{ #category : 'as yet unclassified' }
GsTestMethod >> setFailure [

	result := 'failure'
]

{ #category : 'as yet unclassified' }
GsTestMethod >> setPassed [

	result := 'passed'
	
]

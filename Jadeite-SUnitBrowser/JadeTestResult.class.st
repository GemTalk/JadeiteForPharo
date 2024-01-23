Class {
	#name : 'JadeTestResult',
	#superclass : 'Object',
	#instVars : [
		'failures',
		'errors',
		'passed',
		'summary'
	],
	#category : 'Jadeite-SUnitBrowser'
}

{ #category : 'as yet unclassified' }
JadeTestResult class >> new [

	^super new initialize
]

{ #category : 'as yet unclassified' }
JadeTestResult >> addError: selector [

	errors add: selector
]

{ #category : 'as yet unclassified' }
JadeTestResult >> addFailure: selector [

	failures add: selector
]

{ #category : 'as yet unclassified' }
JadeTestResult >> addPassed: selector [

	passed add: selector
]

{ #category : 'as yet unclassified' }
JadeTestResult >> backgroundColor [

	self hasErrors ifTrue: [^Color red muchLighter].

	self hasWarnings ifTrue: [^Color yellow muchLighter].

	self hasPassed ifTrue: [^Color fromHexString: #CEF1D1].

	^JadeiteApplication defaultBackgroundColor
]

{ #category : 'as yet unclassified' }
JadeTestResult >> errors [
	^errors
]

{ #category : 'as yet unclassified' }
JadeTestResult >> errors: anObject [
	errors := anObject
]

{ #category : 'as yet unclassified' }
JadeTestResult >> failures [
	^failures
]

{ #category : 'as yet unclassified' }
JadeTestResult >> failures: anObject [
	failures := anObject
]

{ #category : 'as yet unclassified' }
JadeTestResult >> hasErrors [

	^errors size > 0
]

{ #category : 'as yet unclassified' }
JadeTestResult >> hasPassed [

	^(errors size = 0) and: [failures size = 0]
]

{ #category : 'as yet unclassified' }
JadeTestResult >> hasWarnings [

	^failures size > 0
]

{ #category : 'as yet unclassified' }
JadeTestResult >> initialize [

	super initialize.

	errors := OrderedCollection new.
	failures := OrderedCollection new.
	passed := OrderedCollection new.
]

{ #category : 'as yet unclassified' }
JadeTestResult >> numberOfTests [

	^failures size + errors size + passed size
]

{ #category : 'as yet unclassified' }
JadeTestResult >> passed [
	^passed
]

{ #category : 'as yet unclassified' }
JadeTestResult >> passed: anObject [
	passed := anObject
]

{ #category : 'as yet unclassified' }
JadeTestResult >> setSummary [

	summary := 	self numberOfTests printString, ' run, ', passed size printString, ' passed, ', failures size printString, ' failures, ', errors size printString, ' errors'
]

{ #category : 'as yet unclassified' }
JadeTestResult >> summary [
	^summary
]

{ #category : 'as yet unclassified' }
JadeTestResult >> summary: anObject [
	summary := anObject
]

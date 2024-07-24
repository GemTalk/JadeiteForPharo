Class {
	#name : 'RowanDisplayLabelVariableService',
	#superclass : 'String',
	#instVars : [
		'value',
		'oop'
	],
	#category : 'Jadeite-RowanClientServicesClient',
	#package : 'Jadeite-RowanClientServicesClient'
}

{ #category : 'public' }
RowanDisplayLabelVariableService >> _key [
	^String new
]

{ #category : 'public' }
RowanDisplayLabelVariableService >> displayOop [

	^String new
]

{ #category : 'public' }
RowanDisplayLabelVariableService >> displayStringOn: displayThing [
	displayThing font beItalic.
	displayThing forecolor: Color blue
]

{ #category : 'public' }
RowanDisplayLabelVariableService >> initialize [

	super initialize.
	oop := nil.
	value := nil
]

{ #category : 'public' }
RowanDisplayLabelVariableService >> isDisplayLabel [

	^true
]

{ #category : 'testing' }
RowanDisplayLabelVariableService >> isVariableDisplayLabel [

	^true
]

{ #category : 'public' }
RowanDisplayLabelVariableService >> key [
	^String new
]

{ #category : 'public' }
RowanDisplayLabelVariableService >> value [
	
	^value
]

{ #category : 'public' }
RowanDisplayLabelVariableService >> value: aString [
	value := aString
]

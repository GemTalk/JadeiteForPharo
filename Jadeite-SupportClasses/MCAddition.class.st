"
A MCAddition represents the operation to add an entity to a snapshot. 
"
Class {
	#name : 'MCAddition',
	#superclass : 'RowanPatchOperation',
	#instVars : [
		'definition'
	],
	#category : 'Jadeite-SupportClasses',
	#package : 'Jadeite-SupportClasses'
}

{ #category : 'instance creation' }
MCAddition class >> of: aDefinition [
	^ self new intializeWithDefinition: aDefinition
]

{ #category : 'accessing' }
MCAddition >> baseDefinition [
	^ nil
]

{ #category : 'accessing' }
MCAddition >> basicApplyTo: anObject [
	anObject addDefinition: definition
]

{ #category : 'accessing' }
MCAddition >> className [ 
	^definition className
]

{ #category : 'accessing' }
MCAddition >> definition [
	"for testing"

	^definition
]

{ #category : 'accessing' }
MCAddition >> detailsString [

	^definition detailsString.
]

{ #category : 'accessing' }
MCAddition >> fromSource [
	^ ''
]

{ #category : 'initializing' }
MCAddition >> initialize: aStream [

	definition := MCDefinition fromStream: aStream.
]

{ #category : 'initializing' }
MCAddition >> intializeWithDefinition: aDefinition [
	definition := aDefinition
]

{ #category : 'accessing' }
MCAddition >> inverse [
	^ MCRemoval of: definition
]

{ #category : 'testing' }
MCAddition >> isAddition [
	^ true
]

{ #category : 'testing' }
MCAddition >> isClassPatch [
	^definition isClassDefinition
]

{ #category : 'accessing' }
MCAddition >> packageName [

	^definition packageName
]

{ #category : 'private - factory' }
MCAddition >> revert: session [
	definition revertAddition: session.
	reverted := true.  
]

{ #category : 'accessing' }
MCAddition >> selector [

	^definition selector
]

{ #category : 'accessing' }
MCAddition >> targetClass [
	^definition actualClass 
]

{ #category : 'accessing' }
MCAddition >> targetDefinition [
	^ definition
]

{ #category : 'accessing' }
MCAddition >> toSource [
	^ definition diffSource
]

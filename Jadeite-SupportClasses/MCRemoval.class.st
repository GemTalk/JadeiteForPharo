"
A MCRemoval represents the removal of an entity of a given snapshot.
"
Class {
	#name : 'MCRemoval',
	#superclass : 'RowanPatchOperation',
	#instVars : [
		'definition'
	],
	#category : 'Jadeite-SupportClasses',
	#package : 'Jadeite-SupportClasses'
}

{ #category : 'instance creation' }
MCRemoval class >> of: aDefinition [
	^ self new intializeWithDefinition: aDefinition
]

{ #category : 'accessing' }
MCRemoval >> baseDefinition [
	^ definition
]

{ #category : 'accessing' }
MCRemoval >> basicApplyTo: anObject [
	anObject removeDefinition: definition
]

{ #category : 'accessing' }
MCRemoval >> className [ 
	^definition className
]

{ #category : 'accessing' }
MCRemoval >> definition [
	"for testing"

	^definition
]

{ #category : 'accessing' }
MCRemoval >> detailsString [

	^definition detailsString.

]

{ #category : 'accessing' }
MCRemoval >> fromSource [
	^ definition diffSource
]

{ #category : 'initializing' }
MCRemoval >> initialize: aStream [

	definition := MCDefinition fromStream: aStream.

]

{ #category : 'initializing' }
MCRemoval >> intializeWithDefinition: aDefinition [
	definition := aDefinition
]

{ #category : 'accessing' }
MCRemoval >> inverse [
	^ MCAddition of: definition
]

{ #category : 'testing' }
MCRemoval >> isClassPatch [
	^definition isClassDefinition
]

{ #category : 'testing' }
MCRemoval >> isRemoval [
	^ true
]

{ #category : 'accessing' }
MCRemoval >> packageName [

	^definition packageName
]

{ #category : 'private - factory' }
MCRemoval >> revert: session [
	definition revert: session.
	reverted := true.  
]

{ #category : 'accessing' }
MCRemoval >> selector [

	^definition selector
]

{ #category : 'accessing' }
MCRemoval >> summarySuffix [
	^ ' (removed)'
]

{ #category : 'accessing' }
MCRemoval >> targetClass [
	^ definition actualClass
]

{ #category : 'accessing' }
MCRemoval >> targetDefinition [
	^ nil
]

{ #category : 'accessing' }
MCRemoval >> toSource [
	^ ''
]

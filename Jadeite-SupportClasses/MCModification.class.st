"
A MCModification represents the operation to modify an entity to a snapshot. 
"
Class {
	#name : 'MCModification',
	#superclass : 'RowanPatchOperation',
	#instVars : [
		'obsoletion',
		'modification'
	],
	#category : 'Jadeite-SupportClasses'
}

{ #category : 'instance creation' }
MCModification class >> of: base to: target [
	^ self new initializeWithBase: base target: target
]

{ #category : 'accessing' }
MCModification >> baseDefinition [
	^ obsoletion
]

{ #category : 'accessing' }
MCModification >> basicApplyTo: anObject [
	anObject modifyDefinition: obsoletion to: modification
]

{ #category : 'accessing' }
MCModification >> className [ 
	^obsoletion className
]

{ #category : 'accessing' }
MCModification >> definition [
	^ modification
]

{ #category : 'accessing' }
MCModification >> detailsString [

	^modification detailsString.

]

{ #category : 'accessing' }
MCModification >> fromSource [
	^ obsoletion source
]

{ #category : 'initializing' }
MCModification >> initialize: aStream [

	obsoletion := MCDefinition fromStream: aStream.
	modification := MCDefinition fromStream: aStream.
]

{ #category : 'initializing' }
MCModification >> initializeWithBase: base target: target [
	obsoletion := base.
	modification := target.
]

{ #category : 'accessing' }
MCModification >> inverse [
	^ MCModification of: modification to: obsoletion
]

{ #category : 'testing' }
MCModification >> isClassPatch [
	^obsoletion isClassDefinition
]

{ #category : 'testing' }
MCModification >> isModification [
	^ true
]

{ #category : 'accessing' }
MCModification >> modification [
	"for testing"

	^modification
]

{ #category : 'accessing' }
MCModification >> obsoletion [
	"for testing"

	^obsoletion
]

{ #category : 'accessing' }
MCModification >> packageName [ 

	^obsoletion packageName.
]

{ #category : 'accessing' }
MCModification >> printAnnotations: request on: aStream [
	aStream nextPutAll: 'old: '.
	obsoletion printAnnotations: request on: aStream.
	aStream cr.
	aStream nextPutAll: 'new: '.
	modification printAnnotations: request on: aStream.
]

{ #category : 'private - factory' }
MCModification >> revert: session [
	obsoletion revert: session.
	reverted := true. 
]

{ #category : 'accessing' }
MCModification >> selector [

	^modification selector.
]

{ #category : 'accessing' }
MCModification >> summarySuffix [
	^ modification summarySuffixOver: obsoletion

]

{ #category : 'printing' }
MCModification >> summarySuffixOver: previousDefinition [
	| sourceChanged categoryChanged timeStampChanged |
	sourceChanged := self source ~= previousDefinition source.
	timeStampChanged := self timeStamp ~= previousDefinition timeStamp.
	categoryChanged := self category ~= previousDefinition category.
	sourceChanged | timeStampChanged | categoryChanged
		ifFalse: [ ^super summarySuffixOver: previousDefinition ].
	sourceChanged ifTrue: [
		^categoryChanged
			ifTrue: [ ' (changed and recategorized)' ]
			ifFalse: [ ' (changed)' ] ].
	timeStampChanged & categoryChanged
		ifTrue: [^ ' (recategorized and different time stamp)' ].
	^categoryChanged
		ifTrue: [ ' (only recategorized)' ]
		ifFalse: [ ' (only different time stamp)' ]

]

{ #category : 'accessing' }
MCModification >> targetClass [
	^ obsoletion actualClass
]

{ #category : 'accessing' }
MCModification >> targetDefinition [
	^ modification
]

{ #category : 'accessing' }
MCModification >> toSource [
	^ modification diffSource
]

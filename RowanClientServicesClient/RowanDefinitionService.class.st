Class {
	#name : 'RowanDefinitionService',
	#superclass : 'RowanService',
	#instVars : [
		'name',
		'properties',
		'session'
	],
	#category : 'RowanClientServicesClient'
}

{ #category : 'comparing' }
RowanDefinitionService >> = definitionService [
	^definitionService isService
		and: [definitionService isDefinitionService and: [name = definitionService name]]
]

{ #category : 'public' }
RowanDefinitionService >> excludedInstVars [

	^super excludedInstVars , #('session')
]

{ #category : 'comparing' }
RowanDefinitionService >> hash [
	^self name hash
]

{ #category : 'public' }
RowanDefinitionService >> indexOfSessionInstVar [
	^10
]

{ #category : 'public' }
RowanDefinitionService >> isDefinitionService [

	^true
]

{ #category : 'accessing' }
RowanDefinitionService >> name [
	^name
]

{ #category : 'accessing' }
RowanDefinitionService >> name: anObject [
	name := anObject
]

{ #category : 'accessing' }
RowanDefinitionService >> properties [
	^properties
]

{ #category : 'accessing' }
RowanDefinitionService >> properties: anObject [
	properties := anObject
]

{ #category : 'accessing' }
RowanDefinitionService >> session [
	^session
]

{ #category : 'accessing' }
RowanDefinitionService >> session: anObject [
	session := anObject
]

{ #category : 'public' }
RowanDefinitionService >> shouldReplicateInstVarAtIndex: index newService: newService [
	(super shouldReplicateInstVarAtIndex: index newService: newService) ifFalse:[^false]. 
	self indexOfSessionInstVar = index ifTrue: [^false].
	^true
]

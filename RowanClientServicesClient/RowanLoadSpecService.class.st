Class {
	#name : 'RowanLoadSpecService',
	#superclass : 'RowanInspectorService',
	#instVars : [
		'loadSpecOop',
		'loadSpecPath',
		'session',
		'comment',
		'conditionalAttributes',
		'platformProperties',
		'componentNames'
	],
	#category : 'RowanClientServicesClient'
}

{ #category : 'accessing' }
RowanLoadSpecService class >> templateClassName [ 

	^#RowanLoadSpecService
]

{ #category : 'accessing' }
RowanLoadSpecService >> comment [
	^comment
]

{ #category : 'accessing' }
RowanLoadSpecService >> comment: anObject [
	comment := anObject
]

{ #category : 'accessing' }
RowanLoadSpecService >> componentNames [
	^componentNames
]

{ #category : 'accessing' }
RowanLoadSpecService >> componentNames: anObject [
	componentNames := anObject
]

{ #category : 'commands' }
RowanLoadSpecService >> conditionalAttributeItem: new updatedAtIndex: index [
	self
		command: #setConditionalAttributes:;
		commandArgs: (Array with: self conditionalAttributes).
	self issueCommand: self session: session
]

{ #category : 'accessing' }
RowanLoadSpecService >> conditionalAttributes [
	^conditionalAttributes
]

{ #category : 'accessing' }
RowanLoadSpecService >> conditionalAttributes: anObject [
	conditionalAttributes := anObject
]

{ #category : 'private' }
RowanLoadSpecService >> excludedInstVars [

	^super excludedInstVars , #('session')
]

{ #category : 'commands' }
RowanLoadSpecService >> export [
	self
		command: #export;
		commandArgs: Array new.
	self issueCommand: self session: session
]

{ #category : 'constants' }
RowanLoadSpecService >> indexOfSessionInstVar [
	^28
]

{ #category : 'commands' }
RowanLoadSpecService >> load [
	self
		command: #load;
		commandArgs: Array new.
	self issueCommand: self session: session
]

{ #category : 'accessing' }
RowanLoadSpecService >> loadSpecPath [
	^loadSpecPath
]

{ #category : 'accessing' }
RowanLoadSpecService >> loadSpecPath: anObject [
	loadSpecPath := anObject
]

{ #category : 'accessing' }
RowanLoadSpecService >> platformProperties [
	^platformProperties
]

{ #category : 'accessing' }
RowanLoadSpecService >> platformProperties: anObject [
	platformProperties := anObject
]

{ #category : 'commands' }
RowanLoadSpecService >> platformPropertyItem: association updatedAtIndex: value [
	self halt. 
	self
		command: #setPlatformProperty:to:;
		commandArgs: (Array with: association key with: value).
	self issueCommand: self session: session
]

{ #category : 'accessing' }
RowanLoadSpecService >> session [
	^session
]

{ #category : 'accessing' }
RowanLoadSpecService >> session: anObject [
	session := anObject
]

{ #category : 'commands' }
RowanLoadSpecService >> setComment: aString [
	self
		command: #setComment:;
		commandArgs: (Array with: aString).
	self issueCommand: self session: session
]

{ #category : 'commands' }
RowanLoadSpecService >> setLoadSpecProperty: property to: value [
	self
		command: #setLoadSpecProperty:to:;
		commandArgs: (Array with: property with: value).
	self issueCommand: self session: session
]

{ #category : 'commands' }
RowanLoadSpecService >> setPlatformProperty: property to: value [
	self
		command: #setPlatformProperty:to:;
		commandArgs: (Array with: property with: value).
	self issueCommand: self session: session
]

{ #category : 'public' }
RowanLoadSpecService >> shouldReplicateInstVarAtIndex: index newService: newService [
	(super shouldReplicateInstVarAtIndex: index newService: newService) ifFalse:[^false]. 
	self indexOfSessionInstVar = index ifTrue: [^false].
	^true
]

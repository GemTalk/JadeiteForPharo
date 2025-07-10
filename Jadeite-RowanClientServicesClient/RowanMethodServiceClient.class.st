Class {
	#name : 'RowanMethodServiceClient',
	#superclass : 'RowanMethodService',
	#instVars : [
		'inCommand',
		'serviceCompletionBlock',
		'catchBlock'
	],
	#category : 'Jadeite-RowanClientServicesClient',
	#package : 'Jadeite-RowanClientServicesClient'
}

{ #category : 'accessing' }
RowanMethodServiceClient >> catchBlock [

	^ catchBlock ifNil: [ super catchBlock ]
]

{ #category : 'accessing' }
RowanMethodServiceClient >> catchBlock: anObject [

	catchBlock := anObject
]

{ #category : 'accessing' }
RowanMethodServiceClient >> inCommand [

	^ inCommand ifNil: [ inCommand := RowanSemaphore new ]
]

{ #category : 'accessing' }
RowanMethodServiceClient >> inCommand: anObject [

	inCommand := anObject
]

{ #category : 'constants' }
RowanMethodServiceClient >> indexOfFirstReferenceInstVar [

	^37
]

{ #category : 'constants' }
RowanMethodServiceClient >> indexOfInCommandInstVar [
	"performance enhancement"

	^44
]

{ #category : 'constants' }
RowanMethodServiceClient >> indexOfServiceCompletionBlock [
	"performance enhancement"

	^45
]

{ #category : 'constants' }
RowanMethodServiceClient >> indexOfSourceInstVar [
	^12
]

{ #category : 'constants' }
RowanMethodServiceClient >> indexOfStepPointsInstVar [
	^26
]

{ #category : 'constants' }
RowanMethodServiceClient >> indexOfTestResultInstVar [
	^31
]

{ #category : 'initialization' }
RowanMethodServiceClient >> initialize [

	super initialize. 
	catchBlock := [ ]
]

{ #category : 'updates' }
RowanMethodServiceClient >> methodUpdate: presenter browser: browser [

	presenter list do: [ :methodService |
		methodService replicateFrom: self "#replicateFrom: will ensure we only replicate the proper methods" ].
	browser methodListPresenter selections isEmpty ifTrue: [ ^ self ].
	browser methodListPresenter selectedItem = self ifTrue: [
		browser methodSourcePresenter hasUnacceptedEdits ifFalse: [
			browser updateMethodSourceFor: self ] ]
]

{ #category : 'accessing' }
RowanMethodServiceClient >> serviceCompletionBlock [

	^serviceCompletionBlock
]

{ #category : 'accessing' }
RowanMethodServiceClient >> serviceCompletionBlock: aBlock [

	serviceCompletionBlock := aBlock 
]

{ #category : 'public' }
RowanMethodServiceClient >> shouldReplicateInstVarAtIndex: index newService: newService [
	"first reference is only valid on the first return of a method service for a particular browser. 
	It may be better to (someday) move firstReference to the browser state"

	| isTestResultInstVar |
	(super shouldReplicateInstVarAtIndex: index newService: newService)
		ifFalse: [ ^ false ].
	index = self indexOfFirstReferenceInstVar ifTrue: [
		firstReference ifNotNil: [ ^ false ] ].
	isTestResultInstVar := self indexOfTestResultInstVar = index.
	isTestResultInstVar ifTrue: [ ^ false ].
	self indexOfSourceInstVar = index ifTrue: [
		^ newService source isNil not ]. "fastRefresh nils out stepPoints and sources for performance"
	self indexOfStepPointsInstVar = index ifTrue: [
		^ newService stepPoints isNil not ].
	(self indexOfSourceInstVar = index and: [
		 (newService instVarAt: index) notNil ]) ifTrue: [ ^ false ].
	^ true
]

{ #category : 'accessing' }
RowanMethodServiceClient >> stepPointRanges [

	^ stepPoints collect: [ :array | self stepPointRangeFrom: array ]
]

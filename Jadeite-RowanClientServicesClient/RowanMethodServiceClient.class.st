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

{ #category : 'accessing' }
RowanMethodServiceClient >> indexOfInCommandInstVar [
	"performance enhancement"

	^44
]

{ #category : 'accessing' }
RowanMethodServiceClient >> indexOfServiceCompletionBlock [
	"performance enhancement"

	^45
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
		browser updateMethodSourceFor: self ]
]

{ #category : 'accessing' }
RowanMethodServiceClient >> serviceCompletionBlock [

	^serviceCompletionBlock
]

{ #category : 'accessing' }
RowanMethodServiceClient >> serviceCompletionBlock: aBlock [

	serviceCompletionBlock := aBlock 
]

{ #category : 'accessing' }
RowanMethodServiceClient >> stepPointRanges [

	^ stepPoints collect: [ :array | self stepPointRangeFrom: array ]
]

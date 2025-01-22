Class {
	#name : 'RowanClassServiceClient',
	#superclass : 'RowanClassService',
	#instVars : [
		'subclassServices',
		'inCommand',
		'compileErrorHandler',
		'serviceCompletionBlock',
		'alwaysForked'
	],
	#category : 'Jadeite-RowanClientServicesClient',
	#package : 'Jadeite-RowanClientServicesClient'
}

{ #category : 'accessing' }
RowanClassServiceClient >> alwaysForked [

	^ alwaysForked ifNil: [ alwaysForked := false ]
]

{ #category : 'accessing' }
RowanClassServiceClient >> alwaysForked: anObject [

	alwaysForked := anObject
]

{ #category : 'accessing' }
RowanClassServiceClient >> compileErrorHandler [

	^ compileErrorHandler
]

{ #category : 'accessing' }
RowanClassServiceClient >> compileErrorHandler: anObject [

	compileErrorHandler := anObject
]

{ #category : 'actions' }
RowanClassServiceClient >> handleCompileError: compileError [

	compileErrorHandler ifNotNil: [
		compileErrorHandler value: compileError ]
]

{ #category : 'accessing' }
RowanClassServiceClient >> inCommand [

	^ inCommand ifNil: [ inCommand := RowanSemaphore new ]
]

{ #category : 'accessing' }
RowanClassServiceClient >> inCommand: anObject [

	inCommand := anObject
]

{ #category : 'constants' }
RowanClassServiceClient >> indexOfInCommandInstVar [
	"performance enhancement"

	^49
]

{ #category : 'constants' }
RowanClassServiceClient >> indexOfMetaInstVar [
	"performance enhancement"
	^20
]

{ #category : 'constants' }
RowanClassServiceClient >> indexOfMethodsInstVar [
	"performance enhancement"

	^28
]

{ #category : 'constants' }
RowanClassServiceClient >> indexOfServiceCompletionBlock [
	"performance enhancement"

	^51
]

{ #category : 'initialization' }
RowanClassServiceClient >> initialize [
	
	super initialize. 
	subclassServices := OrderedCollection new.
	alwaysForked := false. 
]

{ #category : 'testing' }
RowanClassServiceClient >> notAlwaysForked [

	^ self alwaysForked not
]

{ #category : 'accessing' }
RowanClassServiceClient >> serviceCompletionBlock [

	^ serviceCompletionBlock
]

{ #category : 'accessing' }
RowanClassServiceClient >> serviceCompletionBlock: anObject [

	serviceCompletionBlock := anObject
]

{ #category : 'accessing' }
RowanClassServiceClient >> subclassServices [

	^ subclassServices ifNil:[subclassServices := OrderedCollection new]
]

{ #category : 'accessing' }
RowanClassServiceClient >> subclassServices: anObject [

	subclassServices := anObject
]

{ #category : 'accessing' }
RowanClassServiceClient >> testMethods [ 

	^self methods select:[:methodService | methodService isTestMethod]
]

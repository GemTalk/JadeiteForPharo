Class {
	#name : 'RowanClassServiceClient',
	#superclass : 'RowanClassService',
	#instVars : [
		'subclassServices',
		'inCommand',
		'compileErrorHandler',
		'serviceCompletionBlock'
	],
	#category : 'Jadeite-RowanClientServicesClient',
	#package : 'Jadeite-RowanClientServicesClient'
}

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

{ #category : 'initialization' }
RowanClassServiceClient >> initialize [
	
	super initialize. 
	subclassServices := OrderedCollection new.
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

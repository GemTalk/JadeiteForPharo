Class {
	#name : 'RowanBrowserServiceClient',
	#superclass : 'RowanBrowserService',
	#instVars : [
		'inCommand',
		'serviceCompletionBlock',
		'compileErrorHandler'
	],
	#category : 'Jadeite-RowanClientServicesClient',
	#package : 'Jadeite-RowanClientServicesClient'
}

{ #category : 'accessing' }
RowanBrowserServiceClient >> compileErrorHandler [

	^ compileErrorHandler
]

{ #category : 'accessing' }
RowanBrowserServiceClient >> compileErrorHandler: anObject [

	compileErrorHandler := anObject
]

{ #category : 'actions' }
RowanBrowserServiceClient >> handleCompileError: compileError [

	compileErrorHandler ifNotNil: [
		compileErrorHandler value: compileError ]
]

{ #category : 'accessing' }
RowanBrowserServiceClient >> inCommand [

	^ inCommand ifNil: [ inCommand := RowanSemaphore new ]
]

{ #category : 'accessing' }
RowanBrowserServiceClient >> inCommand: anObject [

	inCommand := anObject
]

{ #category : 'accessing' }
RowanBrowserServiceClient >> indexOfInCommandInstVar [
	"performance enhancement"

	^21
]

{ #category : 'accessing' }
RowanBrowserServiceClient >> indexOfServiceCompletionBlock [
	"performance enhancement"

	^22
]

{ #category : 'accessing' }
RowanBrowserServiceClient >> serviceCompletionBlock [

	^ serviceCompletionBlock
]

{ #category : 'accessing' }
RowanBrowserServiceClient >> serviceCompletionBlock: anObject [

	serviceCompletionBlock := anObject
]

Class {
	#name : 'RowanInspectorServiceClient',
	#superclass : 'RowanInspectorService',
	#instVars : [
		'inCommand',
		'serviceCompletionBlock',
		'catchBlock'
	],
	#category : 'Jadeite-RowanClientServicesClient',
	#package : 'Jadeite-RowanClientServicesClient'
}

{ #category : 'accessing' }
RowanInspectorServiceClient >> catchBlock [

	^ catchBlock ifNil: [ super catchBlock ]
]

{ #category : 'accessing' }
RowanInspectorServiceClient >> catchBlock: anObject [

	catchBlock := anObject
]

{ #category : 'inspecting' }
RowanInspectorServiceClient >> executeThenInspect: string context: anOop session: session windowHandle: handle onCompletion: completionBlock [

	self
		command: #executeThenInspect:context:inWindow:;
		commandArgs: (Array with: string with: anOop with: handle);
		catchBlock: [ :error |
			UIManager default alert: 'Unable to inspect object - Error: ' , error messageText ].
	RowanServiceUpdater current
		issueCommand: self
		session: session
		onCompletion: completionBlock
]

{ #category : 'inspecting' }
RowanInspectorServiceClient >> executeThenInspectBytes: string context: anOop session: session windowHandle: handle onCompletion: completionBlock [

	self
		command: #executeThenInspectBytes:context:inWindow:;
		commandArgs: (Array with: string with: anOop with: handle);
		catchBlock: [ :error |
			UIManager default alert: 'RSR error: ' , error messageText ].
	RowanServiceUpdater current
		issueCommand: self
		session: session
		onCompletion: completionBlock
]

{ #category : 'accessing' }
RowanInspectorServiceClient >> inCommand [

	^ inCommand ifNil: [ inCommand := RowanSemaphore new ]
]

{ #category : 'accessing' }
RowanInspectorServiceClient >> inCommand: anObject [

	inCommand := anObject
]

{ #category : 'accessing' }
RowanInspectorServiceClient >> indexOfInCommandInstVar [
	"performance enhancement"

	^29
]

{ #category : 'service completion' }
RowanInspectorServiceClient >> serviceCompletionBlock [

	^ serviceCompletionBlock
]

{ #category : 'service completion' }
RowanInspectorServiceClient >> serviceCompletionBlock: anObject [ 

	serviceCompletionBlock := anObject
]

Class {
	#name : 'RowanBrowserServiceClient',
	#superclass : 'RowanBrowserService',
	#instVars : [
		'inCommand'
	],
	#category : 'Jadeite-RowanClientServicesClient'
}

{ #category : 'accessing' }
RowanBrowserServiceClient >> inCommand [

	^ inCommand ifNil: [ inCommand := RowanSemaphore new ]
]

{ #category : 'accessing' }
RowanBrowserServiceClient >> inCommand: anObject [

	inCommand := anObject
]

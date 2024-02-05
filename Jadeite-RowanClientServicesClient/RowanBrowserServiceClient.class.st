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

	^ inCommand
]

{ #category : 'accessing' }
RowanBrowserServiceClient >> inCommand: anObject [

	inCommand := anObject
]

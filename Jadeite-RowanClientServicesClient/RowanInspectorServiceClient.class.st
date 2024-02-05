Class {
	#name : 'RowanInspectorServiceClient',
	#superclass : 'RowanInspectorService',
	#instVars : [
		'inCommand'
	],
	#category : 'Jadeite-RowanClientServicesClient'
}

{ #category : 'accessing' }
RowanInspectorServiceClient >> inCommand [

	^ inCommand ifNil: [ inCommand := Semaphore forMutualExclusion ]
]

{ #category : 'accessing' }
RowanInspectorServiceClient >> inCommand: anObject [

	inCommand := anObject
]

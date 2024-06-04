Class {
	#name : 'RowanClassServiceClient',
	#superclass : 'RowanClassService',
	#instVars : [
		'subclassServices',
		'inCommand'
	],
	#category : 'Jadeite-RowanClientServicesClient'
}

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
RowanClassServiceClient >> subclassServices [

	^ subclassServices ifNil:[subclassServices := OrderedCollection new]
]

{ #category : 'accessing' }
RowanClassServiceClient >> subclassServices: anObject [

	subclassServices := anObject
]

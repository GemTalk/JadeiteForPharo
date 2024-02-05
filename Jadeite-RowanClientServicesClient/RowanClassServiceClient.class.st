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

	^ inCommand ifNil: [ inCommand := Semaphore forMutualExclusion ]
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

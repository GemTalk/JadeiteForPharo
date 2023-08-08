Class {
	#name : 'RowanClassServiceClient',
	#superclass : 'RowanClassService',
	#instVars : [
		'subclassServices'
	],
	#category : 'RowanClientServicesClient'
}

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

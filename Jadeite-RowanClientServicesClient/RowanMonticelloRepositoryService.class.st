Class {
	#name : 'RowanMonticelloRepositoryService',
	#superclass : 'RowanService',
	#instVars : [
		'description'
	],
	#category : 'Jadeite-RowanClientServicesClient',
	#package : 'Jadeite-RowanClientServicesClient'
}

{ #category : 'accessing' }
RowanMonticelloRepositoryService class >> templateClassName [ 

	^#RowanMonticelloRepositoryService
]

{ #category : 'accessing' }
RowanMonticelloRepositoryService >> description [

	^ description
]

{ #category : 'accessing' }
RowanMonticelloRepositoryService >> description: anObject [

	description := anObject
]

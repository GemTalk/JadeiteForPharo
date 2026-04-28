Class {
	#name : 'RowanMonticelloRepositoryService',
	#superclass : 'RowanService',
	#instVars : [
		'description',
		'repositoryPackages',
		'repositoryOop'
	],
	#category : 'Jadeite-RowanClientServicesClient',
	#package : 'Jadeite-RowanClientServicesClient'
}

{ #category : 'accessing' }
RowanMonticelloRepositoryService class >> templateClassName [ 

	^#RowanMonticelloRepositoryService
]

{ #category : 'converting' }
RowanMonticelloRepositoryService >> asString [

	^ self description
]

{ #category : 'testing' }
RowanMonticelloRepositoryService >> isSeparator [

	^ false
]

{ #category : 'accessing' }
RowanMonticelloRepositoryService >> description [

	^ description
]

{ #category : 'accessing' }
RowanMonticelloRepositoryService >> description: anObject [

	description := anObject
]

{ #category : 'accessing' }
RowanMonticelloRepositoryService >> repositoryOop [

	^ repositoryOop
]

{ #category : 'accessing' }
RowanMonticelloRepositoryService >> repositoryOop: anObject [

	repositoryOop := anObject
]

{ #category : 'accessing' }
RowanMonticelloRepositoryService >> repositoryPackages [

	^ repositoryPackages
]

{ #category : 'accessing' }
RowanMonticelloRepositoryService >> repositoryPackages: anObject [

	repositoryPackages := anObject
]

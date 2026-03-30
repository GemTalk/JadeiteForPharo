Class {
	#name : 'RowanMonticelloRepositoryGroupService',
	#superclass : 'RowanService',
	#instVars : [
		'repositories'
	],
	#category : 'Jadeite-RowanClientServicesClient',
	#package : 'Jadeite-RowanClientServicesClient'
}

{ #category : 'accessing' }
RowanMonticelloRepositoryGroupService class >> templateClassName [ 

	^#RowanMonticelloRepositoryGroupService
]

{ #category : 'accessing' }
RowanMonticelloRepositoryGroupService >> repositories [

	^ repositories
]

{ #category : 'accessing' }
RowanMonticelloRepositoryGroupService >> repositories: anObject [

	repositories := anObject
]

{ #category : 'loading' }
RowanMonticelloRepositoryGroupService >> repositoryDescriptions [

	^ self repositories collect: [ :repositoryService |
		  repositoryService description ]
]

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

{ #category : 'loading' }
RowanMonticelloRepositoryGroupService >> repositoryDescriptions [

	^ repositories collect: [ :repositoryService |
		  repositoryService description ]
]

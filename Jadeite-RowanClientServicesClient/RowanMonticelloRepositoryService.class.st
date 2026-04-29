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

{ #category : 'comparing' }
RowanMonticelloRepositoryService >> = aRepositoryService [

	aRepositoryService isService ifFalse: [ ^ false ].
	^ aRepositoryService description = self description
]

{ #category : 'converting' }
RowanMonticelloRepositoryService >> asString [

	^ self description
]

{ #category : 'accessing' }
RowanMonticelloRepositoryService >> description [

	^ description
]

{ #category : 'accessing' }
RowanMonticelloRepositoryService >> description: anObject [

	description := anObject
]

{ #category : 'comparing' }
RowanMonticelloRepositoryService >> hash [

	^ self description hash
]

{ #category : 'testing' }
RowanMonticelloRepositoryService >> isSeparator [

	^ false
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

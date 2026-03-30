Class {
	#name : 'RowanMonticelloPackageService',
	#superclass : 'RowanService',
	#instVars : [
		'name',
		'description',
		'repositoryGroups'
	],
	#category : 'Jadeite-RowanClientServicesClient',
	#package : 'Jadeite-RowanClientServicesClient'
}

{ #category : 'accessing' }
RowanMonticelloPackageService class >> templateClassName [ 

	^#RowanMonticelloPackageService
]

{ #category : 'accessing' }
RowanMonticelloPackageService >> description [

	^ description
]

{ #category : 'accessing' }
RowanMonticelloPackageService >> description: anObject [

	description := anObject
]

{ #category : 'accessing' }
RowanMonticelloPackageService >> name [

	^ name
]

{ #category : 'accessing' }
RowanMonticelloPackageService >> name: anObject [

	name := anObject
]

{ #category : 'loading' }
RowanMonticelloPackageService >> repositories [

	^ repositoryGroups repositories
]

{ #category : 'loading' }
RowanMonticelloPackageService >> repositoryDescriptions [

	^ repositoryGroups repositoryDescriptions
]

{ #category : 'accessing' }
RowanMonticelloPackageService >> repositoryGroups [

	^ repositoryGroups
]

{ #category : 'accessing' }
RowanMonticelloPackageService >> repositoryGroups: anObject [

	repositoryGroups := anObject
]

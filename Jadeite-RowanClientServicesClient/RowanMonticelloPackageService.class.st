Class {
	#name : 'RowanMonticelloPackageService',
	#superclass : 'RowanService',
	#instVars : [
		'name',
		'description',
		'repositoryGroups',
		'packageOop',
		'hasChanges',
		'changes',
		'classes',
		'extensionClasses',
		'sourceRepository'
	],
	#category : 'Jadeite-RowanClientServicesClient',
	#package : 'Jadeite-RowanClientServicesClient'
}

{ #category : 'accessing' }
RowanMonticelloPackageService class >> templateClassName [ 

	^#RowanMonticelloPackageService
]

{ #category : 'accessing' }
RowanMonticelloPackageService >> changes [

	^ changes
]

{ #category : 'accessing' }
RowanMonticelloPackageService >> changes: anObject [

	changes := anObject
]

{ #category : 'accessing' }
RowanMonticelloPackageService >> classes [

	^ classes
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
RowanMonticelloPackageService >> extensionClasses [

	^ extensionClasses
]

{ #category : 'accessing' }
RowanMonticelloPackageService >> extensionClasses: anObject [

	extensionClasses := anObject
]

{ #category : 'accessing' }
RowanMonticelloPackageService >> hasChanges [

	^ hasChanges
]

{ #category : 'accessing' }
RowanMonticelloPackageService >> hasChanges: anObject [

	hasChanges := anObject
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

{ #category : 'accessing' }
RowanMonticelloPackageService >> sourceRepository [

	^ sourceRepository
]

{ #category : 'accessing' }
RowanMonticelloPackageService >> sourceRepository: anObject [

	sourceRepository := anObject
]

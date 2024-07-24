Class {
	#name : 'RowanComponentDefinitionService',
	#superclass : 'RowanDefinitionService',
	#instVars : [
		'subcomponentDefinitions',
		'packageNames',
		'projectDefinitionService',
		'preloadDoitName',
		'postloadDoitName',
		'projectNames',
		'comment'
	],
	#category : 'Jadeite-RowanClientServicesClient',
	#package : 'Jadeite-RowanClientServicesClient'
}

{ #category : 'accessing' }
RowanComponentDefinitionService class >> templateClassName [
	^#RowanComponentDefinitionService
]

{ #category : 'public' }
RowanComponentDefinitionService >> basicPrepareForReplication [
	projectDefinitionService basicPrepareForReplication.
]

{ #category : 'accessing' }
RowanComponentDefinitionService >> comment [
	^comment
]

{ #category : 'accessing' }
RowanComponentDefinitionService >> comment: anObject [
	comment := anObject
]

{ #category : 'public' }
RowanComponentDefinitionService >> isPlatformSubcomponent [

	^false
]

{ #category : 'public' }
RowanComponentDefinitionService >> isSubcomponent [

	^false
]

{ #category : 'accessing' }
RowanComponentDefinitionService >> packageNames [
	^packageNames
]

{ #category : 'accessing' }
RowanComponentDefinitionService >> packageNames: anObject [
	packageNames := anObject
]

{ #category : 'accessing' }
RowanComponentDefinitionService >> postloadDoitName [
	^postloadDoitName
]

{ #category : 'accessing' }
RowanComponentDefinitionService >> postloadDoitName: anObject [
	postloadDoitName := anObject
]

{ #category : 'accessing' }
RowanComponentDefinitionService >> preloadDoitName [
	^preloadDoitName
]

{ #category : 'accessing' }
RowanComponentDefinitionService >> preloadDoitName: anObject [
	preloadDoitName := anObject
]

{ #category : 'printing' }
RowanComponentDefinitionService >> printOn: aStream [
	aStream nextPutAll: name
]

{ #category : 'accessing' }
RowanComponentDefinitionService >> projectDefinitionService [
	^projectDefinitionService
]

{ #category : 'accessing' }
RowanComponentDefinitionService >> projectDefinitionService: anObject [
	projectDefinitionService := anObject
]

{ #category : 'accessing' }
RowanComponentDefinitionService >> projectNames [
	^projectNames
]

{ #category : 'accessing' }
RowanComponentDefinitionService >> projectNames: anObject [
	projectNames := anObject
]

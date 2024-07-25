Class {
	#name : 'RowanQueryService',
	#superclass : 'RowanService',
	#instVars : [
		'queryResults'
	],
	#category : 'Jadeite-RowanClientServicesClient',
	#package : 'Jadeite-RowanClientServicesClient'
}

{ #category : 'rsr' }
RowanQueryService class >> templateClassName [ 

	^#RowanQueryService
]

{ #category : 'accessing' }
RowanQueryService >> answer [
	^queryResults	
]

{ #category : 'public' }
RowanQueryService >> hasResults [

	^queryResults notEmpty
]

{ #category : 'accessing' }
RowanQueryService >> queryResults [
	^queryResults 
]

{ #category : 'accessing' }
RowanQueryService >> queryResults: anObject [
	queryResults := anObject
]

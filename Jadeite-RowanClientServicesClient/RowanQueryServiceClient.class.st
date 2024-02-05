Class {
	#name : 'RowanQueryServiceClient',
	#superclass : 'RowanQueryService',
	#instVars : [
		'name',
		'inCommand'
	],
	#category : 'Jadeite-RowanClientServicesClient'
}

{ #category : 'displaying' }
RowanQueryServiceClient >> displayName [
	"for logging. for now"

	^name
]

{ #category : 'accessing' }
RowanQueryServiceClient >> inCommand [

	^ inCommand
]

{ #category : 'accessing' }
RowanQueryServiceClient >> inCommand: anObject [

	inCommand := anObject
]

{ #category : 'accessing' }
RowanQueryServiceClient >> name [
	^name
]

{ #category : 'accessing' }
RowanQueryServiceClient >> name: aString [
	name := aString asString
]

{ #category : 'accessing' }
RowanQueryServiceClient >> sortAspect [

	^name
]

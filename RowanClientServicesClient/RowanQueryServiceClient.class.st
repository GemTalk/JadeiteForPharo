Class {
	#name : 'RowanQueryServiceClient',
	#superclass : 'RowanQueryService',
	#instVars : [
		'name'
	],
	#category : 'RowanClientServicesClient'
}

{ #category : 'displaying' }
RowanQueryServiceClient >> displayName [
	"for logging. for now"

	^name
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

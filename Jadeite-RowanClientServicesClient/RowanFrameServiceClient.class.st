Class {
	#name : 'RowanFrameServiceClient',
	#superclass : 'RowanFrameService',
	#instVars : [
		'inCommand',
		'index'
	],
	#category : 'Jadeite-RowanClientServicesClient',
	#package : 'Jadeite-RowanClientServicesClient'
}

{ #category : 'accessing' }
RowanFrameServiceClient >> index [

	^ index
]

{ #category : 'accessing' }
RowanFrameServiceClient >> index: anObject [

	index := anObject
]

{ #category : 'accessing' }
RowanFrameServiceClient >> indexOfInCommandInstVar [
	"performance enhancement"

	^20
]

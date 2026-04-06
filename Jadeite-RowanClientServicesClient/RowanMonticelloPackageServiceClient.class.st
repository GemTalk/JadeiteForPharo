Class {
	#name : 'RowanMonticelloPackageServiceClient',
	#superclass : 'RowanMonticelloPackageService',
	#instVars : [
		'inCommand',
		'serviceCompletionBlock',
		'catchBlock'
	],
	#category : 'Jadeite-RowanClientServicesClient',
	#package : 'Jadeite-RowanClientServicesClient'
}

{ #category : 'accessing' }
RowanMonticelloPackageServiceClient >> catchBlock [

	^ catchBlock
]

{ #category : 'accessing' }
RowanMonticelloPackageServiceClient >> catchBlock: anObject [

	catchBlock := anObject
]

{ #category : 'accessing' }
RowanMonticelloPackageServiceClient >> inCommand [

	^ inCommand
]

{ #category : 'accessing' }
RowanMonticelloPackageServiceClient >> inCommand: anObject [

	inCommand := anObject
]

{ #category : 'accessing' }
RowanMonticelloPackageServiceClient >> serviceCompletionBlock [

	^ serviceCompletionBlock
]

{ #category : 'accessing' }
RowanMonticelloPackageServiceClient >> serviceCompletionBlock: anObject [

	serviceCompletionBlock := anObject
]

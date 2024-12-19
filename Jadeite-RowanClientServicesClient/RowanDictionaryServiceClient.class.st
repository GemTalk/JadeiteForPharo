Class {
	#name : 'RowanDictionaryServiceClient',
	#superclass : 'RowanDictionaryService',
	#instVars : [
		'inCommand'
	],
	#category : 'Jadeite-RowanClientServicesClient',
	#package : 'Jadeite-RowanClientServicesClient'
}

{ #category : 'accessing' }
RowanDictionaryServiceClient >> defaultTemplateForClassCategory: classCategory [

	^ self defaultTemplate
		  copyReplaceAll: 'category: nil'
		  with: 'category: ''' , classCategory , ''''
]

{ #category : 'accessing' }
RowanDictionaryServiceClient >> inCommand [

	^ inCommand ifNil: [ inCommand := RowanSemaphore new ]
]

{ #category : 'accessing' }
RowanDictionaryServiceClient >> inCommand: anObject [

	inCommand := anObject
]

{ #category : 'accessing' }
RowanDictionaryServiceClient >> indexOfInCommandInstVar [
	"performance enhancement"

	^18
]

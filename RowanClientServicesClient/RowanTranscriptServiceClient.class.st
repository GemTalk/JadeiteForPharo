Class {
	#name : 'RowanTranscriptServiceClient',
	#superclass : 'RowanTranscriptService',
	#instVars : [
		'transcriptPresenter'
	],
	#category : 'RowanClientServicesClient'
}

{ #category : 'as yet unclassified' }
RowanTranscriptServiceClient >> nextPutAll [
	transcriptPresenter text: transcriptPresenter text , string.
	transcriptPresenter scrollValue: 1@1.
]

{ #category : 'accessing' }
RowanTranscriptServiceClient >> transcriptPresenter: anObject [

	transcriptPresenter := anObject
]

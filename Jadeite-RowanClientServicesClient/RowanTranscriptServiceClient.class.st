Class {
	#name : 'RowanTranscriptServiceClient',
	#superclass : 'RowanTranscriptService',
	#instVars : [
		'transcriptPresenter'
	],
	#category : 'Jadeite-RowanClientServicesClient',
	#package : 'Jadeite-RowanClientServicesClient'
}

{ #category : 'as yet unclassified' }
RowanTranscriptServiceClient >> nextPutAll [
	"best to write to the presenter in the morphic thread
	but use a semaphore to ensure it completes before returning to the server"

	| sem |
	sem := Semaphore new.
	UIManager default defer: [
		transcriptPresenter text: transcriptPresenter text , string.
		transcriptPresenter scrollValue: 1 @ 1.
		sem signal ].
	sem wait
]

{ #category : 'accessing' }
RowanTranscriptServiceClient >> transcriptPresenter: anObject [

	transcriptPresenter := anObject
]

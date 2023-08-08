Class {
	#name : 'BrowserUpdateAnnouncer',
	#superclass : 'Announcer',
	#instVars : [
		'browserUpdate'
	],
	#category : 'RowanClientServicesClient'
}

{ #category : 'accessing' }
BrowserUpdateAnnouncer >> browserUpdate [

	^ browserUpdate
]

{ #category : 'accessing' }
BrowserUpdateAnnouncer >> browserUpdate: anObject [

	browserUpdate := anObject
]

{ #category : 'announcing' }
BrowserUpdateAnnouncer >> when: aSymbol send: aSelector to: anObject [

	| anAnnouncementClass |
	anAnnouncementClass := browserUpdate convertEventSymbolToClass: aSymbol.
	^ super when: anAnnouncementClass send: aSelector to: anObject
]

{ #category : 'announcing' }
BrowserUpdateAnnouncer >> when: aSymbol send: aSelector to: anObject withArguments: anArgArray [

	| anAnnouncementClass |
	anAnnouncementClass := browserUpdate convertEventSymbolToClass:
		                       aSymbol.
	^ super
		  when: anAnnouncementClass
		  send: aSelector
		  to: anObject
		  withArguments: anArgArray
]

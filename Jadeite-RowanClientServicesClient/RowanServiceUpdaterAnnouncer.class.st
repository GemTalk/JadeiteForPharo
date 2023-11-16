Class {
	#name : 'RowanServiceUpdaterAnnouncer',
	#superclass : 'Announcer',
	#instVars : [
		'serviceUpdater'
	],
	#category : 'Jadeite-RowanClientServicesClient'
}

{ #category : 'accessing' }
RowanServiceUpdaterAnnouncer >> serviceUpdater: anObject [

	serviceUpdater := anObject
]

{ #category : 'announcing' }
RowanServiceUpdaterAnnouncer >> when: aSymbol send: aSelector to: anObject [

	| anAnnouncementClass |
	anAnnouncementClass := serviceUpdater convertEventSymbolToClass: aSymbol.
	^ super when: anAnnouncementClass send: aSelector to: anObject
]

{ #category : 'announcing' }
RowanServiceUpdaterAnnouncer >> when: aSymbol send: aSelector to: anObject withArguments: anArgArray [

	| anAnnouncementClass |
	anAnnouncementClass := serviceUpdater convertEventSymbolToClass:
		                       aSymbol.
	^ super
		  when: anAnnouncementClass
		  send: aSelector
		  to: anObject
		  withArguments: anArgArray
]

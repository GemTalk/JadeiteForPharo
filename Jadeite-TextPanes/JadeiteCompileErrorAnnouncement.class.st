Class {
	#name : 'JadeiteCompileErrorAnnouncement',
	#superclass : 'Announcement',
	#instVars : [
		'compileErrorText'
	],
	#category : 'Jadeite-TextPanes',
	#package : 'Jadeite-TextPanes'
}

{ #category : 'accessing' }
JadeiteCompileErrorAnnouncement >> compileErrorText [

	^ compileErrorText
]

{ #category : 'accessing' }
JadeiteCompileErrorAnnouncement >> compileErrorText: anObject [

	compileErrorText := anObject
]

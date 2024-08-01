Class {
	#name : 'JadeiteForPharoBrowserAbstractTestCase',
	#superclass : 'JadeiteForPharoGUITestCase',
	#instVars : [
		'secondBrowser',
		'methodListBrowser',
		'secondPresenter',
		'transcriptWritesWereEnabled'
	],
	#category : 'Jadeite-Tests',
	#package : 'Jadeite-Tests'
}

{ #category : 'testing' }
JadeiteForPharoBrowserAbstractTestCase >> isAbstract [

	^self == JadeiteForPharoBrowserAbstractTestCase
]

{ #category : 'support' }
JadeiteForPharoBrowserAbstractTestCase >> setUp [
	super setUp.
	self jadeiteLog: 'setUp complete'.
	self setupProjectBrowser.
	self jadeiteLog: 'setupProjectBrowser complete'.
]

{ #category : 'support' }
JadeiteForPharoBrowserAbstractTestCase >> tearDown [
	super tearDown.
	session isValidSession
		ifTrue: [transcriptWritesWereEnabled == true ifTrue: [transcript flipTranscript]].
	methodListBrowser
		ifNotNil: 
			[self destroy: methodListBrowser.
			methodListBrowser := nil].
	secondBrowser
		ifNotNil: 
			[self destroy: secondBrowser.
			secondBrowser := nil]
]

"
These tests should not assume a connection to the server is present. Although it's perfectly ok if the test wants to create a session. 
"
Class {
	#name : 'JadeiteForPharoHeadlessTestCase',
	#superclass : 'JadeiteForPharoTestCase',
	#category : 'Jadeite-Tests',
	#package : 'Jadeite-Tests'
}

{ #category : 'accessing' }
JadeiteForPharoHeadlessTestCase class >> classForTestResource [

	^JadeiteHeadlessTestResource
]

{ #category : 'accessing' }
JadeiteForPharoHeadlessTestCase class >> jadeiteTestResourceClass [

	^JadeiteHeadlessTestResource 
]

{ #category : 'support' }
JadeiteForPharoHeadlessTestCase >> disableToolOpeningPreferences [

	JadeitePreferences current openBrowserOnClass: String new
]

{ #category : 'support' }
JadeiteForPharoHeadlessTestCase >> performTest [

	RowanServiceUpdater current critical: [ super performTest ]
]

{ #category : 'support' }
JadeiteForPharoHeadlessTestCase >> setUp [

	savedSettings := JadeitePreferences current copy.
	self closeConnectionLaunchers.
	JadeiteConnectionProfile connectionProfile disconnect.
	self disableToolOpeningPreferences.
	JadeiteConnectionProfile connectionProfile connect
]

{ #category : 'support' }
JadeiteForPharoHeadlessTestCase >> tearDown [

	JadeiteConnectionProfile connectionProfile disconnect.
	savedSettings ifNotNil: [ JadeitePreferences current: savedSettings ]
]

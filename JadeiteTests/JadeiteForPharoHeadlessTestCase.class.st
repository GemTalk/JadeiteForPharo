"
These tests should not assume a connection to the server is present. 
"
Class {
	#name : 'JadeiteForPharoHeadlessTestCase',
	#superclass : 'TestCase',
	#instVars : [
		'existingConnection',
		'connectionProfile'
	],
	#category : 'JadeiteTests'
}

{ #category : 'defaults' }
JadeiteForPharoHeadlessTestCase class >> defaultGciConnectionProfile [

	| gciConnectionProfile |
	gciConnectionProfile := JadeiteGCIConnectionProfile new.
	gciConnectionProfile
		host: 'uffda';
		stone: 'gs_370';
		user: 'SystemUser';
		password: 'swordfish';
		version: '3.7.0';
		netldi: 'ldibert9';
		path: '/home/ewinger/Pharo/clientlibs'.
	^ gciConnectionProfile
]

{ #category : 'support' }
JadeiteForPharoHeadlessTestCase >> connect [
	"The copy of the connection profile might have an existing session and connection. However, `connect` should replace existing session and connection objects so we won't disturb other tests that assume a connection."

	connectionProfile := self getConnectionProfile.
	connectionProfile connect.
	^ connectionProfile
]

{ #category : 'support' }
JadeiteForPharoHeadlessTestCase >> getConnectionProfile [

	connectionProfile := JadeiteConnectionLauncher lastConnectionProfile
		                     copy.
	connectionProfile ifNil: [
		connectionProfile := self class defaultGciConnectionProfile ].
	^ connectionProfile
]

{ #category : 'support' }
JadeiteForPharoHeadlessTestCase >> setUp [ 
	
	existingConnection := GciSession current library. 
	connectionProfile := self getConnectionProfile.
	connectionProfile isGciConnection ifFalse: [ ^ self ].
	connectionProfile connect.
]

{ #category : 'support' }
JadeiteForPharoHeadlessTestCase >> tearDown [

	GciSession current library: existingConnection.
	connectionProfile ifNotNil: [ connectionProfile disconnect ]
]

{ #category : 'tests' }
JadeiteForPharoHeadlessTestCase >> test_abort [

	| service |
	connectionProfile := self connect.
	service := RowanAnsweringService new
		           exec: 'UserGlobals at: #jadeite_test_abort put: true'
		           in: GciSession current.
	service := RowanAnsweringService new
		           command: #execReturningObject:;
		           commandArgs:
			           (Array with:
					            'UserGlobals at: #jadeite_test_abort ifAbsent: [false]').
	GciSession current issueCommand: service.
	self assert: service answer.
	(JadeiteApplication new gciSession: GciSession current)
		abortTransaction.
	service := RowanAnsweringService new
		           command: #execReturningObject:;
		           commandArgs:
			           (Array with:
					            'UserGlobals at: #jadeite_test_abort ifAbsent: [false]').
	GciSession current issueCommand: service.
	self deny: service answer.
	connectionProfile disconnect.
	connectionProfile := nil
]

{ #category : 'tests' }
JadeiteForPharoHeadlessTestCase >> test_gciConnect [
	"will need customization if Jadeite for Pharo tests are ever run in github's CI space"

	| service |
	connectionProfile disconnect. "setUp is assumed to connect"
	connectionProfile := self getConnectionProfile.
	connectionProfile isGciConnection ifFalse: [ ^ self ].
	connectionProfile connect.
	[
	self assert: connectionProfile connection isOpen.
	self assert: (GsSession sessionIsValid: connectionProfile session).
	service := RowanAnsweringService new
		           command: #execReturningObject:;
		           commandArgs: (Array with: '3 + 4').
	GciSession current issueCommand: service.
	self assert: service answer equals: 7 ] ensure: [
		connectionProfile disconnect ].
	self assert: connectionProfile connection isNil.
	self assert: connectionProfile session isNil. 
	connectionProfile := nil
]

{ #category : 'tests' }
JadeiteForPharoHeadlessTestCase >> test_serviceUpdater [

	| serviceUpdater oc testService initialSize |
	serviceUpdater := RowanServiceUpdater current.
	self assert: (serviceUpdater isKindOf: RowanServiceUpdater).
	initialSize := serviceUpdater registeredPresenters size.
	oc := OrderedCollection new.
	RowanServiceUpdater current
		register: oc
		selector: #testServiceUpdate:.
	self
		assert: serviceUpdater registeredPresenters size
		equals: initialSize + 1.
	self assert: (serviceUpdater registeredPresenters includes: oc).
	testService := RowanTestService
		               command: #isClassService
		               withArgs: Array new.
	self assert: oc isEmpty.
	GciSession current issueCommand: testService.
	self assert: oc first equals: #testServiceUpdate:.
	RowanServiceUpdater current removeEventsTriggeredFor: oc. "in theory, this eventually goes away on it's own"
	oc := nil.
	testService := nil. 
	self
		assert: serviceUpdater registeredPresenters size
		equals: initialSize
]

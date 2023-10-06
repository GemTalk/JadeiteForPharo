"
These tests should not assume a connection to the server is present. 
"
Class {
	#name : 'JadeiteForPharoHeadlessTestCase',
	#superclass : 'TestCase',
	#instVars : [
		'existingConnection'
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

	| connectionProfile |
	connectionProfile := self getConnectionProfile.
	connectionProfile connect.
	^ connectionProfile
]

{ #category : 'support' }
JadeiteForPharoHeadlessTestCase >> getConnectionProfile [

	| connectionProfile |
	connectionProfile := JadeiteConnectionLauncher lastConnectionProfile
		                     copy.
	connectionProfile ifNil: [
		connectionProfile := self class defaultGciConnectionProfile ].
	^ connectionProfile
]

{ #category : 'support' }
JadeiteForPharoHeadlessTestCase >> setUp [ 
	
	existingConnection := GciSession current library. 
]

{ #category : 'support' }
JadeiteForPharoHeadlessTestCase >> tearDown [
	
	GciSession current library: existingConnection. 
]

{ #category : 'tests' }
JadeiteForPharoHeadlessTestCase >> test_abort [

	| connectionProfile service |
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
	(JadeiteApplication new gciSession: GciSession current) abortTransaction.
	service := RowanAnsweringService new
		           command: #execReturningObject:;
		           commandArgs:
			           (Array with:
					            'UserGlobals at: #jadeite_test_abort ifAbsent: [false]').
	GciSession current issueCommand: service.
	self deny: service answer.
	connectionProfile disconnect
]

{ #category : 'tests' }
JadeiteForPharoHeadlessTestCase >> test_gciConnect [
	"will need customization if Jadeite for Pharo tests are ever run in github's CI space"

	| connectionProfile service |
	connectionProfile := self getConnectionProfile. 
	connectionProfile isGciConnection ifFalse:[^self].
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
	self assert: connectionProfile session isNil
]

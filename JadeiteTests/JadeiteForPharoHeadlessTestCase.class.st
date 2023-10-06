Class {
	#name : 'JadeiteForPharoHeadlessTestCase',
	#superclass : 'TestCase',
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

{ #category : 'tests' }
JadeiteForPharoHeadlessTestCase >> test_gciConnect [
	"will need customization if Jadeite for Pharo tests are ever run in github's CI space"

	| connectionProfile console service |
	connectionProfile := JadeiteConnectionLauncher lastConnectionProfile
		                     copy.
	connectionProfile ifNil: [
		connectionProfile := self class defaultGciConnectionProfile ].
	connectionProfile isGciConnection ifFalse: [ ^ self ].
	[
	console := connectionProfile connect. "The copy of the connection profile might have an existing session and connection. However, `connect` should replace existing session and connection objects so we won't disturb other tests that assume a connection."
	self assert: connectionProfile connection isOpen.
	self assert: (GsSession sessionIsValid: connectionProfile session).
	service := RowanAnsweringService new
		           command: #execReturningObject:;
		           commandArgs: (Array with: '3 + 4').
	BrowserUpdate current
		issueCommand: service
		session: GciSession current.
	self assert: service answer equals: 7 ] ensure: [
		connectionProfile disconnect ].
	self assert: connectionProfile connection isNil.
	self assert: connectionProfile session isNil
]

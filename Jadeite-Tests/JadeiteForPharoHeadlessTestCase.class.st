"
These tests should not assume a connection to the server is present. 
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
JadeiteForPharoHeadlessTestCase class >> testResourceClass [

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

{ #category : 'tests' }
JadeiteForPharoHeadlessTestCase >> test_abort [

	| service |
	service := RowanAnsweringService new
		           exec: 'UserGlobals at: #jadeite_test_abort put: true'
		           in: GciSession current
		           onCompletion: [  ].
	service := RowanAnsweringService new
		           command: #execReturningObject:;
		           commandArgs:
			           (Array with:
					            'UserGlobals at: #jadeite_test_abort ifAbsent: [false]').
	GciSession current issueCommand: service onCompletion: [  ].
	self assert: service answer.
	(JadeiteApplication new gciSession: GciSession current)
		abortTransaction.
	service := RowanAnsweringService new
		           command: #execReturningObject:;
		           commandArgs:
			           (Array with:
					            'UserGlobals at: #jadeite_test_abort ifAbsent: [false]').
	GciSession current issueCommand: service onCompletion: [  ].
	self deny: service answer.
]

{ #category : 'tests' }
JadeiteForPharoHeadlessTestCase >> test_basicReplicate [

	"Jadeite for Pharo doesn't yet take advantage of RSR's replication mechanism."

	| service  replicatedService |
	service := RowanClassService new name: 'TestReplication'; meta: false.
	replicatedService := RowanClassService new name: 'TestReplication'; meta: false.
	service categories: #('abc' 'def'); comment: 'this is a test'; hasSubclasses: true. 
	replicatedService basicReplicateFrom: service.
	self assert: replicatedService categories equals: #('abc' 'def').
	self assert: replicatedService comment equals: 'this is a test'. 
	self assert: replicatedService hasSubclasses. 
	
]

{ #category : 'tests' }
JadeiteForPharoHeadlessTestCase >> test_cleanUpServiceOnDisconnect [
	"ensure the hook to cleanup after disconnect gets run"

	| service |
	service := RowanClassService new
		           name: 'RowanService';
		           meta: false.
	service
		command: #update;
		commandArgs: Array new.
	GciSession current issueCommand: service onCompletion: [].
	"make sure a few random fields are filled in so we know the update succeeded"
	self assert: service comment notEmpty.
	self assert: service packageName equals: 'Rowan-Services-Core'.
	self assert: service oop isInteger.
	JadeiteConnectionProfile connectionProfile disconnect.
	1 to: RowanClassService instSize do: [ :index |
	self assert: (service instVarAt: index) isNil ]
]

{ #category : 'tests' }
JadeiteForPharoHeadlessTestCase >> test_copyToClipboard [
	"added a convenience extension method to Text to copy to the clipboard "

	| text string |
	string := 'will this get to the clipboard?'.
	text := Text fromString: string.
	text copyToClipboard.
	self assert: Clipboard clipboardText equals: string.
	string := 'its probably working'.
	text := Text fromString: string.
	text copyToClipboard.
	self assert: Clipboard clipboardText equals: string.
]

{ #category : 'tests' }
JadeiteForPharoHeadlessTestCase >> test_execution [

	| service |
	service := RowanAnsweringService new.
	service exec: '3+4' in: GciSession current onCompletion: [].
	self assert: service answer equals: '7'
]

{ #category : 'tests' }
JadeiteForPharoHeadlessTestCase >> test_executionReturningObject [
	
	| service |
	service := RowanAnsweringService new.
	service execReturningObject: '3+4' in: GciSession current.
	self assert: service answer equals: 7
]

{ #category : 'tests' }
JadeiteForPharoHeadlessTestCase >> test_gciConnect [
	"will need customization if Jadeite for Pharo tests are ever run in github's CI space"

	| service |
	JadeiteConnectionProfile connectionProfile isConnected ifTrue: [
		JadeiteConnectionProfile connectionProfile disconnect ].
	JadeiteConnectionProfile connectionProfile isGciConnection ifFalse: [
		^ self ].
	JadeiteConnectionProfile connectionProfile connect.
	[
	self assert:
		JadeiteConnectionProfile connectionProfile connection isOpen.
	self assert: (GsSession sessionIsValid:
			 JadeiteConnectionProfile connectionProfile session).
	"this test disconnects so we have to use the critical block with the new updater"
	RowanServiceUpdater current critical: [
		service := RowanAnsweringService new
			           command: #execReturningObject:;
			           commandArgs: (Array with: '3 + 4').
		GciSession current
			issueCommand: service
			onCompletion: [ self assert: service answer equals: 7 ] ] ]
		ensure: [ JadeiteConnectionProfile connectionProfile disconnect ].
	self assert:
		JadeiteConnectionProfile connectionProfile connection isNil.
	self assert: JadeiteConnectionProfile connectionProfile session isNil
]

{ #category : 'tests' }
JadeiteForPharoHeadlessTestCase >> test_noSearchMatchesFoundMessage [

	| browser message |
	browser := JadeiteBrowserPresenter new.
	message := browser noMatchesFoundMessageFor: 'siz'.
	self assert: message equals: 'No matches found for ''siz''.
Perhaps include a wildcard in search?'.
	message := browser noMatchesFoundMessageFor: 'xssrrsss*ssxxx'.
	self
		assert: message
		equals: 'No matches found for ''xssrrsss*ssxxx''.'
]

{ #category : 'tests' }
JadeiteForPharoHeadlessTestCase >> test_serviceUpdater [

	| serviceUpdater oc testService initialSize |
	serviceUpdater := RowanServiceUpdater current.
	self assert: (serviceUpdater isKindOf: RowanServiceUpdater).
	initialSize := serviceUpdater registeredPresenters size.
	oc := OrderedCollection new.
	serviceUpdater removeEventsTriggeredFor: oc.
	RowanServiceUpdater current
		register: oc
		selector: #testServiceUpdate:.
	[
	self
		assert: serviceUpdater registeredPresenters size
		equals: initialSize + 1.
	self assert: (serviceUpdater registeredPresenters includes: oc).
	testService := RowanTestService
		               command: #isClassService
		               withArgs: Array new.
	self assert: oc isEmpty.
	GciSession current issueCommand: testService onCompletion: [].
	self assert: oc first equals: #testServiceUpdate: ] ensure: [
		RowanServiceUpdater current removeEventsTriggeredFor: oc "in theory, this eventually goes away on it's own" ].
	oc := nil.
	testService := nil.
	self
		assert: serviceUpdater registeredPresenters size
		equals: initialSize
]

{ #category : 'tests' }
JadeiteForPharoHeadlessTestCase >> test_updates [
	"updates should be added to the service. Those updates are other 
	services which will update the gui. For instance, a query service 
	returns method services in the updates"

	| service |
	service := RowanAnsweringService new.
	service execReturningObject: '3+4' in: GciSession current.
	self assert: service answer equals: 7.
	self assert: service updates isEmpty.
	service := RowanQueryService
		           command: #implementorsOf:
		           withArgs: (Array with: #size).
	GciSession current issueCommand: service onCompletion: [].
	self assert: service returnedServices first identicalTo: service.
	self assert: service updates notEmpty.
	service updates do: [ :theUpdate |
		self assert: theUpdate class = RowanMethodServiceClient ]
]

{ #category : 'tests' }
JadeiteForPharoHeadlessTestCase >> test_workspaceSelectedSelectorNotInteger [

	"The pharo extractor will return an integer which seems wrong. Make sure we return a string or nil."
	| workspace | 
	workspace := JadeiteWorkspace new. 
	self assert: workspace selectedSelector isNil.
	workspace text: '123'. 
	workspace selectionInterval: (1 to: 3). 
	self assert: workspace selectedSelector = '123'. "pharo would return an integer breaking Jadeite's menu creation code."

	
]

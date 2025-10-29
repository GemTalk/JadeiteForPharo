"
Not a true headless test as a session is expected which will open a console. 
No test should open a browser or any other windows.
Just test presenter functionality and state. 
Valid session is expected to be present.
"
Class {
	#name : 'JadeiteForPharoWindowlessBrowserTestCase',
	#superclass : 'JadeiteForPharoWindowlessTestCase',
	#instVars : [
		'browser'
	],
	#category : 'Jadeite-Tests',
	#package : 'Jadeite-Tests'
}

{ #category : 'support' }
JadeiteForPharoWindowlessBrowserTestCase >> ensureLauncherOpened [

	JadeiteConnectionLauncher soleInstance ifNil: [
		JadeiteConnectionApplication new start ]
]

{ #category : 'support' }
JadeiteForPharoWindowlessBrowserTestCase >> execute: aString [

	| service |
	service := RowanAnsweringService new
		           execReturningObject: aString
		           in: GciSession current.
	^ service answer
]

{ #category : 'support' }
JadeiteForPharoWindowlessBrowserTestCase >> forceReconnect [
	"don't force a reconnect in windowless tests"

	self jadeiteTestResourceClass current connectIfNecessary.
	jadeiteShell := JadeiteConsole currentConsole
]

{ #category : 'support' }
JadeiteForPharoWindowlessBrowserTestCase >> setRemoteAutoCommit: boolean onCompletion: aBlock [
	"don't worry about this unless we need it"

	
]

{ #category : 'support' }
JadeiteForPharoWindowlessBrowserTestCase >> setUp [

	super setUp.
	browser := JadeiteBrowser new
		           application: JadeiteConsoleApplication new;
		           gciSession: GciSession current
]

{ #category : 'tests' }
JadeiteForPharoWindowlessBrowserTestCase >> test_activePresenter [

	| firstPage |
	self assert: browser tabs pages size equals: 1.
	firstPage := browser tabs selectedPage.
	firstPage presenterProvider: [ MockBrowserPresenter new ].
	self
		assert: browser activePresenter
		equals: firstPage activePresenter
]

{ #category : 'tests' }
JadeiteForPharoWindowlessBrowserTestCase >> test_addTab [

	| firstPage |
	self assert: browser tabs pages size equals: 1.
	self
		assert: browser tabs pages first
		equals: browser tabs selectedPage.
	firstPage := browser tabs selectedPage.
	browser openBrowserTab.
	self assert: browser tabs pages size equals: 2.
	self deny: browser tabs pages last equals: firstPage
]

{ #category : 'tests' }
JadeiteForPharoWindowlessBrowserTestCase >> test_autoCommitChangeNotification [

	self defer: [ browser gciSession autoCommit value: #failed ].
	self assert: browser autoCommitButton color equals: Color red.
	self
		assert: browser autoCommitButton label
		equals: 'Auto Commit - failed'.
	self defer: [ browser gciSession autoCommit value: true ].
	self assert: browser autoCommitButton color equals: Color green.
	self
		assert: browser autoCommitButton label
		equals: 'Auto Commit - true'.
	self defer: [ browser gciSession autoCommit value: false ].
	self
		assert: browser autoCommitButton color
		equals: browser autoCommitButton defaultColor.
	self
		assert: browser autoCommitButton label
		equals: 'Auto Commit - false'
]

{ #category : 'tests' }
JadeiteForPharoWindowlessBrowserTestCase >> test_browserAbort [

	self execute:
		'UserGlobals removeKey: #jadeite_test_abort ifAbsent: []'.
	self execute: 'UserGlobals at: #jadeite_test_abort put: true'.
	self assert:
		(self execute:
			 'UserGlobals at: #jadeite_test_abort ifAbsent: [false]').
	browser abortTransaction.
	self deny:
		(self execute:
			 'UserGlobals at: #jadeite_test_abort ifAbsent: [false]')
]

{ #category : 'tests' }
JadeiteForPharoWindowlessBrowserTestCase >> test_browserOpener [

	self assert: browser browserOpener equals: browser.
	self
		assert: JadeiteConsole currentConsole browserOpener
		equals: JadeiteConsole currentConsole
]

{ #category : 'tests' }
JadeiteForPharoWindowlessBrowserTestCase >> test_browserPresenterClass [

	JadeitePreferences isRowanAvailable
		ifFalse: [
				self
					assert: browser browserPresenterClass
					equals: JadeiteBrowserPresenterWithoutRowan ]
		ifTrue: [
				self
					assert: browser browserPresenterClass
					equals: JadeiteBrowserPresenter ]
]

{ #category : 'tests' }
JadeiteForPharoWindowlessBrowserTestCase >> test_classListPresenterAccessor [
	"browser should get classListPresenter from active presenter "

	| firstPage |
	firstPage := browser tabs selectedPage.
	firstPage presenterProvider: [ MockBrowserPresenter new ].
	firstPage retrievePresenter. "make sure the notebook page sets the activePresenter "
	self
		assert: browser classListPresenter
		equals: #'MockBrowserPresenter classListPresenter'
]

{ #category : 'tests' }
JadeiteForPharoWindowlessBrowserTestCase >> test_connectPresenters [
	"when page removed, other pages should have title updated"

	| firstPage mockTab |
	self assert: browser tabs pages size equals: 1.
	self
		assert: browser tabs pages first
		equals: browser tabs selectedPage.
	firstPage := browser tabs selectedPage.
	mockTab := MockPage new.
	self assert: mockTab title equals: 'title not updated'.
	browser tabs addPage: mockTab.
	browser tabs removePage: firstPage.
	self assert: mockTab title equals: 'title updated'
]

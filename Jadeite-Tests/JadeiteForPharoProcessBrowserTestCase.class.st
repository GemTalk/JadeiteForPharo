Class {
	#name : 'JadeiteForPharoProcessBrowserTestCase',
	#superclass : 'JadeiteForPharoGUITestCase',
	#instVars : [
		'processBrowser'
	],
	#category : 'Jadeite-Tests',
	#package : 'Jadeite-Tests'
}

{ #category : 'support' }
JadeiteForPharoProcessBrowserTestCase >> tearDown [

	super tearDown.
	self destroy: processBrowser
]

{ #category : 'tests' }
JadeiteForPharoProcessBrowserTestCase >> test_changePriority [

	| answeringService delayItem |
	answeringService := RowanAnsweringServiceClient new
		                    exec: '| proc | 
proc := [(Delay forSeconds: 5) wait] newProcess. 
proc name: ''test_changePriority''. 
proc resume'
		                    in: session
		                    onCompletion: [  ].

	processBrowser := self waitForProcessBrowser: [
		                  jadeiteShell openProcessBrowser ].
	delayItem := self waitForProcessNamed: 'test_changePriority'.
	self assert: delayItem priority equals: 15.
	processBrowser processListPresenter selectItem: delayItem.
	[
	processBrowser basicChangePriority: 20.
	delayItem := processBrowser processListPresenter list collection
		             detect: [ :processService |
		             processService name = 'test_changePriority' ].
	self assert: delayItem priority equals: 20 ] ensure: [
		processBrowser terminateProcess.
		(Delay forMilliseconds: 250) wait.
		self assertIsNil: (self waitForProcessNamed: 'test_changePriority') ]
]

{ #category : 'tests' }
JadeiteForPharoProcessBrowserTestCase >> test_openProcessBrowser [

	processBrowser := self waitForProcessBrowser: [
		                  jadeiteShell openProcessBrowser ].
	self assert: (processBrowser isKindOf: JadeiteProcessBrowser).
	processBrowser processListPresenter list do: [ :processService |
		self assert: (processService isKindOf: RowanProcessServiceClient) ]
]

{ #category : 'support' }
JadeiteForPharoProcessBrowserTestCase >> waitForProcessBrowser: aBlock [

	| existingProcessBrowsers newProcessBrowsers count |
	RsrGarbageCollector maximumReclamation.
	existingProcessBrowsers := JadeiteProcessBrowser allInstances.
	aBlock fork.
	count := 0.
	[
	count > 100 or: [
		(newProcessBrowsers := JadeiteProcessBrowser allInstances
			                       asOrderedCollection) size
		> existingProcessBrowsers size ] ] whileFalse: [
		count := count + 1.
		(Delay forMilliseconds: 1) wait ].
	newProcessBrowsers removeAll: existingProcessBrowsers.
	^ newProcessBrowsers first
]

{ #category : 'tests' }
JadeiteForPharoProcessBrowserTestCase >> waitForProcessNamed: processName [

	| delayItem count |
	count := 0.
	[
	(delayItem := processBrowser processListPresenter list collection
		              detect: [ :processService |
		              processService name = processName ]
		              ifNone: [  ]) isNil and: [ count <= 100 ] ]
		whileTrue: [
			(Delay forMilliseconds: 5) wait.
			count := count + 1 ].
	count > 100 ifTrue: [ ^ nil ].
	^ delayItem
]

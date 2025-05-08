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
JadeiteForPharoProcessBrowserTestCase >> test_openProcessBrowser [

	processBrowser := self waitForProcessBrowser: [
		                  jadeiteShell openProcessBrowser ].
	self assert: (processBrowser isKindOf: JadeiteProcessBrowser)
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

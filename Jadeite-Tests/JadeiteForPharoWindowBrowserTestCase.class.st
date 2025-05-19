Class {
	#name : 'JadeiteForPharoWindowBrowserTestCase',
	#superclass : 'JadeiteForPharoGUITestCase',
	#instVars : [
		'windowsBrowser'
	],
	#category : 'Jadeite-Tests',
	#package : 'Jadeite-Tests'
}

{ #category : 'support' }
JadeiteForPharoWindowBrowserTestCase >> setUp [

	super setUp.
	windowsBrowser := self waitForWindowsBrowser: [
		                  jadeiteShell openWindowsBrowser ]
]

{ #category : 'support' }
JadeiteForPharoWindowBrowserTestCase >> tearDown [

	super tearDown.
	self destroy: windowsBrowser
]

{ #category : 'tests' }
JadeiteForPharoWindowBrowserTestCase >> test_openWindowsBrowser [

	self assert: (windowsBrowser isKindOf: JadeiteWindowsBrowser)
]

{ #category : 'support' }
JadeiteForPharoWindowBrowserTestCase >> toolTested [

	^ windowsBrowser
]

{ #category : 'support' }
JadeiteForPharoWindowBrowserTestCase >> waitForWindowsBrowser: aBlock [

	| existingWindowsBrowsers newWindowsBrowsers count |
	RsrGarbageCollector maximumReclamation.
	existingWindowsBrowsers := JadeiteWindowsBrowser allInstances.
	aBlock fork.
	count := 0.
	[
	count > 100 or: [
		(newWindowsBrowsers := JadeiteWindowsBrowser allInstances
			                       asOrderedCollection) size
		> existingWindowsBrowsers size ] ] whileFalse: [
		count := count + 1.
		(Delay forMilliseconds: 1) wait ].
	newWindowsBrowsers removeAll: existingWindowsBrowsers.
	^ newWindowsBrowsers first
]

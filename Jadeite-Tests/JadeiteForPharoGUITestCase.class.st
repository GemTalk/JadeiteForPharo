"
This class contains tests for Jadeite for Pharo that (presumably) should pass. 

Other tests in the JadeiteAbstractTestCase hierarchy were ported from Jadeite for Dolphin and are not known to work in pharo yet. 
"
Class {
	#name : 'JadeiteForPharoGUITestCase',
	#superclass : 'JadeiteForPharoTestCase',
	#instVars : [
		'workspace',
		'methodListBrowser',
		'progressBarState'
	],
	#category : 'Jadeite-Tests',
	#package : 'Jadeite-Tests'
}

{ #category : 'constants' }
JadeiteForPharoGUITestCase >> compileErrorMethodText [

	^'hasCompileErrorInText
	
	| coll |
	coll := Array with: 1 with: 2. 
	coll do: [ :int |
		"missing right bracket".
	^coll'
]

{ #category : 'constants' }
JadeiteForPharoGUITestCase >> compileErrorMethodTextShowingCompileError [

	^ 'hasCompileErrorInText
	
	| coll |
	coll := Array with: 1 with: 2. 
	coll do: [ :int |
		"missing right bracket expected a right bracket (])".
	^coll'
]

{ #category : 'support' }
JadeiteForPharoGUITestCase >> dismissPopoverAndPrint [

	SpCodePopoverPrintPresenter allInstances do: [ :popup |
		popup dismissAndPrint ].
	JadeitePopoverPrintPresenter allInstances do: [ :popup |
		popup dismissAndPrint ]
]

{ #category : 'support' }
JadeiteForPharoGUITestCase >> displayAndPrint [

	workspace codePane jadeDisplay.
	self dismissPopoverAndPrint
]

{ #category : 'support' }
JadeiteForPharoGUITestCase >> ensureLauncherOpened [

	| launchers |
	launchers := JadeiteConnectionLauncher allInstances.
	launchers
		ifEmpty: [ ^ JadeiteConnectionApplication new start ]
		ifNotEmpty: [
			(launchers noneSatisfy: [ :launcher |
				 launcher window isNil or: [ launcher window isOpen ] ]) ifTrue: [
				^ JadeiteConnectionApplication new start ] ]
]

{ #category : 'support' }
JadeiteForPharoGUITestCase >> setUp [

	progressBarState := JadeitePreferences showProgressBar.
	JadeitePreferences showProgressBar: false.
	self ensureLauncherOpened.
	super setUp
]

{ #category : 'support' }
JadeiteForPharoGUITestCase >> tearDown [

	super tearDown.
	workspace ifNotNil: [
		workspace isModified: false.
		self destroy: workspace ].
	self destroy: methodListBrowser.
	JadeitePreferences showProgressBar: progressBarState
]

{ #category : 'support' }
JadeiteForPharoGUITestCase >> waitFor: aBlock errorMessage: errorString [

	| sem |
	sem := Semaphore new.
	[
	aBlock whileTrue: [ (Delay forMilliseconds: 1) wait ].
	sem signal ] fork.
	(sem waitTimeoutSeconds: 1) ifTrue: [ Error signal: errorString ]
]

{ #category : 'support' }
JadeiteForPharoGUITestCase >> waitForMethodListBrowserWhile: aBlock [
	"would really like a more determinate way of getting the correct method list"

	| existingMethodLists newMethodLists count |
	RsrGarbageCollector maximumReclamation.
	existingMethodLists := JadeiteMethodListPresenter allInstances.
	aBlock fork.
	count := 0.
	[
	count > 100 or: [
		(newMethodLists := JadeiteMethodListPresenter allInstances
			                   asOrderedCollection) size
		> existingMethodLists size ] ] whileFalse: [
		count := count + 1.
		(Delay forMilliseconds: 1) wait ].
	newMethodLists removeAll: existingMethodLists.
	methodListBrowser := newMethodLists first
]

{ #category : 'support' }
JadeiteForPharoGUITestCase >> waitForNewBrowserWhile: aBlock [

	| existingBrowsers newBrowsers count |
	RsrGarbageCollector maximumReclamation.
	existingBrowsers := JadeiteBrowser allInstances.
	aBlock fork.
	count := 0.
	[
	count > 100 or: [
		(newBrowsers := JadeiteBrowser allInstances
			                   asOrderedCollection) size
		> existingBrowsers size ] ] whileFalse: [
		count := count + 1.
		(Delay forMilliseconds: 1) wait ].
	newBrowsers removeAll: existingBrowsers.
	projectsBrowser := newBrowsers first
]

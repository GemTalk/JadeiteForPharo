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

{ #category : 'as yet unclassified' }
JadeiteForPharoGUITestCase class >> isAbstract [ 
	^ self name = #JadeiteForPharoGUITestCase 
]

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

	JadeiteConnectionLauncher soleInstance ifNil: [
		JadeiteConnectionApplication new start ]
]

{ #category : 'support' }
JadeiteForPharoGUITestCase >> setUp [

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
]

{ #category : 'tests' }
JadeiteForPharoGUITestCase >> test_openBrowser [
	"verify toolbar button works"

	| browser |
	browser := self toolTested openBrowser.
	[ self assert: (browser isKindOf: JadeiteBrowser) ] ensure: [
		self destroy: browser ]
]

{ #category : 'tests' }
JadeiteForPharoGUITestCase >> toolTested [
	"if a test specifies a tool, then use it for common tests"

	^ nil
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
JadeiteForPharoGUITestCase >> waitForCloseDialog [

	| dialogs count |
	count := 0.
	[
	(dialogs := self currentWorld windowsSatisfying: [ :each |
		            each isKindOf: QuestionWithoutCancelDialogWindow ])
		isEmpty and: [ count < 10 ] ] whileTrue: [
		count := count + 1.
		(Delay forMilliseconds: 10) wait ].
	self assert: dialogs size equals: 1.
	^ dialogs first
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
	count > 10 or: [
		(newBrowsers := JadeiteBrowser allInstances
			                   asOrderedCollection) size
		> existingBrowsers size ] ] whileFalse: [
		count := count + 1.
		(Delay forMilliseconds: 50) wait ].
	newBrowsers removeAll: existingBrowsers.
	projectsBrowser := newBrowsers first
]

{ #category : 'support' }
JadeiteForPharoGUITestCase >> waitForSaveDialog [

	| dialogs count |
	count := 0.
	[
	(dialogs := self currentWorld windowsSatisfying: [ :each |
		            (each model class canUnderstand: #presenter)
			            ifTrue: [
			            each model presenter isKindOf:
				            JadeiteServerFileSaveDialog ]
			            ifFalse: [ false ] ]) isEmpty and: [ count < 10 ] ]
		whileTrue: [
			count := count + 1.
			(Delay forMilliseconds: 10) wait ].
	self assert: dialogs size equals: 1.
	^ dialogs first model
]

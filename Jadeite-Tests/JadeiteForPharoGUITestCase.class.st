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
	self toolUsedForCommonTests ifNil: [
		^ self skip:
			  'Only subclasses that define toolTested can run this test. Classes testing tools have a tool bar that can open a browser' ].
	browser := self toolUsedForCommonTests openBrowser.
	[ self assert: (browser isKindOf: JadeiteBrowser) ] ensure: [
		self destroy: browser ]
]

{ #category : 'tests' }
JadeiteForPharoGUITestCase >> toolUsedForCommonTests [
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

	methodListBrowser := self
		                     waitForNew: JadeiteMethodListPresenter
		                     while: aBlock
]

{ #category : 'support' }
JadeiteForPharoGUITestCase >> waitForNew: presenterClass while: aBlock [

	| existing new count |
	RsrGarbageCollector maximumReclamation.
	existing := presenterClass allInstances.
	aBlock fork.
	count := 0.
	[
	count > 10 or: [
		(new := presenterClass allInstances asOrderedCollection) size
		> existing size ] ] whileFalse: [
		count := count + 1.
		(Delay forMilliseconds: 50) wait ].
	new removeAll: existing.
	new isEmpty ifTrue: [ ^ nil ].
	^ new first
]

{ #category : 'support' }
JadeiteForPharoGUITestCase >> waitForNewBrowserWhile: aBlock [

	projectsBrowser := self waitForNew: JadeiteBrowser while: aBlock
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

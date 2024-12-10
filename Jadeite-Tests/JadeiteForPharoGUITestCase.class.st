"
This class contains tests for Jadeite for Pharo that (presumably) should pass. 

Other tests in the JadeiteAbstractTestCase hierarchy were ported from Jadeite for Dolphin and are not known to work in pharo yet. 
"
Class {
	#name : 'JadeiteForPharoGUITestCase',
	#superclass : 'JadeiteForPharoTestCase',
	#instVars : [
		'workspace',
		'methodListBrowser'
	],
	#category : 'Jadeite-Tests',
	#package : 'Jadeite-Tests'
}

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
		ifEmpty: [ JadeiteConnectionApplication new start ]
		ifNotEmpty: [
			(launchers noneSatisfy: [ :launcher | launcher window isOpen ])
				ifTrue: [ JadeiteConnectionApplication new start ] ]
]

{ #category : 'support' }
JadeiteForPharoGUITestCase >> setUp [
	"JadeitePreferences isRowanLoaded: true. "
	self ensureLauncherOpened.
	super setUp
]

{ #category : 'support' }
JadeiteForPharoGUITestCase >> tearDown [

	super tearDown.
	workspace ifNotNil: [
		workspace isModified: false.
		self destroy: workspace ].
	self destroy: methodListBrowser
]

{ #category : 'support' }
JadeiteForPharoGUITestCase >> waitForMethodListBrowserWhile: aBlock [
	"would really like a more determinate way of getting the write method list"

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

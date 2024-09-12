Class {
	#name : 'JadeiteForPharoMethodListTestCase',
	#superclass : 'JadeiteForPharoGUITestCase',
	#instVars : [
		'methodListBrowser'
	],
	#category : 'Jadeite-Tests',
	#package : 'Jadeite-Tests'
}

{ #category : 'support' }
JadeiteForPharoMethodListTestCase >> tearDown [

	super tearDown.
	self destroy: methodListBrowser
]

{ #category : 'tests' }
JadeiteForPharoMethodListTestCase >> test_browseImplementors [

	self waitForMethodListBrowserWhile: [
		jadeiteShell browseImplementorsOf: #size ].
	methodListBrowser methodListPresenter items do: [ :methodService |
		methodListBrowser methodListPresenter selectItem: methodService.
		self assert: methodService selector equals: #size ].
	self assert: ('* Implementors of ''size'' for *' match:
			 methodListBrowser owner title)
]

{ #category : 'tests' }
JadeiteForPharoMethodListTestCase >> test_browseSendersFoo [

	self
		testsIssue: #issue500
		withTitle:
		'(Oscar-3.0.74) highlighting of multi-keyword selectors in senders/implementors browser is broken'.
	self waitForMethodListBrowserWhile: [
		jadeiteShell browseSendersOf: #foo ].
	methodListBrowser methodListPresenter items do: [ :methodService |
		methodListBrowser methodListPresenter selectItem: methodService.
		self assert: ('foo*' match:
				 methodListBrowser methodSourcePresenter documentPresenter
					 selection) "use match because we might pickup a '.'" ].
	self assert: ('* Senders of ''foo'' for *' match: methodListBrowser owner title)
]

{ #category : 'support' }
JadeiteForPharoMethodListTestCase >> waitForMethodListBrowserWhile: aBlock [
	"would really like a more determinate way of getting the write method list"

	RsrGarbageCollector maximumReclamation.
	self assert: JadeiteMethodListPresenter allInstances isEmpty.
	aBlock fork.
	[ JadeiteMethodListPresenter allInstances isEmpty ] whileTrue: [
		(Delay forMilliseconds: 1) wait ].
	methodListBrowser := JadeiteMethodListPresenter allInstances first
]

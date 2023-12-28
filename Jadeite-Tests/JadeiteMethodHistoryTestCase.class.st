Class {
	#name : 'JadeiteMethodHistoryTestCase',
	#superclass : 'JadeiteAbstractTestCase',
	#instVars : [
		'methodHistoryBrowser'
	],
	#category : 'Jadeite-Tests'
}

{ #category : 'as yet unclassified' }
JadeiteMethodHistoryTestCase >> removeMethodHistoryFor: methodService [
	"assume method service is selected"

	| answeringService |
	answeringService := RowanAnsweringService new
		                    command: #removeMethodHistoryFor:;
		                    commandArgs:
			                    (Array with:
					                     self methodListPresenter selections first);
		                    yourself.
	JadePresenter
		issueCommands: (Array with: answeringService)
		session: session
		onCompletion: nil.
	self projectsPresenter removeMethods:
		(Array with: self projectsPresenter selectedClass)
]

{ #category : 'as yet unclassified' }
JadeiteMethodHistoryTestCase >> tearDown [
	super tearDown.
	methodHistoryBrowser ifNotNil: [methodHistoryBrowser view close]
]

{ #category : 'as yet unclassified' }
JadeiteMethodHistoryTestCase >> test_dontAddToHistoryIfIdenticalSource [
	"we were incrementing the history gui when a method 
	was selected. That made it look like the history was bigger
	than it really was"

	self setupProjectBrowser.
	self selectRowanSample1Class.
	self
		saveMethod: 'test_openMethodHistory  ^1'
		in: 'RowanSample1'
		category: 'other'.
	
	[self selectMethodNamed: #test_openMethodHistory.
	methodHistoryBrowser := self projectsPresenter browseMethodHistory.
	self assert: methodHistoryBrowser source equals: 'test_openMethodHistory  ^1'.
	self assert: methodHistoryBrowser slider value equals: 2.
	self assert: methodHistoryBrowser slider view isEnabled.
	self assert: methodHistoryBrowser history size equals: 2.
	10 timesRepeat: 
			[self selectRowanSample1Class.	"will deselect method"
			self selectMethodNamed: #test_openMethodHistory.
			self assert: methodHistoryBrowser history size equals: 2]]
			ensure: [self removeMethodHistoryFor: self methodListPresenter selections first]
]

{ #category : 'as yet unclassified' }
JadeiteMethodHistoryTestCase >> test_openMethodHistory [
	self setupProjectBrowser.
	self selectRowanSample1Class.
	self
		saveMethod: 'test_openMethodHistory  ^1'
		in: 'RowanSample1'
		category: 'other'.
	
	[self selectMethodNamed: #test_openMethodHistory.
	methodHistoryBrowser := self projectsPresenter browseMethodHistory.
	self assert: methodHistoryBrowser source equals: 'test_openMethodHistory  ^1'.
	self assert: methodHistoryBrowser slider value equals: 2.
	self assert: methodHistoryBrowser slider view isEnabled]
			ensure: [self removeMethodHistoryFor: self methodListPresenter selections first]
]

{ #category : 'as yet unclassified' }
JadeiteMethodHistoryTestCase >> test_openMethodHistoryWithHistory [
	| newSource |
	self setupProjectBrowser.
	self selectRowanSample1Class.
	self selectMethodNamed: #foo.
	newSource := 'foo



^1'.
	self
		saveMethod: newSource
		in: 'RowanSample1'
		category: 'other'.
	methodHistoryBrowser := self projectsPresenter browseMethodHistory.
	self assert: methodHistoryBrowser source equals: newSource.
	self assert: methodHistoryBrowser slider value equals: methodHistoryBrowser history size.
	self assert: methodHistoryBrowser slider view isEnabled.
	methodHistoryBrowser moveTo: 1.
	self assert: methodHistoryBrowser source equals: 'foo ^''foo'''
]

{ #category : 'as yet unclassified' }
JadeiteMethodHistoryTestCase >> test_sliderClick [
	self setupProjectBrowser.
	self selectRowanSample1Class.
	self
		saveMethod: 'test_sliderClick  ^1'
		in: 'RowanSample1'
		category: 'other'.
	self
		saveMethod: 'test_sliderClick  ^2'
		in: 'RowanSample1'
		category: 'other'.
	
	[self selectMethodNamed: #test_sliderClick.
	methodHistoryBrowser := self projectsPresenter browseMethodHistory.
	self assert: methodHistoryBrowser source equals: 'test_sliderClick  ^2'.
	self assert: methodHistoryBrowser slider view isEnabled.
	"pretend the user has clicked on the slider directly"
	methodHistoryBrowser slider view selectionRange: (1 to: 1).	"for visual coorination with model"
	methodHistoryBrowser slider view displayValue: 1.
	methodHistoryBrowser slider model value: 1.	"trigger a #valueChanged event"
	self assert: methodHistoryBrowser source equals: 'test_sliderClick  ^1']
			ensure: [self removeMethodHistoryFor: self methodListPresenter selections first]
]

{ #category : 'as yet unclassified' }
JadeiteMethodHistoryTestCase >> test_updateAfterMethodCompile [
	self setupProjectBrowser.
	self selectRowanSample1Class.
	self
		saveMethod: 'test_sliderClick  ^1'
		in: 'RowanSample1'
		category: 'other'.
	self
		saveMethod: 'test_sliderClick  ^2'
		in: 'RowanSample1'
		category: 'other'.
	
	[self selectMethodNamed: #test_sliderClick.
	methodHistoryBrowser := self projectsPresenter browseMethodHistory.
	methodHistoryBrowser moveTo: 1.
	self assert: methodHistoryBrowser source equals: 'test_sliderClick  ^1'.
	self assert: methodHistoryBrowser history size equals: 3.
	self
		saveMethod: 'test_sliderClick  ^3'
		in: 'RowanSample1'
		category: 'other'.
	self assert: methodHistoryBrowser history size equals: 4.
	self assert: methodHistoryBrowser selection equals: 1	"stay on selection but update the view with the new method"]
			ensure: [self removeMethodHistoryFor: self methodListPresenter selections first]
]

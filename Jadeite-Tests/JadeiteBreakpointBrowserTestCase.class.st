Class {
	#name : 'JadeiteBreakpointBrowserTestCase',
	#superclass : 'JadeiteAbstractTestCase',
	#instVars : [
		'breakpointBrowser'
	],
	#category : 'Jadeite-Tests',
	#package : 'Jadeite-Tests'
}

{ #category : 'as yet unclassified' }
JadeiteBreakpointBrowserTestCase >> openBreakpointBrowser [
	^breakpointBrowser := transcript browseBreakpoints
]

{ #category : 'as yet unclassified' }
JadeiteBreakpointBrowserTestCase >> primaryTestWindow [
	"Every test should have a primary window it is testing. 
	If not, just return nil"

	^breakpointBrowser
]

{ #category : 'as yet unclassified' }
JadeiteBreakpointBrowserTestCase >> setUp [
	super setUp.
	JadePresenter clearAllBreakpointsIn: session.
	self enableBreakpoints
]

{ #category : 'as yet unclassified' }
JadeiteBreakpointBrowserTestCase >> tearDown [
	super tearDown.
	breakpointBrowser ifNotNil: [breakpointBrowser view close].
	projectsBrowser ifNotNil: [self destroy: projectsBrowser]
]

{ #category : 'as yet unclassified' }
JadeiteBreakpointBrowserTestCase >> test_addedBreakpointAddsMethod [
	| treeModel |
	self openProjectBrowser.
	
	self selectRowanSample1Test.
	self selectMethodNamed: #test2.
	self projectsPresenter setBreakPointAt: 1 in: self projectsPresenter.
	self openBreakpointBrowser.
	treeModel := breakpointBrowser breakpointListPresenter model.
	self assert: treeModel roots asArray equals: #('RowanSample1Test').
	self assert: treeModel rootNodes first children first object selector equals: #test2.
	breakpointBrowser breakpointListPresenter selections: #('RowanSample1Test').
	self assert: breakpointBrowser methodSourcePresenter value isEmpty.
	self assert: treeModel rootNodes first children size equals: 1.
	self assert: treeModel rootNodes first children first object breakpointDisplayString
		equals: 'test2 (1)'.
	self selectMethodNamed: #test1.
	self projectsPresenter setBreakPointAt: 1 in: self projectsPresenter.
	self assert: treeModel rootNodes first children size equals: 2.
	self assert: treeModel rootNodes first children first object breakpointDisplayString
		equals: 'test1 (1)'.
	self assert: treeModel rootNodes first children last object breakpointDisplayString
		equals: 'test2 (1)'
]

{ #category : 'as yet unclassified' }
JadeiteBreakpointBrowserTestCase >> test_additionalAccelerators [
	"No way yet to adequately test accelerators function
	but we can assert that we tell Dolphin to set them up"

	self testsIssue: #issue329 withTitle: 'Need accelerator key tests'.
	self openBreakpointBrowser.
	self assert: breakpointBrowser additionalAccelerators size equals: 1	"should fail if we add a new one"
]

{ #category : 'as yet unclassified' }
JadeiteBreakpointBrowserTestCase >> test_breakpointAdditionsUpdateAutomatically [
	| treeModel indicators |
	self openProjectBrowser.
	self selectRowanSample1Test.
	self selectMethodNamed: #test2.
	self projectsPresenter setBreakPointAt: 2 in: self projectsPresenter.
	self openBreakpointBrowser.
	treeModel := breakpointBrowser breakpointListPresenter model.
	self assert: treeModel roots asArray equals: #('RowanSample1Test').
	self assert: treeModel rootNodes first children first object selector equals: #test2.
	breakpointBrowser breakpointListPresenter selections: #('RowanSample1Test').
	self assert: breakpointBrowser methodSourcePresenter value isEmpty.
	breakpointBrowser breakpointListPresenter
		selections: (Array with: treeModel rootNodes first children first object).
	self assert: treeModel rootNodes first children first object breakpointDisplayString
		equals: 'test2 (1)'.
	self assert: ('test2*self assert: RowanSample1 bar = ''bar'''
				match: breakpointBrowser methodSourcePresenter value).
	indicators := breakpointBrowser methodSourcePresenter documentPresenter view indicators.
	self assert: indicators size equals: 5.
	self assert: (indicators at: 1) styleName equals: #stepPoint.
	self assert: (indicators at: 1) range equals: (1 to: 5).
	self assert: (indicators at: 2) styleName equals: #breakPoint.
	self assert: (indicators at: 2) range equals: (35 to: 37).
	self projectsPresenter setBreakPointAt: 1 in: self projectsPresenter.	"set another breakpoint"
	indicators := breakpointBrowser methodSourcePresenter documentPresenter view indicators.
	self assert: indicators size equals: 5.
	self assert: (indicators at: 1) styleName equals: #breakPoint.
	self assert: (indicators at: 1) range equals: (1 to: 5).
	self assert: (indicators at: 2) styleName equals: #breakPoint.
	self assert: (indicators at: 2) range equals: (35 to: 37).
	self assert: treeModel rootNodes first children first object breakpointDisplayString
		equals: 'test2 (2)'
]

{ #category : 'as yet unclassified' }
JadeiteBreakpointBrowserTestCase >> test_breakpointIsSelectedAndVisible [
	| firstBreakpoint |
	self testsIssue: #issue514
		withTitle: '(3.0.77) should breakpoint browser come up with the first breakpoint in method highlighted?'.
	self openProjectBrowser.
	self selectRowanSample1Test.
	self selectMethodNamed: #test2.
	self projectsPresenter setBreakPointAt: 1 in: self projectsPresenter.
	self openBreakpointBrowser.
	self assert: breakpointBrowser selectedMethodServices size equals: 1.
	self assert: breakpointBrowser selectedMethodServices first selector equals: #test2.
	firstBreakpoint := breakpointBrowser methodSourcePresenter documentPresenter view indicators
				detect: [:indicator | indicator styleName == #breakPoint or: [indicator styleName == #disabledBreakPoint]].
	self assert: firstBreakpoint range
		equals: breakpointBrowser methodSourcePresenter documentPresenter view selectionRange
]

{ #category : 'as yet unclassified' }
JadeiteBreakpointBrowserTestCase >> test_breakpointRemovalsUpdateAutomatically [
	| treeModel indicators |
	self openProjectBrowser.
	self selectRowanSample1Test.
	self selectMethodNamed: #test2.
	self projectsPresenter setBreakPointAt: 1 in: self projectsPresenter.
	self projectsPresenter setBreakPointAt: 2 in: self projectsPresenter.
	self openBreakpointBrowser.
	treeModel := breakpointBrowser breakpointListPresenter model.
	self assert: treeModel roots asArray equals: #('RowanSample1Test').
	self assert: treeModel rootNodes first children first object selector equals: #test2.
	breakpointBrowser breakpointListPresenter selections: #('RowanSample1Test').
	self assert: breakpointBrowser methodSourcePresenter value isEmpty.
	breakpointBrowser breakpointListPresenter
		selections: (Array with: treeModel rootNodes first children first object).
	self assert: treeModel rootNodes first children first object breakpointDisplayString
		equals: 'test2 (2)'.
	self assert: ('test2*self assert: RowanSample1 bar = ''bar''' match: breakpointBrowser methodSourcePresenter value). 
	indicators := breakpointBrowser methodSourcePresenter documentPresenter view indicators.
	self assert: indicators size equals: 5.
	self assert: (indicators at: 1) styleName equals: #breakPoint.
	self assert: (indicators at: 1) range equals: (1 to: 5).
	self assert: (indicators at: 2) styleName equals: #breakPoint.
	self assert: (indicators at: 2) range equals: (35 to: 37).
	self assert: treeModel rootNodes first children first object breakpointDisplayString
		equals: 'test2 (2)'.
	self projectsPresenter clearBreakPointAt: 1 in: self projectsPresenter.
	indicators := breakpointBrowser methodSourcePresenter documentPresenter view indicators.
	self assert: indicators size equals: 5.
	self assert: (indicators at: 1) styleName equals: #stepPoint.
	self assert: (indicators at: 1) range equals: (1 to: 5).
	self assert: (indicators at: 2) styleName equals: #breakPoint.
	self assert: (indicators at: 2) range equals: (35 to: 37).
	self assert: treeModel rootNodes first children first object breakpointDisplayString
		equals: 'test2 (1)'
]

{ #category : 'as yet unclassified' }
JadeiteBreakpointBrowserTestCase >> test_browseSelectedMethod [
	| menuItem commandQuery methodListBrowser |
	self testsIssue: #issue822
		withTitle: 'would be nice to be able to choose to browse a method, when full project browser is overkill'.
	self openProjectBrowser.
	self selectRowanSample1Test.
	self selectMethodNamed: #test1.
	self projectsPresenter setBreakPointAt: 1 in: self projectsPresenter.
	breakpointBrowser := self projectsPresenter browseBreakpoints.
	self assert: breakpointBrowser selectedMethodServices size equals: 1.
	self assert: breakpointBrowser selectedMethodServices first selector equals: #test1.
	self selectMethodNamed: #test1.
	menuItem := breakpointBrowser methodListPresenter view contextMenu items
				detect: [:item | item command = #browseSelectedMethod].
	commandQuery := CommandQuery commandDescription: menuItem
				source: breakpointBrowser methodListPresenter view.
	breakpointBrowser queryCommand: commandQuery.
	self assert: commandQuery isEnabled.
	methodListBrowser := breakpointBrowser browseSelectedMethod.
	
	[self assert: (methodListBrowser isKindOf: JadeiteMethodListBrowser).
	self assert: methodListBrowser primaryPresenter methodListPresenter selection selector
		equals: #test1]
			ensure: [self destroy: methodListBrowser].
	self assert: breakpointBrowser methodListPresenter model asArray first equals: #RowanSample1Test.
	breakpointBrowser methodListPresenter selection: #RowanSample1Test.
	breakpointBrowser queryCommand: commandQuery.
	self deny: commandQuery isEnabled
]

{ #category : 'as yet unclassified' }
JadeiteBreakpointBrowserTestCase >> test_clearMethodPaneWhenBreakpointRemoved [
	| originalSource |
	self testsIssue: #issue763
		withTitle: 'Breakpoint browser text pane not refreshed on method disappear (3.1pr3)'.
	self openProjectBrowser.
	self selectRowanSample1Test.
	self selectMethodNamed: #test1.
	originalSource := projectsBrowser currentCard methodSourcePresenter value.
	self projectsPresenter setBreakPointAt: 1 in: self projectsPresenter.
	breakpointBrowser := self projectsPresenter browseBreakpoints.
	self assert: breakpointBrowser selectedMethodServices size equals: 1.
	self assert: breakpointBrowser selectedMethodServices first selector equals: #test1.
	self assert: breakpointBrowser methodSourcePresenter value equals: originalSource.
	self projectsPresenter clearBreakPointAt: 1 in: self projectsPresenter.
	self assert: breakpointBrowser methodSourcePresenter value equals: String new
]

{ #category : 'as yet unclassified' }
JadeiteBreakpointBrowserTestCase >> test_clearMethodPaneWhenBreakpointRemoved2 [
	"clear from the breakpoint browser which has slightly different behavior"

	| originalSource |
	self testsIssue: #issue763
		withTitle: 'Breakpoint browser text pane not refreshed on method disappear (3.1pr3)'.
	self openProjectBrowser.
	self selectRowanSample1Test.
	self selectMethodNamed: #test1.
	originalSource := projectsBrowser currentCard methodSourcePresenter value.
	self projectsPresenter setBreakPointAt: 1 in: self projectsPresenter.
	breakpointBrowser := self projectsPresenter browseBreakpoints.
	self assert: breakpointBrowser selectedMethodServices size equals: 1.
	self assert: breakpointBrowser selectedMethodServices first selector equals: #test1.
	self assert: breakpointBrowser methodSourcePresenter value equals: originalSource.
	breakpointBrowser methodSourcePresenter clearBreakPointAt: 1 in: self projectsPresenter.
	self assert: breakpointBrowser methodSourcePresenter value equals: String new
]

{ #category : 'as yet unclassified' }
JadeiteBreakpointBrowserTestCase >> test_globalAdditionalAccelerators [
	self openBreakpointBrowser.
	self primaryTestWindow ifNil: [^self].	"not all test classes have a primaryTestWindow"
	self assert: (self primaryTestWindow additionalAccelerators includes: #(#raiseConsole 'Ctrl+F7'))
]

{ #category : 'as yet unclassified' }
JadeiteBreakpointBrowserTestCase >> test_openBreakpointBrowser [
	self openBreakpointBrowser.
	self assert: breakpointBrowser isKindOf: JadeiteBreakpointBrowser. 

]

{ #category : 'as yet unclassified' }
JadeiteBreakpointBrowserTestCase >> test_openBreakpointBrowserDisabledSourcePane [
	self openBreakpointBrowser.
	self assert: breakpointBrowser methodSourcePresenter value equals: String new.
	self assert: breakpointBrowser methodSourcePresenter documentPresenter view isReadOnly
]

{ #category : 'as yet unclassified' }
JadeiteBreakpointBrowserTestCase >> test_revert [
	"revert should revert back to the method source
	not related to issue per say but this comment within it
	https://github.com/GemTalk/Jadeite/issues/584#issuecomment-610531382"

	| originalSource |
	self testsIssue: #issue584 withTitle: 'Would like changed method indicator on tab'.
	self openProjectBrowser.
	self selectRowanSample1Test.
	self selectMethodNamed: #test1.
	originalSource := projectsBrowser currentCard methodSourcePresenter value.
	self projectsPresenter setBreakPointAt: 1 in: self projectsPresenter.
	breakpointBrowser := self projectsPresenter browseBreakpoints.
	self assert: breakpointBrowser selectedMethodServices size equals: 1.
	self assert: breakpointBrowser selectedMethodServices first selector equals: #test1.
	self assert: breakpointBrowser methodSourcePresenter value equals: originalSource.
	breakpointBrowser methodSourcePresenter value: originalSource , 'blahblahblah'.
	self assert: breakpointBrowser methodSourcePresenter value equals: originalSource , 'blahblahblah'.
	breakpointBrowser methodSourcePresenter editRevert.
	self assert: breakpointBrowser methodSourcePresenter value equals: originalSource
]

{ #category : 'as yet unclassified' }
JadeiteBreakpointBrowserTestCase >> test_selectedMethodIsFirstSelected [
	"when bp browser is opened from the project browser, try to 
	select the selected method in the bp browser using the selectin
	in the project browser"

	| firstBreakpoint |
	self testsIssue: #issue514
		withTitle: '(3.0.77) should breakpoint browser come up with the first breakpoint in method highlighted?'.
	self openProjectBrowser.
	self selectRowanSample1Test.
	self selectMethodNamed: #test1.
	self projectsPresenter setBreakPointAt: 1 in: self projectsPresenter.
	self selectMethodNamed: #test2.
	self projectsPresenter setBreakPointAt: 1 in: self projectsPresenter.
	self assert: self projectsPresenter methodListPresenter selection selector equals: #test2.	"not the first in the bp list"
	breakpointBrowser := self projectsPresenter browseBreakpoints.
	self assert: breakpointBrowser selectedMethodServices size equals: 1.
	self assert: breakpointBrowser selectedMethodServices first selector equals: #test2.
	firstBreakpoint := breakpointBrowser methodSourcePresenter documentPresenter view indicators
				detect: [:indicator | indicator styleName == #breakPoint or: [indicator styleName == #disabledBreakPoint]].
	self assert: firstBreakpoint range
		equals: breakpointBrowser methodSourcePresenter documentPresenter view selectionRange
]

{ #category : 'as yet unclassified' }
JadeiteBreakpointBrowserTestCase >> test_showsBreakpoints [
	| treeModel indicators |
	self openProjectBrowser.
	self selectRowanSample1Test.
	self selectMethodNamed: #test2.
	self projectsPresenter setBreakPointAt: 2 in: self projectsPresenter.
	self openBreakpointBrowser.
	treeModel := breakpointBrowser breakpointListPresenter model.
	self assert: treeModel roots asArray equals: #('RowanSample1Test').
	self assert: treeModel rootNodes first children first object selector equals: #test2.
	breakpointBrowser breakpointListPresenter selections: #('RowanSample1Test').
	self assert: breakpointBrowser methodSourcePresenter value isEmpty.
	breakpointBrowser breakpointListPresenter
		selections: (Array with: treeModel rootNodes first children first object).
	self assert: treeModel rootNodes first children first object breakpointDisplayString
		equals: 'test2 (1)'.
	self assert: ('test2*self assert: RowanSample1 bar = ''bar''' match: breakpointBrowser methodSourcePresenter value).
	indicators := breakpointBrowser methodSourcePresenter documentPresenter view indicators.
	self assert: indicators size equals: 5.
	self assert: (indicators at: 1) styleName equals: #stepPoint.
	self assert: (indicators at: 1) range equals: (1 to: 5).
	self assert: (indicators at: 2) styleName equals: #breakPoint.
	self assert: (indicators at: 2) range equals: (35 to: 37).
	self assert: (indicators at: 3) styleName equals: #stepPoint.
	self assert: (indicators at: 3) range equals: (39 to: 40).
	self assert: (indicators at: 4) styleName equals: #stepPoint.
	self assert: (indicators at: 4) range equals: (14 to: 20).
	self assert: (indicators at: 5) styleName equals: #stepPoint.
	self assert: (indicators at: 5) range equals: (45 to: 46)
]

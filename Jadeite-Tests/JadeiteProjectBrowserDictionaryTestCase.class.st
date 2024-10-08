Class {
	#name : 'JadeiteProjectBrowserDictionaryTestCase',
	#superclass : 'JadeiteProjectBrowserDictionaryDataCuratorTestCase',
	#category : 'Jadeite-Tests',
	#package : 'Jadeite-Tests'
}

{ #category : 'as yet unclassified' }
JadeiteProjectBrowserDictionaryTestCase >> setUp [
	user := 'SystemUser'.
	super setUp
]

{ #category : 'as yet unclassified' }
JadeiteProjectBrowserDictionaryTestCase >> test_compileMethodInNonPackagedClass [

	self testsIssue: #issue217 withTitle: 'Eliminate Dictionary Browser'.
	self
		testsRowanIssue: #issue499
		withTitle:
		'RwPrjBrowserTool>>addOrUpdateMethod:inProtocol:forClassNamed:isMeta: returns nil'. "Rowan issue"
	self selectNoneProject.
	self selectServiceNamed: 'Globals' in: self dictionaryPresenter.
	self selectServiceNamed: 'Array' in: self classListPresenter.
	self methodSourcePresenter value: 'foo ^''foo'''.
	self projectsPresenter
		editSaveMethod: self classListPresenter selection
		onCompletion: nil.

	[
	self assert: self methodListPresenter selection selector equals: #foo.
	self assert: self methodSourcePresenter value equals: 'foo ^''foo'''.
	self assert: (session executeString: 'Array includesSelector: #foo') ]
		ensure: [
			self abortTransaction.
			self cloneRowanSample1.
			self ensureRowanSampleProjectsLoaded ]
]

{ #category : 'as yet unclassified' }
JadeiteProjectBrowserDictionaryTestCase >> test_dictionaryViewClassHierarchy [
	| classNames |
	self testsIssue: #issue217 withTitle: 'Eliminate Dictionary Browser'.
	self selectNoneProject.
	self selectServiceNamed: 'RowanKernel' in: self dictionaryPresenter.
	classNames := self classListPresenter list collect: [:classService | classService name].
	self selectHierarchyTab.
	
	[self assert: (self classHierarchyPresenter model isKindOf: JadeiteTreeModel).
	classNames do: 
			[:className |
			self denyIsNil: (self classHierarchyPresenter model asBag
						detect: [:classService | classService name = className]
						ifNone: [])]]
			ensure: [self selectClassListTab]
]

{ #category : 'as yet unclassified' }
JadeiteProjectBrowserDictionaryTestCase >> test_dictionaryViewClassHierarchySelectedClass [
	| firstChild root children |
	self testsIssue: #issue217 withTitle: 'Eliminate Dictionary Browser'.
	self selectNoneProject.
	self selectServiceNamed: 'RowanKernel' in: self dictionaryPresenter.
	self selectServiceNamed: 'GsChoiceInteraction' in: self classListPresenter.
	self selectHierarchyTab.
	
	[self assert: self classHierarchyPresenter model size equals: 3.
	#('Object' 'GsInteraction' 'GsChoiceInteraction') do: 
			[:className |
			self denyIsNil: (self classHierarchyPresenter model asBag
						detect: [:classService | classService name = className]
						ifNone: [])].
	self assert: self classHierarchyPresenter model roots size equals: 1.
	self assert: self classHierarchyPresenter model roots first name equals: 'Object'.
	root := self classHierarchyPresenter model roots first.
	self assert: (children := self classHierarchyPresenter model getChildrenOf: root) size equals: 1.
	firstChild := children first.
	self assert: firstChild name equals: 'GsInteraction'.
	self assert: (children := self classHierarchyPresenter model getChildrenOf: firstChild) size
		equals: 1.
	self assert: children size equals: 1.
	self assert: children first name equals: 'GsChoiceInteraction']
			ensure: [self selectClassListTab]
]

{ #category : 'as yet unclassified' }
JadeiteProjectBrowserDictionaryTestCase >> test_gotoPackageMenuItem [
	| commandQuery gotoItem |
	self testsIssue: #issue217 withTitle: 'Eliminate Dictionary Browser'.
	self testsIssue: #issue491 withTitle: '(Oscar 3.0.73) need a way to find class in the dictionary '.
	self selectNoneProject.
	self selectServiceNamed: 'UserGlobals' in: self dictionaryPresenter. 
	self selectServiceNamed: 'JadeServer' in: self classListPresenter.
	commandQuery := self
				queryCommand: #gotoClassDefinedPackage
				inPresenter: self projectsPresenter
				view: self classListPresenter view.
	self assert: commandQuery isEnabled.
	self projectsPresenter updateClassMenu: self classListPresenter view queryContextMenu. "done by menu building infrastructure"
	gotoItem := self classListPresenter view queryContextMenu items
				detect: [:menuItem | menuItem command == #gotoClassDefinedPackage].
	self assert: gotoItem description equals: 'Go To Defining Package (Rowan-JadeServer)'.
	gotoItem commandDescription performAgainst: self projectsPresenter.
	commandQuery := self
				queryCommand: #gotoClassDefinedPackage
				inPresenter: self projectsPresenter
				view: self classListPresenter view.
	self deny: commandQuery isEnabled
]

{ #category : 'as yet unclassified' }
JadeiteProjectBrowserDictionaryTestCase >> test_gotoPackageMenuItemHierarchyTab [
	| commandQuery gotoItem |
	self testsIssue: #issue217 withTitle: 'Eliminate Dictionary Browser'.
	self testsIssue: #issue491 withTitle: '(Oscar 3.0.73) need a way to find class in the dictionary '.
	self selectNoneProject.
	self selectServiceNamed: 'UserGlobals' in: self dictionaryPresenter. 
	self selectServiceNamed: 'JadeServer' in: self classListPresenter.
	self selectHierarchyTab.
	commandQuery := self
				queryCommand: #gotoClassDefinedPackage
				inPresenter: self projectsPresenter
				view: self classListPresenter view.
	self assert: commandQuery isEnabled.
	self projectsPresenter updateClassMenu: self classListPresenter view queryContextMenu. "done by menu building infrastructure"
	gotoItem := self classListPresenter view queryContextMenu items
				detect: [:menuItem | menuItem command == #gotoClassDefinedPackage].
	self assert: gotoItem description equals: 'Go To Defining Package (Rowan-JadeServer)'.
	gotoItem commandDescription performAgainst: self projectsPresenter.
	commandQuery := self
				queryCommand: #gotoClassDefinedPackage
				inPresenter: self projectsPresenter
				view: self classListPresenter view.
	self deny: commandQuery isEnabled
]

{ #category : 'as yet unclassified' }
JadeiteProjectBrowserDictionaryTestCase >> test_multipleBrowsersUpdateClassList [
	| firstClassList |
	self testsIssue: #issue217 withTitle: 'Eliminate Dictionary Browser'.
	self selectNoneProject.
	self selectClassListTab.
	self selectServiceNamed: 'RowanKernel' in: self dictionaryPresenter.
	firstClassList := self classListPresenter list.
	self openSecondBrowser.
	self assert: self classListPresenter list equals: firstClassList.
	self selectServiceNamed: 'RowanSample1' in: secondPresenter projectListPresenter.
	self selectServiceNamed: 'RowanSample1-Tests' in: secondPresenter packageListPresenter.
	self assert: self classListPresenter list equals: firstClassList.
	self deny: secondPresenter classListPresenter list equals: firstClassList
]

{ #category : 'as yet unclassified' }
JadeiteProjectBrowserDictionaryTestCase >> test_mutliSelectDictionaryHierarchy [
	self testsIssue: #issue217 withTitle: 'Eliminate Dictionary Browser'.
	self testsIssue: #issue489 withTitle: '(3.0.73) package multi-select is not functional'.
	self selectNoneProject.
	self selectServicesNamed: #('UserGlobals' 'Published') in: self dictionaryPresenter.
	self assert: (self classListPresenter list collect: [:classService | classService name]) asArray
		equals: #('JadeServer' 'JadeServer64bit' 'JadeServer64bit24' 'JadeServer64bit32' 'JadeServer64bit35' 'JadeServer64bit3x' 'Rowan').
	self selectHierarchyTab.
	#('Object' 'JadeServer' 'JadeServer64bit' 'JadeServer64bit24' 'JadeServer64bit3x' 'JadeServer64bit32' 'JadeServer64bit35' 'Rowan')
		do: 
			[:className |
			self assert: ((self classHierarchyPresenter model asArray collect: [:service | service name])
						includes: className)]
]

{ #category : 'as yet unclassified' }
JadeiteProjectBrowserDictionaryTestCase >> test_mutliSelectPackageHierarchy [
	self testsIssue: #issue217 withTitle: 'Eliminate Dictionary Browser'.
	self testsIssue: #issue489 withTitle: '(3.0.73) package multi-select is not functional'.
	self selectServiceNamed: 'Rowan' in: self projectListPresenter.
	self selectServicesNamed: #('Rowan-Kernel' 'Rowan-Specifications') in: self packageListPresenter.
	self assert: (self classListPresenter list collect: [:classService | classService name]) asArray
		equals: #('Rowan' 'RwPlatform' 'RwSpecification').
	self selectHierarchyTab.
	#('Object' 'Rowan' 'RwPlatform' 'RwSpecification') do: 
			[:className |
			self assert: ((self classHierarchyPresenter model asArray collect: [:service | service name])
						includes: className)]
]

{ #category : 'as yet unclassified' }
JadeiteProjectBrowserDictionaryTestCase >> test_packageAndDictionaryViewClass [
	"test for the same view for a consistent look and feel.
	EditableListView is a subclass of ListView"
	self testsIssue: #issue217 withTitle: 'Eliminate Dictionary Browser'.
	self selectServiceNamed: 'Rowan' in: self projectListPresenter.
	self assert: self projectsPresenter packageListPresenter view class equals: EditableListView.
	self selectServiceNamed: RowanProjectService noneProject name in: self projectListPresenter.
	self assert: self projectsPresenter dictionaryPresenter view class equals: EditableListView.
	self assert: self projectsPresenter projectListPresenter view class equals: ListView.
	self assert: self projectsPresenter classListPresenter view class equals: ListView.
	self assert: self projectsPresenter categoryListPresenter view class equals: ListView.
	self assert: self projectsPresenter variableListPresenter view class equals: ListView.
	self assert: self projectsPresenter methodListPresenter view class equals: ListView
]

{ #category : 'as yet unclassified' }
JadeiteProjectBrowserDictionaryTestCase >> test_removeMethodInNonPackagedClass [

	self testsIssue: #issue217 withTitle: 'Eliminate Dictionary Browser'.
	self selectNoneProject.
	self selectServiceNamed: 'Globals' in: self dictionaryPresenter.
	self selectServiceNamed: 'Array' in: self classListPresenter.
	self methodSourcePresenter value: 'foo ^''foo'''.

	[
	self projectsPresenter
		editSaveMethod: self classListPresenter selection
		onCompletion: nil.
	self assert: self methodListPresenter selection selector equals: #foo.
	self projectsPresenter removeMethods:
		self classListPresenter selections.
	self deny: (self methodListPresenter selectionIfNone: [ false ]) ]
		ensure: [
			self dictionaryPresenter resetSelection. "to avoid long refresh"
			self abortTransaction.
			self cloneRowanSample1.
			self ensureRowanSampleProjectsLoaded ]
]

{ #category : 'as yet unclassified' }
JadeiteProjectBrowserDictionaryTestCase >> test_selectProjectClearHierarchy [
	self testsIssue: #issue217 withTitle: 'Eliminate Dictionary Browser'.
	self selectNoneProject.
	self selectServiceNamed: 'UserGlobals' in: self dictionaryPresenter.
	self selectServiceNamed: 'JadeServer' in: self classListPresenter.
	self selectHierarchyTab.
	self deny: self classHierarchyPresenter model isEmpty.
	self selectServiceNamed: 'Rowan' in: self projectListPresenter.
	self assert: self classHierarchyPresenter model isEmpty.
	self selectClassListTab.
	self assert: self classListPresenter model isEmpty
]

{ #category : 'as yet unclassified' }
JadeiteProjectBrowserDictionaryTestCase >> test_unicodeKeyInUserGlobals [
	| selection |
	self testsIssue: #issue582
		withTitle: 'SymbolDictionary browser completely broken by an unreadable value in a Global '.
	session executeString: 'RowanServicesTest new addUnicodeSymbolKeyToUserGlobals'.
	
	[self selectNoneProject.
	self selectServiceNamed: 'UserGlobals' in: self dictionaryPresenter.	"bug occurred here"
	selection := self projectsPresenter globalsTab list
				detect: [:array | array first = 'UserGlobals.<<unprintable string. charSize > 1>>'].
	self projectsPresenter globalsTab selection: selection.
	self assert: (selection at: 2) equals: #String.
	self assert: ((selection at: 3) isKindOf: Integer).
	self assert: (selection at: 4) equals: '''fnoodle''']
			ensure: [session executeString: 'RowanServicesTest new removeUnicodeSymbolsFromUserGlobals']
]

{ #category : 'as yet unclassified' }
JadeiteProjectBrowserDictionaryTestCase >> test_unicodeValueInUserGlobals [
	| selection |
	self testsIssue: #issue582
		withTitle: 'SymbolDictionary browser completely broken by an unreadable value in a Global '.
	session executeString: 'RowanServicesTest new addUnicodeValueToUserGlobals'.
	
	[self selectNoneProject.
	self selectServiceNamed: 'UserGlobals' in: self dictionaryPresenter.	"bug occurred here"
	selection := self projectsPresenter globalsTab list
				detect: [:array | array first = 'UserGlobals.bad'].
	self projectsPresenter globalsTab selection: selection.
	self assert: (selection at: 2) equals: #Symbol.
	self assert: ((selection at: 3) isKindOf: Integer).
	self assert: (#'*Â£Â¥*' match: (selection at: 4)) ]
			ensure: [session executeString: 'RowanServicesTest new removeUnicodeSymbolsFromUserGlobals']
]

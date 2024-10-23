Class {
	#name : 'JadeiteSUnitPresenterWithoutRowan',
	#superclass : 'JadeiteSUnitPresenter',
	#instVars : [
		'dictionaryListPresenter'
	],
	#category : 'Jadeite-SUnitBrowser',
	#package : 'Jadeite-SUnitBrowser'
}

{ #category : 'updates' }
JadeiteSUnitPresenterWithoutRowan >> addUpdatedTestClasses: classServices [
	"don't show class unless the package concurs"

	| inSelectedPackage |
	inSelectedPackage := OrderedCollection new.
	dictionaryListPresenter selections do: 
			[:packageService |
			packageService classes
				ifNotNil: 
					[classServices
						do: [:classService | (packageService classes includes: classService) ifTrue: [inSelectedPackage add: classService]]]].
	classListPresenter model addAll: inSelectedPackage.
	methodListPresenter clear
]

{ #category : 'initialization' }
JadeiteSUnitPresenterWithoutRowan >> connectPresenters [

	dictionaryListPresenter whenSelectionChangedDo: [ :selection | 
		self onDictionaryChanged ].
	classListPresenter whenSelectionChangedDo: [ :selection | 
		self onClassesChanged ]
]

{ #category : 'accessing' }
JadeiteSUnitPresenterWithoutRowan >> dictionaryListPresenter [

	^ dictionaryListPresenter
]

{ #category : 'accessing' }
JadeiteSUnitPresenterWithoutRowan >> dictionaryListPresenter: anObject [

	dictionaryListPresenter := anObject
]

{ #category : 'initialization' }
JadeiteSUnitPresenterWithoutRowan >> initializePresenters [

	| listPresenters |

	textResultPresenter := (JadeiteTextDocument new text: String new)
		                       beNotEditable;
		                       beNotWrapWord;
		                       withoutLineNumbers.
	self layout
		add: textResultPresenter
		withConstraints: [ :constraints | constraints height: 30 ].
	listPresenters := SpBoxLayout newHorizontal.
	listPresenters spacing: 10.
	self layout add: listPresenters.

	dictionaryListPresenter := JadeiteListPresenter newNameSortedList
		                        headerTitle: 'Dictionaries'.
	listPresenters add: dictionaryListPresenter.
	classListPresenter := JadeiteListPresenter newNameSortedList
		                      headerTitle: 'Classes'.
	classListPresenter beMultipleSelection.
	self initializeBrowseClassMenu.
	listPresenters add: classListPresenter.
	methodListPresenter := JadeiteListPresenter newNameSortedList
		                       headerTitle: 'Test Selector'.
	methodListPresenter
		beMultipleSelection;
		displayIcon: [ :item | item testResultIconForBrowser: self ].
	self initializeBrowseMethodListMenu.
	self addSUnitMethodListMenuItems.
	listPresenters add: methodListPresenter
]

{ #category : 'events' }
JadeiteSUnitPresenterWithoutRowan >> onDictionaryChanged [

	self updateClassesOnCompletion: [
		self reset.
		classListPresenter unselectAll.
		methodListPresenter list: Array new ]
]

{ #category : 'registration' }
JadeiteSUnitPresenterWithoutRowan >> registerPresentersForUpdates [
	RowanServiceUpdater current register: dictionaryListPresenter selector: #testDictionaries:.
	RowanServiceUpdater current
		register: classListPresenter
		selector: #testClasses:browser:
		browser: self.
	RowanServiceUpdater current
		register: classListPresenter
		selector: #renamedClass:browser:
		browser: self.
	RowanServiceUpdater current register: classListPresenter selector: #removedClass:.
	RowanServiceUpdater current
		register: methodListPresenter
		selector: #sunitMethodsUpdate:browser:
		browser: self.
	RowanServiceUpdater current
		register: methodListPresenter
		selector: #testResultUpdate:browser:
		browser: self
]

{ #category : 'updates' }
JadeiteSUnitPresenterWithoutRowan >> updateClassesOnCompletion: completionBlock [

	| dictionaryServices |
	self initializeClassList.
	dictionaryServices := dictionaryListPresenter selections.
	dictionaryServices do: [ :dictionaryService |
		dictionaryService command: #testClasses ].
	RowanServiceUpdater current
		issueCommands: dictionaryServices
		session: self gciSession
		onCompletion: completionBlock
]

{ #category : 'updates' }
JadeiteSUnitPresenterWithoutRowan >> updateDictionariesOnCompletion: completionBlock [

	| browserService |
	browserService := RowanBrowserService new.
	browserService command: #dictionariesWithTests.
	self issueCommand: browserService onCompletion: [
		testCounter at: 1 put: browserService testCount.
		completionBlock value ]
]

{ #category : 'updates' }
JadeiteSUnitPresenterWithoutRowan >> updateMethodsFrom: classServices [
	| newMethods selectedSelectors removals dictionaryNames |
	classServices isEmpty ifTrue: [^methodListPresenter list: ListModel new].
	selectedSelectors := methodListPresenter selections
				collect: [:methodService | methodService selector].
	removals := OrderedCollection new.
	newMethods := OrderedCollection new.
	classServices do: 
			[:classService |
			| tests |
			"show the class that the test will be run under"
			tests := classService visibleTests.
			tests do: [:methodService | methodService className: classService name].
			newMethods addAll: tests].
	self update: newMethods orRemove: removals.
	dictionaryNames := dictionaryListPresenter selections collect: [:service | service name].
	methodListPresenter model
		do: [:methodService | methodService inSelectedPackage: (dictionaryNames includes: methodService packageName)].
	methodListPresenter selections: (methodListPresenter model
				select: [:methodService | selectedSelectors includes: methodService selector]).
	methodListPresenter view invalidate.
	methodListPresenter view resortOnLastColumnClicked
]

{ #category : 'initialization' }
JadeiteSUnitPresenterWithoutRowan >> updatePresenter [

	super updatePresenter.
	testCounter := Array with: 0 with: OrderedCollection new.
	self updateDictionariesOnCompletion: [  ]
]

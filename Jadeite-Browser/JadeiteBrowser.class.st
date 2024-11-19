Class {
	#name : 'JadeiteBrowser',
	#superclass : 'JadeitePresenterWithAutoCommitButton',
	#traits : 'JadeiteMethodsTrait + JadeiteProjectsTrait + JadeiteToolbarTrait + JadeiteClassTrait + JadeiteFilterTrait + JadeitePackageTrait',
	#classTraits : 'JadeiteMethodsTrait classTrait + JadeiteProjectsTrait classTrait + JadeiteToolbarTrait classTrait + JadeiteClassTrait classTrait + JadeiteFilterTrait classTrait + JadeitePackageTrait classTrait',
	#instVars : [
		'tabs',
		'toolbar',
		'postOpenBlock'
	],
	#category : 'Jadeite-Browser',
	#package : 'Jadeite-Browser'
}

{ #category : 'instance creation' }
JadeiteBrowser class >> new [

	^ JadeitePreferences isRowanLoaded
		  ifTrue: [ super new ]
		  ifFalse: [ JadeiteBrowserWithoutRowan new ]
]

{ #category : 'instance creation' }
JadeiteBrowser class >> openOn: theOwner postOpen: aBlock [

	| browser |
	browser := self new
		           owner: theOwner;
		           gciSession: GciSession current;
		           postOpenBlock: aBlock;
		           open.
	^ browser
]

{ #category : 'accessing' }
JadeiteBrowser >> activePresenter [

	^ self tabs selectedPage activePresenter
]

{ #category : 'initialization' }
JadeiteBrowser >> addStyle: aString [
	super addStyle: aString. 
	self cards do:[:notebookPage |
		notebookPage activePresenter ifNotNil: [ :presenter |
		presenter addStyle: aString ]]
]

{ #category : 'commands' }
JadeiteBrowser >> basicAddMethodCategory: aString [

	^self activePresenter basicAddMethodCategory: aString
]

{ #category : 'accessing' }
JadeiteBrowser >> browserPresenterClass [

	^ JadeitePreferences isRowanLoaded
		  ifTrue: [ JadeiteBrowserPresenter ]
		  ifFalse: [ JadeiteBrowserPresenterWithoutRowan ]
]

{ #category : 'testing' }
JadeiteBrowser >> canDiscardEdits [

	^ self activePresenter canDiscardEdits
]

{ #category : 'initialization' }
JadeiteBrowser >> cards [

	^tabs pages
]

{ #category : 'initialization' }
JadeiteBrowser >> cardsPresenter [
	"for legacy tests"
	^self cards 
]

{ #category : 'accessing' }
JadeiteBrowser >> categoryListPresenter [

	^ self activePresenter categoryListPresenter
]

{ #category : 'accessing' }
JadeiteBrowser >> classListPresenter [ 

	^ (tabs pages at: tabs selectedPageIndex) activePresenter classListPresenter
]

{ #category : 'actions' }
JadeiteBrowser >> closeCard [

	self tabs removePage: self tabs currentCard
]

{ #category : 'initialization' }
JadeiteBrowser >> connectPresenters [

	super connectPresenters.
	tabs whenPageRemovedDo: [ :removedPage |
		tabs pages do: [ :openPage |
			openPage activePresenter updateSystemTab ] ]
]

{ #category : 'accessing' }
JadeiteBrowser >> currentCard [ 
	"for ported test support (only?)"
	^self activePresenter
]

{ #category : 'layout' }
JadeiteBrowser >> defaultLayout [ 

	^SpBoxLayout newVertical
]

{ #category : 'accessing' }
JadeiteBrowser >> gciSession [

	^ gciSession
]

{ #category : 'accessing' }
JadeiteBrowser >> gciSession: anObject [

	gciSession := anObject.
	gciSession ifNil: [ ^self ]. 
	gciSession autoCommit
		whenChangedSend: #updateAutoCommitButton
		to: self.
	self updateAutoCommitButton
]

{ #category : 'initialization' }
JadeiteBrowser >> initializeBindings [

	self
		bindKeyCombination: $n meta asKeyCombination
		toAction: [ self openBrowser ];
		bindKeyCombination: $t meta asKeyCombination
		toAction: [ self openBrowserTab ];
		bindKeyCombination: $f shift ctrl toAction: [ self findClass ]
]

{ #category : 'initialization' }
JadeiteBrowser >> initializeJadeiteMenu [

	^ JadeiteMenuPresenter new
		  addGroup: [ :group |
			  group
				  addItem: [ :item |
					  item
						  name: 'New Browser';
						  shortcut: $n meta;
						  action: [ self openBrowser ] ];
				  addItem: [ :item |
					  item
						  name: 'New Tab';
						  shortcut: $t meta;
						  action: [ self openBrowserTab ] ] ];
		  addGroup: [ :group |
			  group
				  addItem: [ :item |
					  item
						  name: 'Find Class ...';
						  shortcut: $f shift ctrl;
						  action: [ self findClass ] ];
				  addItem: [ :item |
					  item
						  name: 'Find Class References ...';
						  shortcut: $r shift ctrl;
						  action: [ self findClassReferences ] ] ];
		  yourself
]

{ #category : 'initialization' }
JadeiteBrowser >> initializeKeyBindings: aWindowPresenter [

	aWindowPresenter
		bindKeyCombination: $n meta toAction: [ self openBrowser ];
		bindKeyCombination: $t meta toAction: [ self openBrowserTab ];
		bindKeyCombination: $f shift ctrl toAction: [ self findClass ];
		bindKeyCombination: $r shift ctrl
		toAction: [ self findClassReferences ]
]

{ #category : 'initialization' }
JadeiteBrowser >> initializeMenubar [

	^ self newMenuBar
		  addGroup: [ :group |
			  group
				  addItem: [ :item |
					  item
						  name: 'Jadeite';
						  subMenu: self initializeJadeiteMenu ];
				  addItem: [ :item |
					  item
						  name: 'Project';
						  subMenu: self newProjectMenu ];
				  addItem: [ :item |
					  item
						  name: 'Package';
						  subMenu: self newPackageMenu ];
				  addItem: [ :item |
					  item
						  name: 'Class';
						  subMenu: self newFullClassMenu ];
				  addItem: [ :item |
					  item
						  name: 'Category';
						  subMenu: self newCategoryMenu ];
				  addItem: [ :item |
					  item
						  name: 'Method';
						  subMenu: self fullMethodListMenu ].
			  self addToolbarItemsToMenuGroup: group ];
		  yourself
]

{ #category : 'initialization' }
JadeiteBrowser >> initializePresenters [

	super initializePresenters.
	"self initializeToolbar."
	tabs := self instantiate: JadeiteNotebookPresenter.
	self openNewBrowserTab.
	self layout add: tabs.
	self initializeAutoCommitPresenter.
	self initializeBindings
]

{ #category : 'initialization' }
JadeiteBrowser >> initializeWindow: aWindowPresenter [
	"keep font & row computations for investigation but comment out for now."

	| initialExtent |
	
	initialExtent := (160 @ 100) * StandardFonts defaultFont pointSize.
	super initializeWindow: aWindowPresenter.
	aWindowPresenter
		initialExtent: initialExtent;
		menu: self initializeMenubar.
	self initializeKeyBindings: aWindowPresenter.
	aWindowPresenter whenClosedDo: [
		self cards do: [ :notebookPage |
			notebookPage ifNotNil: [ :page | "presenter may be nil if the presenter could not open"
				page activePresenter ifNotNil: [ :presenter |
					presenter unsubcribePresenters ] ] ] ].
	self updateCaption
]

{ #category : 'testing' }
JadeiteBrowser >> isCategorySelected [

	^self activePresenter isCategorySelected
]

{ #category : 'testing' }
JadeiteBrowser >> isClassSelected [

	^self activePresenter isClassSelected
]

{ #category : 'testing' }
JadeiteBrowser >> isRowanProjectSelected [

	^self activePresenter isRowanProjectSelected
]

{ #category : 'accessing' }
JadeiteBrowser >> methodListPresenter [

	^ (tabs pages at: tabs selectedPageIndex) activePresenter methodListPresenter
]

{ #category : 'accessing' }
JadeiteBrowser >> methodsListPresenter [

	^ (tabs pages at: tabs selectedPageIndex) methodListPresenter
]

{ #category : 'testing' }
JadeiteBrowser >> okToClose [

	self window isOpen ifFalse: [ ^ true ].
	^ self activePresenter canDiscardEdits
]

{ #category : 'actions' }
JadeiteBrowser >> openBrowserTab [

	^self openNewBrowserTab
]

{ #category : 'commands' }
JadeiteBrowser >> openNewBrowserPresenter [

	| browserPresenter |
	browserPresenter := self browserPresenterClass new
		                    postOpenBlock: postOpenBlock;
		                    application: self application;
		                    gciSession: gciSession.
	browserPresenter
		addStyle: 'jadeWorkspace';
		owner: self.
	self application registerBrowserEventsFor: browserPresenter.
	browserPresenter postOpen.
	^ browserPresenter
]

{ #category : 'actions' }
JadeiteBrowser >> openNewBrowserTab [

	| notebookPage |
	notebookPage := JadeiteNotebookPage
		                title: 'Browser'
		                icon: nil
		                provider: [ self openNewBrowserPresenter ].
	notebookPage beCloseable.
	tabs addPage: notebookPage.
	tabs selectPage: notebookPage
]

{ #category : 'accessing' }
JadeiteBrowser >> packageListPresenter [

	^ self activePresenter packageListPresenter
]

{ #category : 'accessing' }
JadeiteBrowser >> postOpenBlock [

	^ postOpenBlock
]

{ #category : 'accessing' }
JadeiteBrowser >> postOpenBlock: anObject [

	postOpenBlock := anObject
]

{ #category : 'accessing' }
JadeiteBrowser >> projectListPresenter [

	^(tabs pages at: tabs selectedPageIndex) activePresenter projectListPresenter 
]

{ #category : 'testing' }
JadeiteBrowser >> removeClass [

	^self activePresenter removeClass
]

{ #category : 'commands' }
JadeiteBrowser >> selectedClass [

	^self activePresenter selectedClass
]

{ #category : 'accessing' }
JadeiteBrowser >> selectedClassTab [

	^ (tabs pages at: tabs selectedPageIndex) selectedClassTab
]

{ #category : 'constants' }
JadeiteBrowser >> shellName [
	^'Jadeite Browser '
]

{ #category : 'accessing' }
JadeiteBrowser >> tabs [

	^ tabs
]

{ #category : 'accessing' }
JadeiteBrowser >> tabs: anObject [

	tabs := anObject
]

{ #category : 'actions' }
JadeiteBrowser >> updateAfterFindClassName: className methodSelector: selector meta: meta [

	^ self activePresenter
		  updateAfterFindClassName: className
		  methodSelector: selector
		  meta: meta
]

{ #category : 'initialization' }
JadeiteBrowser >> updateCaption [
	self caption: (self gciSession titleBarFor: self shellName)
]

{ #category : 'tabs' }
JadeiteBrowser >> updateLabel: aString [
	
	tabs selectedPage ifNotNil: [:page | page title: aString]. 
	
]

{ #category : 'tabs' }
JadeiteBrowser >> updateLabel: aString for: tabbedPresenter [
	
	tabs selectedPage title: aString. 
	
]

{ #category : 'tabs' }
JadeiteBrowser >> updateTabs [
]

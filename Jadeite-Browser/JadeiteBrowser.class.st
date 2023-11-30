Class {
	#name : 'JadeiteBrowser',
	#superclass : 'JadeitePresenterWithAutoCommitButton',
	#traits : 'JadeiteMethodsTrait + JadeiteProjectsTrait + JadeiteToolbarTrait + JadeiteClassTrait + JadeiteFilterTrait + JadeitePackageTrait',
	#classTraits : 'JadeiteMethodsTrait classTrait + JadeiteProjectsTrait classTrait + JadeiteToolbarTrait classTrait + JadeiteClassTrait classTrait + JadeiteFilterTrait classTrait + JadeitePackageTrait classTrait',
	#instVars : [
		'tabs',
		'toolbar'
	],
	#category : 'Jadeite-Browser'
}

{ #category : 'actions' }
JadeiteBrowser >> abortTransaction [
	^self application abortTransaction.
]

{ #category : 'accessing' }
JadeiteBrowser >> activePresenter [

	^ self tabs selectedPage activePresenter
]

{ #category : 'initialization' }
JadeiteBrowser >> addStyle: aString [
	super addStyle: aString. 
	self cards do:[:notebookPage |
		notebookPage activePresenter addStyle: aString ]
]

{ #category : 'commands' }
JadeiteBrowser >> basicAddMethodCategory: aString [

	^self activePresenter basicAddMethodCategory: aString
]

{ #category : 'accessing' }
JadeiteBrowser >> caption: aString [

	self owner title: aString
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

{ #category : 'actions' }
JadeiteBrowser >> closeCard [

	self tabs removePage: self tabs currentCard
]

{ #category : 'actions' }
JadeiteBrowser >> commitTransaction [
	^self application commitTransaction.
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

	^ self newMenu
		  addGroup: [ :group | 
			  group
				  addItem: [ :item | 
					  item
						  name: 'New Projects Browser';
						  shortcut: $n meta;
						  action: [ self openBrowser ] ];
				  addItem: [ :item | 
					  item
						  name: 'New Projects Tab';
						  shortcut: $t meta;
						  action: [ self openBrowserTab ] ] ];
		  addItem: [ :item | 
			  item
				  name: 'Find Class ...';
				  shortcut: $f shift ctrl;
				  action: [ self findClass ] ];
		  yourself
]

{ #category : 'initialization' }
JadeiteBrowser >> initializeKeyBindings: aWindowPresenter [

	aWindowPresenter
		bindKeyCombination: $n meta toAction: [ self openBrowser ];
		bindKeyCombination: $t meta toAction: [ self openBrowserTab ];
		bindKeyCombination: $f shift ctrl toAction: [ self findClass ]
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
						  subMenu: self newClassMenu ];
				  addItem: [ :item |
					  item
						  name: 'Category';
						  subMenu: self newCategoryMenu ];
				  addItem: [ :item |
					  item
						  name: 'Method';
						  subMenu: self newMethodListMenu ] ];
		  yourself
]

{ #category : 'initialization' }
JadeiteBrowser >> initializePresenters [

	super initializePresenters.
	self initializeMenubar.
	self initializeToolbar.
	tabs := self instantiate: JadeiteNotebookPresenter.
	self openNewBrowserTab.
	self layout add: tabs.
	self initializeAutoCommitPresenter.
	self initializeBindings.
]

{ #category : 'initialization' }
JadeiteBrowser >> initializeWindow: aWindowPresenter [

	super initializeWindow: aWindowPresenter.
	aWindowPresenter
		initialExtent: 1600 @ 1000;
		menu: self initializeMenubar.
	self initializeKeyBindings: aWindowPresenter.
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

	^self activePresenter canDiscardEdits
]

{ #category : 'actions' }
JadeiteBrowser >> openBrowserTab [

	^self openNewBrowserTab
]

{ #category : 'commands' }
JadeiteBrowser >> openNewBrowserPresenter [

	| browserPresenter |
	browserPresenter := JadeiteBrowserPresenter new
		                    application: self application;
		                    gciSession: gciSession;
		                    updateProjects.
	browserPresenter
		addStyle: 'jadeWorkspace';
		owner: self;
		build.
	self application registerBrowserEventsFor: browserPresenter.
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
JadeiteBrowser >> projectListPresenter [

	^(tabs pages at: tabs selectedPageIndex) activePresenter projectListPresenter 
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
	^'Jadeite Project Browser for '
]

{ #category : 'accessing' }
JadeiteBrowser >> tabs [

	^ tabs
]

{ #category : 'accessing' }
JadeiteBrowser >> tabs: anObject [

	tabs := anObject
]

{ #category : 'initialization' }
JadeiteBrowser >> updateCaption [
	self caption: (self gciSession titleBarFor: self shellName)
]

{ #category : 'tabs' }
JadeiteBrowser >> updateLabel: aString [
	
	tabs selectedPage title: aString. 
	MorphicRenderLoop new doOneCycle. "repaint the label"
	
]

{ #category : 'tabs' }
JadeiteBrowser >> updateLabel: aString for: tabbedPresenter [
	
	tabs selectedPage title: aString. 
	
]

{ #category : 'tabs' }
JadeiteBrowser >> updateTabs [
]

Class {
	#name : 'JadeiteBrowser',
	#superclass : 'SpAbstractWidgetPresenter',
	#traits : 'JadeiteMethodsTrait + JadeiteProjectsTrait + JadeiteToolbarTrait + JadeiteClassTrait + JadeiteFilterTrait + JadeitePackageTrait',
	#classTraits : 'JadeiteMethodsTrait classTrait + JadeiteProjectsTrait classTrait + JadeiteToolbarTrait classTrait + JadeiteClassTrait classTrait + JadeiteFilterTrait classTrait + JadeitePackageTrait classTrait',
	#instVars : [
		'tabs',
		'toolbar',
		'gciSession',
		'browserPresenters',
		'autoCommitButton'
	],
	#category : 'JadeiteBrowser'
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
	browserPresenters do:[:browserPresenter |
		browserPresenter addStyle: aString ]
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

	^browserPresenters
]

{ #category : 'accessing' }
JadeiteBrowser >> categoryListPresenter [

	^ self activePresenter categoryListPresenter
]

{ #category : 'actions' }
JadeiteBrowser >> commitTransaction [
	^self application commitTransaction.
]

{ #category : 'layout' }
JadeiteBrowser >> defaultLayout [ 

	^SpBoxLayout newVertical
]

{ #category : 'actions' }
JadeiteBrowser >> flipAutoCommit [
	self gciSession flipAutoCommit
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
JadeiteBrowser >> initialize [ 
	super initialize. 
	browserPresenters := OrderedCollection new.
]

{ #category : 'initialization' }
JadeiteBrowser >> initializeAutoCommitPresenter [

	| autoCommitBox |
	autoCommitBox := SpBoxLayout newHorizontal.
	autoCommitButton := SpButtonPresenter new.
	autoCommitButton action: [ self flipAutoCommit ].
	autoCommitBox
		add: autoCommitButton
		withConstraints: [ :constraints | 
			constraints
				height: 25;
				width: 150 ].
	self layout add: autoCommitBox expand: false
]

{ #category : 'initialization' }
JadeiteBrowser >> initializeJadeiteMenu [

	^ self newMenu
		  addGroup: [ :group | 
			  group
				  addItem: [ :item | 
					  item
						  name: 'New Browser';
						  shortcut: $n meta;
						  action: [ self openBrowser ] ];
				  addItem: [ :item | 
					  item
						  name: 'New Browser Tab';
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
	self initializeAutoCommitPresenter
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
JadeiteBrowser >> isClassSelected [

	^self activePresenter isClassSelected
]

{ #category : 'testing' }
JadeiteBrowser >> isRowanProjectSelected [

	^self activePresenter isRowanProjectSelected
]

{ #category : 'accessing' }
JadeiteBrowser >> methodListPresenter [

	^ (browserPresenters at: tabs selectedPageIndex) methodListPresenter
]

{ #category : 'accessing' }
JadeiteBrowser >> methodsListPresenter [

	^ (browserPresenters at: tabs selectedPageIndex) methodListPresenter
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
	browserPresenters add: browserPresenter.
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

	^(browserPresenters at: tabs selectedPageIndex) projectListPresenter 
]

{ #category : 'commands' }
JadeiteBrowser >> selectedClass [

	^self activePresenter selectedClass
]

{ #category : 'accessing' }
JadeiteBrowser >> selectedClassTab [

	^ (browserPresenters at: tabs selectedPageIndex) selectedClassTab
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

{ #category : 'updates' }
JadeiteBrowser >> updateAutoCommitButton [

	self gciSession autoCommit value == #failed ifTrue: [ 
		autoCommitButton label: 'Auto Commit - failed'.
		^ autoCommitButton color: Color red ].
	self gciSession autoCommit value
		ifTrue: [ 
			autoCommitButton color: Color green.
			autoCommitButton label: 'Auto Commit - true' ]
		ifFalse: [ 
			autoCommitButton color: autoCommitButton defaultColor.
			autoCommitButton label: 'Auto Commit - false' ].
]

{ #category : 'initialization' }
JadeiteBrowser >> updateCaption [
	self caption: (self gciSession titleBarFor: self shellName)
]

{ #category : 'displaying' }
JadeiteBrowser >> updateLabel: aString [
	
	tabs selectedPage title: aString. 
	
]

{ #category : 'displaying' }
JadeiteBrowser >> updateLabel: aString for: tabbedPresenter [
	
	tabs selectedPage title: aString. 
	
]

{ #category : 'updates' }
JadeiteBrowser >> updateTabs [
]

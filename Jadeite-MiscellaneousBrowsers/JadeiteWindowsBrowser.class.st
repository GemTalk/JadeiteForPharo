"
Display Jadeite windows and allow users to do basic operations with them like raise and close
"
Class {
	#name : 'JadeiteWindowsBrowser',
	#superclass : 'JadeiteAutoRefreshPresenter',
	#traits : 'JadeiteToolbarTrait',
	#classTraits : 'JadeiteToolbarTrait classTrait',
	#instVars : [
		'windows',
		'windowsListPresenter',
		'layoutBox'
	],
	#category : 'Jadeite-MiscellaneousBrowsers',
	#package : 'Jadeite-MiscellaneousBrowsers'
}

{ #category : 'accessing' }
JadeiteWindowsBrowser class >> currentApplication [ 

	^JadeiteApplication new 
]

{ #category : 'instance creation' }
JadeiteWindowsBrowser class >> showOnSession: aGciSession [

	| inst windowPresenter |
	inst := self basicNew.
	inst initialize.
	inst
		gciSession: aGciSession;
		application: JadeiteConsole currentConsole application.
	windowPresenter := inst open.
	inst refresh. "to show this window in list"
	inst addStyle: 'jadeiteTextBackgroundColor'.
	^ inst
]

{ #category : 'api' }
JadeiteWindowsBrowser >> addStyle: aString [

	super addStyle: aString.
	waitIndicator addStyle: aString.
	layoutBox ifNotNil: [ layoutBox adapter addStyle: aString ].
]

{ #category : 'actions' }
JadeiteWindowsBrowser >> closeSelectedWindow [

	windowsListPresenter selectedItem window
		collapse;
		minimizeOrRestore;
		close.
	self refresh
]

{ #category : 'defaults' }
JadeiteWindowsBrowser >> defaultLayout [ 

	^SpBoxLayout newVertical
]

{ #category : 'initialization' }
JadeiteWindowsBrowser >> initializeJadeiteWindows [

	windows := JadeiteConnectionProfile connectionProfile jadeiteWindows
	           ,
	           (Array with: JadeiteConnectionLauncher soleInstance window).
	windows := windows asSortedCollection: [ :x :y | x title <= y title ]
]

{ #category : 'initialization' }
JadeiteWindowsBrowser >> initializeMenubar [

	^ self newMenuBar
		  addGroup: [ :group |
			  group addItem: [ :item |
					  item
						  name: 'Windows';
						  subMenu: self newWindowsMenu ].
			  self addToolbarItemsToMenuGroup: group ];
		  yourself
]

{ #category : 'initialization' }
JadeiteWindowsBrowser >> initializePresenters [

	| waitBox |
	super initializePresenters.
	autoRefreshPresenter := self newCheckBox
		                        label: 'Auto Refresh';
		                        state: false.
	self layout
		add: autoRefreshPresenter
		withConstraints: [ :constraints | constraints bePlacedAtEnd ].
	layoutBox := SpBoxLayout newVertical.
	self layout add: layoutBox.
	waitBox := self initializeWaitPresenter.
	layoutBox add: waitBox expand: false.
	self initializeWindowsListPresenterTo: layoutBox
]

{ #category : 'initialization' }
JadeiteWindowsBrowser >> initializeWindow: aWindowPresenter [

	super initializeWindow: aWindowPresenter.
	aWindowPresenter
		initialExtent: 80 @ 30 * StandardFonts defaultFont pointSize;
		menu: self initializeMenubar.
	self updateCaption
]

{ #category : 'initialization' }
JadeiteWindowsBrowser >> initializeWindowsListMenu [
	self windowsListPresenter contextMenu: self newWindowsMenu
]

{ #category : 'initialization' }
JadeiteWindowsBrowser >> initializeWindowsListPresenterTo: box [

	windowsListPresenter := JadeiteListPresenter new display: [ :window |
		                        window title ].
	windowsListPresenter headerTitle: 'Jadeite Windows'.
	box add: windowsListPresenter.
	self initializeWindowsListMenu
]

{ #category : 'initialization' }
JadeiteWindowsBrowser >> newWindowsMenu [

	| menu |
	menu := JadeiteMenuPresenter new.
	menu
		addGroup: [ :group |
			group
				addItem: [ :item |
					item
						name: 'Raise';
						action: [ self raiseSelectedWindow ];
						enabled: [ self windowsListPresenter selectionOrNil notNil ] ];
				addItem: [ :item |
					item
						name: 'Close';
						action: [ self closeSelectedWindow ];
						enabled: [ self windowsListPresenter selectionOrNil notNil ] ] ];
		addGroup: [ :group |
			group addItem: [ :item |
				item
					name: 'Refresh';
					action: [ self refresh ] ] ].
	^ menu
]

{ #category : 'actions' }
JadeiteWindowsBrowser >> raiseSelectedWindow [
	"kind of weird pharo code, but it seems that we have to collapse
	the window first, then do a `minimizeOrRestore`"

	windowsListPresenter selectedItem window
		collapse;
		minimizeOrRestore
]

{ #category : 'accessing - model' }
JadeiteWindowsBrowser >> refresh [

	self initializeJadeiteWindows.
	windowsListPresenter list: (ListModel on: windows)
]

{ #category : 'accessing - model' }
JadeiteWindowsBrowser >> setModelBeforeInitialization: jadeiteWindows [

	jadeiteWindows copy do: [ :jadeiteWindow |
		jadeiteWindow isClosed ifTrue: [
			jadeiteWindows remove: jadeiteWindow ] ].
	windows := jadeiteWindows
]

{ #category : 'constants' }
JadeiteWindowsBrowser >> shellName [
	^'Jadeite Windows Browser'
]

{ #category : 'accessing' }
JadeiteWindowsBrowser >> windowsListPresenter [

	^ windowsListPresenter
]

{ #category : 'accessing' }
JadeiteWindowsBrowser >> windowsListPresenter: anObject [

	windowsListPresenter := anObject
]

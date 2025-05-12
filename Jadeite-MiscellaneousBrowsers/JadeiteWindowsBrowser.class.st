"
Display Jadeite windows and allow users to do basic operations with them like raise and close
"
Class {
	#name : 'JadeiteWindowsBrowser',
	#superclass : 'JadeiteAutoRefreshPresenter',
	#traits : 'JadeiteToolbarTrait',
	#classTraits : 'JadeiteToolbarTrait classTrait',
	#instVars : [
		'layoutBox',
		'pharoWindows',
		'jadeiteWindows',
		'jadeiteWindowsListPresenter',
		'pharoWindowsListPresenter'
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
JadeiteWindowsBrowser >> closeJadeiteSelectedWindow [

	jadeiteWindowsListPresenter selectedItem window
		collapse;
		minimizeOrRestore;
		close.
	self refresh
]

{ #category : 'actions' }
JadeiteWindowsBrowser >> closePharoSelectedWindow [

	pharoWindowsListPresenter selectedItem window
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
JadeiteWindowsBrowser >> initializeMenubar [

	^ self newMenuBar
		  addGroup: [ :group |
			  group
				  addItem: [ :item |
					  item
						  name: 'Jadeite Windows';
						  subMenu: self newJadeiteWindowsMenu ];
				  addItem: [ :item |
					  item
						  name: 'Pharo Windows';
						  subMenu: self newPharoWindowsMenu ].
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
		initialExtent: 90 @ 30 * StandardFonts defaultFont pointSize;
		menu: self initializeMenubar.
	self updateCaption
]

{ #category : 'initialization' }
JadeiteWindowsBrowser >> initializeWindows [

	| allWindows |
	allWindows := self currentWorld windowsSatisfying: [ :w | true ].
	allWindows := allWindows asSortedCollection: [ :x :y | x label < y label ].
	jadeiteWindows := allWindows select: [ :w | w isJadeiteWindow ].
	pharoWindows := allWindows reject: [ :w | w isJadeiteWindow ]
]

{ #category : 'initialization' }
JadeiteWindowsBrowser >> initializeWindowsListMenu [

	jadeiteWindowsListPresenter contextMenu: self newJadeiteWindowsMenu.
	pharoWindowsListPresenter contextMenu: self newPharoWindowsMenu
]

{ #category : 'initialization' }
JadeiteWindowsBrowser >> initializeWindowsListPresenterTo: box [

	| listsBox |
	listsBox := SpBoxLayout newHorizontal.
	jadeiteWindowsListPresenter := JadeiteListPresenter new display: [
		                               :window | window label ].
	jadeiteWindowsListPresenter headerTitle: 'Jadeite Windows'.
	listsBox add: jadeiteWindowsListPresenter.

	pharoWindowsListPresenter := JadeiteListPresenter new display: [
		                             :window | window label ].
	pharoWindowsListPresenter headerTitle: 'Pharo Windows'.
	listsBox add: pharoWindowsListPresenter.

	box add: listsBox.
	self initializeWindowsListMenu
]

{ #category : 'initialization' }
JadeiteWindowsBrowser >> newJadeiteWindowsMenu [

	| menu |
	menu := JadeiteMenuPresenter new.
	menu
		addGroup: [ :group |
			group
				addItem: [ :item |
					item
						name: 'Raise';
						action: [ self raiseJadeiteSelectedWindow ];
						enabled: [ jadeiteWindowsListPresenter selectionOrNil notNil ] ];
				addItem: [ :item |
					item
						name: 'Close';
						action: [ self closeJadeiteSelectedWindow ];
						enabled: [ jadeiteWindowsListPresenter selectionOrNil notNil ] ] ];
		addGroup: [ :group |
			group addItem: [ :item |
				item
					name: 'Refresh';
					action: [ self refresh ] ] ].
	^ menu
]

{ #category : 'initialization' }
JadeiteWindowsBrowser >> newPharoWindowsMenu [

	| menu |
	menu := JadeiteMenuPresenter new.
	menu
		addGroup: [ :group |
			group
				addItem: [ :item |
					item
						name: 'Raise';
						action: [ self raisePharoSelectedWindow ];
						enabled: [ pharoWindowsListPresenter selectionOrNil notNil ] ];
				addItem: [ :item |
					item
						name: 'Close';
						action: [ self closePharoSelectedWindow ];
						enabled: [ pharoWindowsListPresenter selectionOrNil notNil ] ] ];
		addGroup: [ :group |
			group addItem: [ :item |
				item
					name: 'Refresh';
					action: [ self refresh ] ] ].
	^ menu
]

{ #category : 'actions' }
JadeiteWindowsBrowser >> raiseJadeiteSelectedWindow [
	"kind of weird pharo code, but it seems that we have to collapse
	the window first, then do a `minimizeOrRestore`"

	jadeiteWindowsListPresenter selectedItem window
		collapse;
		minimizeOrRestore
]

{ #category : 'actions' }
JadeiteWindowsBrowser >> raisePharoSelectedWindow [

	pharoWindowsListPresenter selectedItem window
		collapse;
		minimizeOrRestore
]

{ #category : 'accessing - model' }
JadeiteWindowsBrowser >> refresh [

	self initializeWindows.
	jadeiteWindowsListPresenter list: (ListModel on: jadeiteWindows).
	pharoWindowsListPresenter list: (ListModel on: pharoWindows)
]

{ #category : 'constants' }
JadeiteWindowsBrowser >> shellName [
	^'Jadeite Windows Browser'
]

{ #category : 'accessing' }
JadeiteWindowsBrowser >> windowsListPresenter [

	^ jadeiteWindowsListPresenter
]

{ #category : 'accessing' }
JadeiteWindowsBrowser >> windowsListPresenter: anObject [

	jadeiteWindowsListPresenter := anObject
]

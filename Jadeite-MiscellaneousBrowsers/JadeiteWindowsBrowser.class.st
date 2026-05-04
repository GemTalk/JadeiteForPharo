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

{ #category : 'constants' }
JadeiteWindowsBrowser class >> defaultPreferredExtent [

	^ 90 @ 30
]

{ #category : 'instance creation' }
JadeiteWindowsBrowser class >> show [

	| inst windowPresenter |
	inst := self basicNew.
	inst initialize.
	inst application: JadeiteApplication new.
	windowPresenter := inst open.
	inst refresh. "to show this window in list"
	inst
		addStyle: 'jadeiteTextBackgroundColor';
		showNotWait.
	^ inst
]

{ #category : 'api' }
JadeiteWindowsBrowser >> addStyle: aString [

	super addStyle: aString.
	waitIndicator addStyle: aString.
	layoutBox ifNotNil: [ layoutBox adapter addStyle: aString ].
]

{ #category : 'actions' }
JadeiteWindowsBrowser >> closeJadeiteWindows [

	jadeiteWindowsListPresenter selectedItems do: [ :presenter |
		presenter window close ].
	self refresh
]

{ #category : 'actions' }
JadeiteWindowsBrowser >> closePharoWindows [

	pharoWindowsListPresenter selectedItems do: [ :presenter |
		presenter window close ].
	self refresh
]

{ #category : 'initialization' }
JadeiteWindowsBrowser >> connectPresenters [

	super connectPresenters.
	jadeiteWindowsListPresenter whenActivatedDo: [ :selection |
		self raiseJadeiteWindows ].
	pharoWindowsListPresenter whenActivatedDo: [ :selection |
		self raisePharoWindows ].
	SystemAnnouncer uniqueInstance weak
		when: UIThemeChanged
		send: #themeChanged
		to: self
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
						  subMenu: self newPharoWindowsMenu ] ];
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
	autoRefreshPresenter state: true
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
	jadeiteWindowsListPresenter := JadeiteListPresenter new
		                               display: [ :window | window label ];
		                               displayBold: [ :window |
			                               window isTopWindow ];
		                               beMultipleSelection.
	jadeiteWindowsListPresenter headerTitle: 'Jadeite Windows'.
	listsBox add: jadeiteWindowsListPresenter.

	pharoWindowsListPresenter := JadeiteListPresenter new
		                             display: [ :window | window label ];
		                             displayBold: [ :window |
			                             window isTopWindow ];
		                             beMultipleSelection.
	pharoWindowsListPresenter headerTitle: 'Pharo Windows'.
	listsBox add: pharoWindowsListPresenter.

	box add: listsBox.
	self initializeWindowsListMenu
]

{ #category : 'accessing' }
JadeiteWindowsBrowser >> jadeiteWindowsListPresenter [

	^ jadeiteWindowsListPresenter
]

{ #category : 'accessing' }
JadeiteWindowsBrowser >> jadeiteWindowsListPresenter: anObject [

	jadeiteWindowsListPresenter := anObject
]

{ #category : 'actions' }
JadeiteWindowsBrowser >> lowerJadeiteWindows [

	jadeiteWindowsListPresenter selectedItems do: [ :presenter |
		presenter window collapse ]
]

{ #category : 'actions' }
JadeiteWindowsBrowser >> lowerPharoWindows [

	pharoWindowsListPresenter selectedItems do: [ :presenter |
		presenter window collapse ]
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
						action: [ self raiseJadeiteWindows ];
						enabled: [ jadeiteWindowsListPresenter selectionOrNil notNil ] ];
				addItem: [ :item |
					item
						name: 'Lower';
						action: [ self lowerJadeiteWindows ];
						enabled: [ jadeiteWindowsListPresenter selectionOrNil notNil ] ];
				addItem: [ :item |
					item
						name: 'Close';
						action: [ self closeJadeiteWindows ];
						enabled: [ jadeiteWindowsListPresenter selectionOrNil notNil ] ] ];
		addGroup: [ :group |
			group addItem: [ :item |
				item
					name: 'Refresh';
					action: [ self refresh ] ] ];
		addGroup: [ :group |
			group addItem: [ :item |
				item
					name: 'Inspect';
					action: [ jadeiteWindowsListPresenter selectionOrNil inspect ];
					enabled: [ jadeiteWindowsListPresenter selectionOrNil notNil ] ] ].
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
						action: [ self raisePharoWindows ];
						enabled: [ pharoWindowsListPresenter selectionOrNil notNil ] ];
				addItem: [ :item |
					item
						name: 'Lower';
						action: [ self lowerPharoWindows ];
						enabled: [ pharoWindowsListPresenter selectionOrNil notNil ] ];
				addItem: [ :item |
					item
						name: 'Close';
						action: [ self closePharoWindows ];
						enabled: [ pharoWindowsListPresenter selectionOrNil notNil ] ] ];
		addGroup: [ :group |
			group addItem: [ :item |
				item
					name: 'Refresh';
					action: [ self refresh ] ] ];
		addGroup: [ :group |
			group addItem: [ :item |
				item
					name: 'Inspect';
					action: [ pharoWindowsListPresenter selectionOrNil inspect ];
					enabled: [ pharoWindowsListPresenter selectionOrNil notNil ] ] ].
	^ menu
]

{ #category : 'showing' }
JadeiteWindowsBrowser >> open [

	^ self asWindow open
]

{ #category : 'accessing' }
JadeiteWindowsBrowser >> pharoWindowsListPresenter [

	^ pharoWindowsListPresenter
]

{ #category : 'accessing' }
JadeiteWindowsBrowser >> pharoWindowsListPresenter: anObject [

	pharoWindowsListPresenter := anObject
]

{ #category : 'actions' }
JadeiteWindowsBrowser >> raiseJadeiteWindows [
	"kind of weird pharo code, but it seems that we have to collapse
	the window first, then do a `minimizeOrRestore`"

	[
		jadeiteWindowsListPresenter selectedItems do: [ :presenter |
				presenter window
					collapse;
					minimizeOrRestore ] ]
		on: Error
		do: [ :ex | "no action. User can double click again" ]
]

{ #category : 'actions' }
JadeiteWindowsBrowser >> raisePharoWindows [

	[
		pharoWindowsListPresenter selectedItems do: [ :presenter |
				presenter window
					collapse;
					minimizeOrRestore ] ]
		on: Error
		do: [ :ex | "no action. User can double click again" ]
]

{ #category : 'actions' }
JadeiteWindowsBrowser >> refresh [

	| jadeiteSelections pharoSelections |
	jadeiteSelections := jadeiteWindowsListPresenter selectedItems.
	pharoSelections := pharoWindowsListPresenter selectedItems.
	self updateWindows.
	jadeiteWindowsListPresenter list: (ListModel on: jadeiteWindows).
	pharoWindowsListPresenter list: (ListModel on: pharoWindows).
	jadeiteWindowsListPresenter selectItems: jadeiteSelections.
	pharoWindowsListPresenter selectItems: pharoSelections
]

{ #category : 'constants' }
JadeiteWindowsBrowser >> shellName [
	^'Jadeite Windows Browser'
]

{ #category : 'actions' }
JadeiteWindowsBrowser >> startAutoRefresh [

	super startAutoRefresh.
	autoRefreshProcess name: 'Jadeite Windows Browser Auto Refresh'
]

{ #category : 'events' }
JadeiteWindowsBrowser >> themeChanged [

	PharoLightTheme isCurrent
		ifTrue: [
				waitIndicator adapter widget color:
					JadeiteApplication defaultBackgroundColor.
				layoutBox adapter widget color:
					JadeiteApplication defaultBackgroundColor.
				autoRefreshPresenter adapter widget color:
					JadeiteApplication defaultBackgroundColor ]
		ifFalse: [
				waitIndicator adapter widget color: self theme backgroundColor.
				layoutBox adapter widget color: self theme backgroundColor.
				autoRefreshPresenter adapter widget color:
					self theme backgroundColor ]
]

{ #category : 'constants' }
JadeiteWindowsBrowser >> updateInterval [

	^ 0.5
]

{ #category : 'actions' }
JadeiteWindowsBrowser >> updateWindows [

	| allWindows handWindows |
	allWindows := self currentWorld windowsSatisfying: [ :w | true ].
	"windowsSatisfying: only sees World submorphs. During a drag the window
	 is temporarily reparented to the Hand, so include hand submorphs too."
	handWindows := self currentWorld currentHand submorphs
		               select: [ :m | m embeddedWindowOrNil notNil ].
	allWindows := (allWindows , handWindows) asSet
		              asSortedCollection: [ :x :y | x label < y label ].
	jadeiteWindows := allWindows select: [ :w | w isJadeiteWindow ].
	pharoWindows := allWindows reject: [ :w | w isJadeiteWindow ]
]

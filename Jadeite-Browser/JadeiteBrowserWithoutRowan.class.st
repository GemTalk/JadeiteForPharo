Class {
	#name : 'JadeiteBrowserWithoutRowan',
	#superclass : 'JadeiteBrowser',
	#category : 'Jadeite-Browser',
	#package : 'Jadeite-Browser'
}

{ #category : 'instance creation' }
JadeiteBrowserWithoutRowan class >> new [

	^self basicNew initialize
]

{ #category : 'actions' }
JadeiteBrowserWithoutRowan >> basicFileInServerFile: filePath [

	| service |
	service := RowanFileServiceClient new
		           path: filePath;
		           session: self gciSession.
	^ service fileInOnCompletion: [ :svc |
			  self activePresenter ifNotNil: [ :presenter |
				  presenter updateDictionariesOnCompletion: [ ] ] ]
]

{ #category : 'actions' }
JadeiteBrowserWithoutRowan >> fileInServerFile [

	| filePath |
	filePath := JadeiteServerFileSelectorDialog
		            showOnSession: gciSession
		            defaultPath: JadePresenter homeEnvVarString.
	filePath ifNotNil: [ self basicFileInServerFile: filePath ]
]

{ #category : 'initialization' }
JadeiteBrowserWithoutRowan >> initializeMenubar [

	^ self newMenuBar
		  addGroup: [ :group |
			  group
				  addItem: [ :item |
					  item
						  name: 'Jadeite';
						  subMenu: self initializeJadeiteMenu ];
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
			  self addToolsToMenuGroup: group ];
		  yourself
]

{ #category : 'initialization' }
JadeiteBrowserWithoutRowan >> initializeWindow: aWindowPresenter [

	super initializeWindow: aWindowPresenter.
	aWindowPresenter initialExtent:
		150 @ 80 * StandardFonts defaultFont pointSize
]

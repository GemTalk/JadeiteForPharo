Extension { #name : 'JadeiteBrowserPresenter' }

{ #category : '*Jadeite-AI' }
JadeiteBrowserPresenter >> askJadeiteAboutSelectedClass [
	"Open (or activate) the Ask Jadeite window with the selected class as context."

	| classService |
	classService := self selectedClass.
	classService ifNil: [ ^ self ].
	JadeiteAIChatPresenter
		openWithSession: gciSession
		classService: classService
]

{ #category : '*Jadeite-AI' }
JadeiteBrowserPresenter >> askJadeiteAboutSelectedMethods [
	"Open (or activate) the Ask Jadeite window with the selected methods as context."

	| selected |
	selected := self selectedMethods.
	(selected isNil or: [ selected isEmpty ]) ifTrue: [ ^ self ].
	JadeiteAIChatPresenter
		openWithSession: gciSession
		methodServices: selected
]

{ #category : '*Jadeite-AI' }
JadeiteBrowserPresenter >> fullMethodListMenu [
	"Override trait method to append Ask Jadeite to the method list context menu."

	| menu |
	menu := self newBrowseMethodListMenu.

	menu addGroup: [ :group |
		group addItem: [ :item |
			item
				name: 'Remove Method(s) ...';
				action: [ self removeMethods ] ] ].
	JadeitePreferences isRowanLoaded ifTrue: [
		menu addGroup: [ :group |
			group
				addItem: [ :item |
					item
						name: 'Move to Package ...';
						action: [ self moveMethodToPackage ] ];
				addItem: [ :item |
					item
						name: 'Move to Current Package';
						action: [ self moveMethodToCurrentPackage ] ] ] ].
	menu addGroup: [ :group |
		group addItem: [ :item |
			item
				name: 'File Out Selected Methods ...';
				action: [ self fileoutMethods ];
				enabled: [ self methodListPresenter selections notEmpty ] ] ].
	menu addGroup: [ :group |
		group addItem: [ :item |
			item
				name: 'Ask Jadeite about selected method(s)';
				icon: (self iconNamed: #glamorousHelp);
				action: [ self askJadeiteAboutSelectedMethods ];
				enabled: [ self methodListPresenter selections notEmpty ] ] ].
	^ menu
]

{ #category : '*Jadeite-AI' }
JadeiteBrowserPresenter >> newFullClassMenu [
	"Override to append Ask Jadeite to the full class context menu."

	| menu |
	menu := self newBrowseClassMenu.
	self addModifyClassMenuItemsTo: menu.
	menu addGroup: [ :group |
		group addItem: [ :item |
			item
				name: 'Ask Jadeite about this class';
				icon: (self iconNamed: #glamorousHelp);
				action: [ self askJadeiteAboutSelectedClass ] ] ].
	^ menu
]

{ #category : '*Jadeite-AI' }
JadeiteBrowserPresenter >> newHierarchyClassMenu [
	"Override to append Ask Jadeite to the hierarchy class context menu."

	| menu |
	menu := self newBrowseClassMenu.
	self addModifyClassMenuItemsTo: menu.
	self addHierarchySpecificMenuItemsTo: menu.
	menu addGroup: [ :group |
		group addItem: [ :item |
			item
				name: 'Ask Jadeite about this class';
				icon: (self iconNamed: #glamorousHelp);
				action: [ self askJadeiteAboutSelectedClass ] ] ].
	^ menu
]

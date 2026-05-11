Extension { #name : 'JadeiteBrowserPresenter' }

{ #category : '*Jadeite-AI' }
JadeiteBrowserPresenter >> askJadeiteAboutSelectedClass [
	"Open (or activate) the Ask Jadeite window with the selected class as context."

	| classService chatPresenter |
	classService := self selectedClass.
	classService ifNil: [ ^ self ].
	chatPresenter := JadeiteAIChatPresenter currentWindow.
	chatPresenter
		ifNil: [ chatPresenter := JadeiteAIChatApplication showOnSession: gciSession library ]
		ifNotNil: [ [ chatPresenter window window activate ] on: Error do: [  ] ].
	chatPresenter ifNotNil: [ chatPresenter setClassContext: classService ]
]

{ #category : '*Jadeite-AI' }
JadeiteBrowserPresenter >> askJadeiteAboutSelectedMethods [
	"Open (or activate) the Ask Jadeite window with the selected methods as context."

	| selected chatPresenter |
	selected := self selectedMethods.
	(selected isNil or: [ selected isEmpty ]) ifTrue: [ ^ self ].
	chatPresenter := JadeiteAIChatPresenter currentWindow.
	chatPresenter
		ifNil: [ chatPresenter := JadeiteAIChatApplication showOnSession: gciSession library ]
		ifNotNil: [ [ chatPresenter window window activate ] on: Error do: [  ] ].
	chatPresenter ifNotNil: [ chatPresenter setMethodsContext: selected ]
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

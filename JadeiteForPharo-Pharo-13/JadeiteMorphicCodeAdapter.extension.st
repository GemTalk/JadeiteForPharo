Extension { #name : 'JadeiteMorphicCodeAdapter' }

{ #category : '*JadeiteForPharo-Pharo-13' }
JadeiteMorphicCodeAdapter >> codePaneMenu: aMenu shifted: shifted [

	| menuPresenter actionGroup |
	actionGroup := SpActionGroup new beRoot.

	self presenter internalActions ifNotNil: [ :group |
		actionGroup add: group beRoot ].
	self addExtraActionsTo: actionGroup.
	self presenter actions ifNotNil: [ :group |
		actionGroup add: group beRoot ].
	self presenter hasEditionContextMenu ifTrue: [
		actionGroup add: self presenter editionCommandsGroup beRoot ].

	menuPresenter := self presenter newMenu.
	menuPresenter fillWith: actionGroup.

	"apply context menu if there is one"
	self presenter contextMenu ifNotNil: [ :aContextMenu |
			self presenter actions ifNotNil: [
					Error signal:
						'You are using contextMenu: and actions: at the same time. Both mechanisms are mutually exclusive.' ]
			"menuPresenter := aContextMenu " "<<<<< JfP change. Don't override the new menu" ].

	^ SpBindings
		  value: self model application adapterBindings
		  during: [ menuPresenter value build ]
]

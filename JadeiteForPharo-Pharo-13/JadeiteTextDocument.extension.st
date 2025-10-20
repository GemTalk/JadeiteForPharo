Extension { #name : 'JadeiteTextDocument' }

{ #category : '*JadeiteForPharo-Pharo-13' }
JadeiteTextDocument >> buildContextMenuWith: aValuable [

	| menuPresenter |
	overrideContextMenu ifTrue: [ ^ aValuable ].

	menuPresenter := self newContextMenu.
	aValuable ifNotNil: [
		aValuable value ifNotNil: [ :menu |
			menu menuGroups do: [ :aGroup | menuPresenter addMenuGroup: aGroup ] ] ].

	^ menuPresenter
]

{ #category : '*JadeiteForPharo-Pharo-13' }
JadeiteTextDocument >> contextMenu [
	
	^ [ self buildContextMenuWith: super contextMenu ]
]

{ #category : '*JadeiteForPharo-Pharo-13' }
JadeiteTextDocument >> newContextMenu [

	^ self rootCommandsGroup asMenuPresenter
]

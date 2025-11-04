Extension { #name : 'JadeiteTextInputFieldAdapter' }

{ #category : '*JadeiteForPharo-Pharo-13' }
JadeiteTextInputFieldAdapter >> codePaneMenu: aMenu shifted: shifted [

	| menuPresenter |
	menuPresenter := self model contextMenu.
	menuPresenter ifNil: [ ^ nil ].
	^ SpBindings
		  value: self model application adapterBindings
		  during: [ menuPresenter value build ]
]

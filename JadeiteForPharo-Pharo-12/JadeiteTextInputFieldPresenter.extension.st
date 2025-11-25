Extension { #name : 'JadeiteTextInputFieldPresenter' }

{ #category : '*JadeiteForPharo-Pharo-12' }
JadeiteTextInputFieldPresenter >> whenSubmitDo: aBlock [
	"This method will add a 'submit' event to the widget. It will react when user 
	 presses <meta+s> key (this is for historical reasons), and with enter (cr).
	 `aBlock` receives one argument (the submited text)"

	self
		bindKeyCombination: SpAcceptChangesCommand defaultShortcutKey
			| Character cr asKeyCombination
		toAction: [ aBlock value: self adapter widget text asString ]
]

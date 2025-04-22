Class {
	#name : 'JadeiteSearchDialogWindow',
	#superclass : 'ListDialogWindow',
	#category : 'Jadeite-SupportClasses',
	#package : 'Jadeite-SupportClasses'
}

{ #category : 'initialization' }
JadeiteSearchDialogWindow >> initialize [

	super initialize.
	self bindKeyCombination: Character escape toAction: [ self cancel ]
]

{ #category : 'actions' }
JadeiteSearchDialogWindow >> newButtons [
	"remove browse buttons"

	^ {
		  self newCancelButton.
		  (self newOKButton isDefault: true) }
]

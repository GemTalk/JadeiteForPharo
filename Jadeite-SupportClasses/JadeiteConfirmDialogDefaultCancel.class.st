Class {
	#name : 'JadeiteConfirmDialogDefaultCancel',
	#superclass : 'SpConfirmDialog',
	#category : 'Jadeite-SupportClasses'
}

{ #category : 'initialization' }
JadeiteConfirmDialogDefaultCancel >> initializeDialogWindow: aDialogWindowPresenter [
	"See comment in SpDialogWindowPresenter>>buttons. 
	Last button added is default but is a to-do item"
	aDialogWindowPresenter
		okAction: acceptAction;
		cancelAction: cancelAction.
	self parentWindow
		ifNotNil: [ :w | aDialogWindowPresenter centeredRelativeTo: w ]
		ifNil: [ aDialogWindowPresenter centered ].
	aDialogWindowPresenter
		addButton: self acceptLabel do: [ :presenter | self accept ];
		addDefaultButton: self cancelLabel do: [ :presenter | self cancel ]
]

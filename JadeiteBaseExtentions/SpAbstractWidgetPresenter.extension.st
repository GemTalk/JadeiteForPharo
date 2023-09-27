Extension { #name : 'SpAbstractWidgetPresenter' }

{ #category : '*JadeiteBaseExtentions' }
SpAbstractWidgetPresenter >> isOpen [ 

	^self window isOpen
]

{ #category : '*JadeiteBaseExtentions' }
SpAbstractWidgetPresenter >> view [
	"ported code from dolphin gets the view of the MVC.
	Pharo, I think, uses the presenter instead for many view functions AFAIK"
	^self 
]

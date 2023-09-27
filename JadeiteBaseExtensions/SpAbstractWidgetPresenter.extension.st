Extension { #name : 'SpAbstractWidgetPresenter' }

{ #category : '*JadeiteBaseExtensions' }
SpAbstractWidgetPresenter >> isOpen [ 

	^self window isOpen
]

{ #category : '*JadeiteBaseExtensions' }
SpAbstractWidgetPresenter >> view [
	"ported code from dolphin gets the view of the MVC.
	Pharo, I think, uses the presenter instead for many view functions AFAIK"
	^self 
]

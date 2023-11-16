Extension { #name : 'SpAbstractWidgetPresenter' }

{ #category : '*Jadeite-BaseExtensions' }
SpAbstractWidgetPresenter >> isOpen [ 

	^self window isOpen
]

{ #category : '*Jadeite-BaseExtensions' }
SpAbstractWidgetPresenter >> view [
	"ported code from dolphin gets the view of the MVC.
	Pharo, I think, uses the presenter instead for many view functions AFAIK"
	^self 
]

Extension { #name : 'SpAbstractWidgetPresenter' }

{ #category : '*JadeiteToolsSupportClasses' }
SpAbstractWidgetPresenter >> isOpen [ 

	^self window isOpen
]

{ #category : '*JadeiteToolsSupportClasses' }
SpAbstractWidgetPresenter >> view [
	"ported code from dolphin gets the view of the MVC.
	Pharo, I think, uses the presenter instead for many view functions AFAIK"
	^self 
]

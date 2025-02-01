Class {
	#name : 'JadeiteModalWindowPresenter',
	#superclass : 'SpModalWindowPresenter',
	#category : 'Jadeite-BaseExtensions',
	#package : 'Jadeite-BaseExtensions'
}

{ #category : 'private - showing' }
JadeiteModalWindowPresenter >> openWithLayout: aSpecLayout [

	self buildWithSpecLayout: aSpecLayout.
	self application registerWindow: self.
	self withAdapterDo: [ :anAdapter | 
		anAdapter openWithDeferredAction: [ 
			self allPresenters do: [ :each | each announceDisplayed ].
			anAdapter widget beUnsticky. 
			self updateTitle ] ]
]

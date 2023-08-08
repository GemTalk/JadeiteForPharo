Extension { #name : 'SpPresenter' }

{ #category : '*JadeiteToolsSupportClasses' }
SpPresenter >> update: browserUpdate withSelector: selector [ 
	browserUpdate
		updatesPerform: selector
		presenter: self.
]

{ #category : '*JadeiteToolsSupportClasses' }
SpPresenter >> update: browserUpdate withSelector: selector browser: browser [
	browserUpdate
		updatesPerform: selector
		presenter: self
		browser: browser.
	(browser class canUnderstand: #redrawAllViews) ifTrue: [browser redrawAllViews]
]

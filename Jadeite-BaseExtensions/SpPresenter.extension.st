Extension { #name : 'SpPresenter' }

{ #category : '*Jadeite-BaseExtensions' }
SpPresenter >> update: browserUpdate withSelector: selector browser: browser [
	browserUpdate
		updatesPerform: selector
		presenter: self
		browser: browser.
]

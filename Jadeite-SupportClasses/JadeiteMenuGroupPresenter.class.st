Class {
	#name : 'JadeiteMenuGroupPresenter',
	#superclass : 'SpMenuGroupPresenter',
	#category : 'Jadeite-SupportClasses'
}

{ #category : 'api' }
JadeiteMenuGroupPresenter >> addItem: aBlock [
	| item |
	
	item := self instantiate: JadeiteMenuItemPresenter.
	aBlock value: item.
	self addMenuItem: item
]

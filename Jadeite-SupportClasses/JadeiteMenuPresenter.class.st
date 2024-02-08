Class {
	#name : 'JadeiteMenuPresenter',
	#superclass : 'SpMenuPresenter',
	#category : 'Jadeite-SupportClasses'
}

{ #category : 'api' }
JadeiteMenuPresenter >> addGroup: aBlock [
	"copied from SpMenuPresenter"
	| group |

	group := self instantiate: JadeiteMenuGroupPresenter.
	aBlock value: group.
	self addMenuGroup: group
]

{ #category : 'api' }
JadeiteMenuPresenter >> defaultGroup [
	"copied from SpMenuPresenter"
	^ defaultGroup ifNil: [ 
		defaultGroup := self instantiate: JadeiteMenuGroupPresenter.
		self addMenuGroup: defaultGroup.
		defaultGroup ]
]

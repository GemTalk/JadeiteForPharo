Class {
	#name : 'JadeiteMenuItemPresenter',
	#superclass : 'SpMenuItemPresenter',
	#category : 'Jadeite-SupportClasses',
	#package : 'Jadeite-SupportClasses'
}

{ #category : 'api' }
JadeiteMenuItemPresenter >> action [

	^ action
]

{ #category : 'private' }
JadeiteMenuItemPresenter >> performMenuActionWith: aMenuItem [

	| en |
	en := self isEnabled.
	en isBlock ifTrue: [ en := en value ].
	en ifFalse: [ ^ self ].

	self action cull: aMenuItem
]

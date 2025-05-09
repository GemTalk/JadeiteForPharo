"
Superclass for Jaded's presenters. 
Provides things like hooks to register presenters for updates.
"
Class {
	#name : 'JadeiteSessionPresenter',
	#superclass : 'JadeitePresenter',
	#instVars : [
		'gciSession'
	],
	#category : 'Jadeite-SupportClasses',
	#package : 'Jadeite-SupportClasses'
}

{ #category : 'accessing' }
JadeiteSessionPresenter >> gciSession [

	^ gciSession 
]

{ #category : 'accessing' }
JadeiteSessionPresenter >> gciSession: aGciSession [

	gciSession := aGciSession
]

{ #category : 'initialization' }
JadeiteSessionPresenter >> initializeWindow: aWindowPresenter [

	super initializeWindow: aWindowPresenter.
	aWindowPresenter whenClosedDo: [
		JadeiteConnectionProfile connectionProfile ifNotNil: [ :profile |
			profile removeJadeiteWindow: aWindowPresenter ] ]
]

{ #category : 'showing' }
JadeiteSessionPresenter >> open [

	| jadeiteWindow |
	jadeiteWindow := super open.
	JadeiteConnectionProfile connectionProfile ifNotNil: [ :profile |
		profile addJadeiteWindow: jadeiteWindow ].
	^ jadeiteWindow
]

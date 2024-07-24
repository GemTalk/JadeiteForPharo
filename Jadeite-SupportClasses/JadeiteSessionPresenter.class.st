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

{ #category : 'showing' }
JadeiteSessionPresenter >> open [

	| jadeiteWindow |
	jadeiteWindow := super open.
	JadeiteConnectionProfile connectionProfile ifNotNil: [ :profile |
		profile jadeiteWindows add: jadeiteWindow ].
	^ jadeiteWindow
]

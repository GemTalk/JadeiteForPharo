Class {
	#name : 'JadeiteRenameClassMethodListBrowser',
	#superclass : 'JadeiteMethodListBrowser',
	#category : 'Jadeite-MethodBrowser',
	#package : 'Jadeite-MethodBrowser'
}

{ #category : 'as yet unclassified' }
JadeiteRenameClassMethodListBrowser class >> openOn: answeringService selecting: string session: session [

	| shell |
	(shell := JadeiteMethodListApplication showOnSession: session library)
		firstReferenceString: string.
	shell methods: answeringService answer.
	answeringService answer isEmpty ifTrue: [ ^ shell selecting: 0 ].
	answeringService answer first firstReference
		ifNil: [
			string ifNotNil: [
				| index |
				index := answeringService answer first source
					         indexOfSubCollection: string.
				shell selecting: index ] ]
		ifNotNil: [ :index | shell selecting: index ].
	^ shell
]

{ #category : 'as yet unclassified' }
JadeiteRenameClassMethodListBrowser >> presenterClass [
	^JadeiteRenameClassMethodListPresenter
]

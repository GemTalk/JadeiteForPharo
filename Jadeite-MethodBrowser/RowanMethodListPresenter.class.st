Class {
	#name : 'RowanMethodListPresenter',
	#superclass : 'JadeMethodListPresenter',
	#category : 'Jadeite-MethodBrowser',
	#package : 'Jadeite-MethodBrowser'
}

{ #category : 'as yet unclassified' }
RowanMethodListPresenter >> browseMethodsFromString: aString [

	| list |
	list := RowanMethodDefinition
		listFromString: aString
		session: self gciSession.
	methodListPresenter list: list asSortedCollection.
	list notEmpty ifTrue: [
		methodListPresenter selectFirstMethod.
	].

]

{ #category : 'as yet unclassified' }
RowanMethodListPresenter >> browseMethodsFromString: aString methodName: methodName [
	| list |

	list := RowanMethodDefinition
		listFromString: aString
		session: self gciSession.
	methodListPresenter list: list asSortedCollection.
	list notEmpty ifTrue: [
		methodListPresenter selectFirstMethod.
	].
]

{ #category : 'as yet unclassified' }
RowanMethodListPresenter >> browseMethodsFromString: aString methodName: methodName type: browseType [
	| list |
	list := RowanMethodDefinition
		listFromString: aString
		session: self gciSession.
	methodListPresenter list: list asSortedCollection.
	list notEmpty ifTrue: [
		methodListPresenter selectFirstMethod.
	].
]

{ #category : 'as yet unclassified' }
RowanMethodListPresenter >> list: aCollection [
	methodListPresenter list: aCollection

]

{ #category : 'as yet unclassified' }
RowanMethodListPresenter >> methodSourcePresenter [

	^methodSourcePresenter
]

{ #category : 'as yet unclassified' }
RowanMethodListPresenter >> selectedPackage [

	^methodListPresenter selectedMethod packageName
]

{ #category : 'as yet unclassified' }
RowanMethodListPresenter >> updateSaveMethodOop: anInteger [

	super updateSaveMethodOop: anInteger.
	methodListPresenter primaryPresenter selection
]

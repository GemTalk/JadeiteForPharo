Class {
	#name : 'JadeAbstractHistoryEntry',
	#superclass : 'Object',
	#instVars : [
		'methodName',
		'className',
		'classCategory'
	],
	#category : 'Jadeite-MethodBrowser'
}

{ #category : 'as yet unclassified' }
JadeAbstractHistoryEntry class >> newFrom: aJadeAutoSystemBrowserPresenter [

	^super new initialize
		populateFrom: aJadeAutoSystemBrowserPresenter;
		yourself
]

{ #category : 'as yet unclassified' }
JadeAbstractHistoryEntry >> classCategory [
	^classCategory

]

{ #category : 'as yet unclassified' }
JadeAbstractHistoryEntry >> classCategory: anObject [
	classCategory := anObject

]

{ #category : 'as yet unclassified' }
JadeAbstractHistoryEntry >> className [
	^className

]

{ #category : 'as yet unclassified' }
JadeAbstractHistoryEntry >> className: anObject [
	className := anObject

]

{ #category : 'as yet unclassified' }
JadeAbstractHistoryEntry >> getClassName [
	"<className> is anArray with all hierarchy names"

	(className isKindOf: String) ifTrue: [^className].

	(className isNil or: [className isEmpty]) ifTrue: [^''].

	^className last

]

{ #category : 'as yet unclassified' }
JadeAbstractHistoryEntry >> getMethodName [
	"<methodName> is anArray with different GemStone values"

	(methodName isKindOf: String) ifTrue: [^methodName].

	(methodName isNil or: [methodName isEmpty]) ifTrue: [^''].

	^methodName first
]

{ #category : 'as yet unclassified' }
JadeAbstractHistoryEntry >> hasAllValues [

	^self hasMethodName and: [self hasClassName] 
]

{ #category : 'as yet unclassified' }
JadeAbstractHistoryEntry >> hasClassName [
	"<className> is anArray with all hierarchy names"

	^self getClassName notEmpty
]

{ #category : 'as yet unclassified' }
JadeAbstractHistoryEntry >> hasMethodName [

	^self getMethodName notEmpty
	
]

{ #category : 'as yet unclassified' }
JadeAbstractHistoryEntry >> methodName [
	^methodName

]

{ #category : 'as yet unclassified' }
JadeAbstractHistoryEntry >> methodName: anObject [
	methodName := anObject
]

{ #category : 'as yet unclassified' }
JadeAbstractHistoryEntry >> printOn: target [


	target nextPutAll: ('aHistoryEntry ', self getClassName, '>>', self getMethodName)
]

Class {
	#name : 'JadeMethodExplorerHistoryEntry',
	#superclass : 'JadeAbstractHistoryEntry',
	#instVars : [
		'treeSelection',
		'methodCategory',
		'gsMethod'
	],
	#category : 'JadeiteMethodBrowser'
}

{ #category : 'as yet unclassified' }
JadeMethodExplorerHistoryEntry >> gsMethod [
	^gsMethod
]

{ #category : 'as yet unclassified' }
JadeMethodExplorerHistoryEntry >> gsMethod: anObject [
	gsMethod := anObject
]

{ #category : 'as yet unclassified' }
JadeMethodExplorerHistoryEntry >> methodCategory [
	^methodCategory
]

{ #category : 'as yet unclassified' }
JadeMethodExplorerHistoryEntry >> methodCategory: anObject [
	methodCategory := anObject
]

{ #category : 'as yet unclassified' }
JadeMethodExplorerHistoryEntry >> populateFrom: aJadeTreeMethodListPresenter [

	gsMethod := aJadeTreeMethodListPresenter selectedMethod.

	methodName := gsMethod name.
	className := gsMethod gsClass name.
	classCategory := gsMethod gsClass category.
	methodCategory := gsMethod category.

	treeSelection := aJadeTreeMethodListPresenter selectedExplorerNode.
]

{ #category : 'as yet unclassified' }
JadeMethodExplorerHistoryEntry >> treeSelection [
	^treeSelection
]

{ #category : 'as yet unclassified' }
JadeMethodExplorerHistoryEntry >> treeSelection: anObject [
	treeSelection := anObject
]

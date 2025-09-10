Class {
	#name : 'JadeiteClassCategoryTreeAdapter',
	#superclass : 'SpMorphicTreeAdapter',
	#category : 'Jadeite-SupportClasses',
	#package : 'Jadeite-SupportClasses'
}

{ #category : 'factory' }
JadeiteClassCategoryTreeAdapter >> basicSelectionChanged: ann [
	| selection |

	selection := self presenter selection.
	ann newSelectedIndexes ifEmpty: [ ^ selection unselectAll ].
	"(ann newSelectedIndexes difference: ann oldSelectedIndexes) ifEmpty: [ ^ self ]. JfP CHANGE. If you have multiple selections and select only one of those selections, a change event won't get triggered because difference is empty."

	selection selectPaths: (ann newSelectedIndexes
		collect: [ :index | self widget dataSource pathFromIndex: index ]).

	self presenter isActiveOnSingleClick ifTrue: [
		self presenter doActivateAtPath: selection selectedPath ]
]

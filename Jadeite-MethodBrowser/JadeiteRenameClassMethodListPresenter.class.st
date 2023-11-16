Class {
	#name : 'JadeiteRenameClassMethodListPresenter',
	#superclass : 'JadeiteMethodListPresenter',
	#instVars : [
		'findString',
		'newClassName'
	],
	#category : 'Jadeite-MethodBrowser'
}

{ #category : 'as yet unclassified' }
JadeiteRenameClassMethodListPresenter >> createComponents [
	methodListPresenter := self add: JadeiteBasicRenameClassMethodListPresenter new name: 'methodList'.
	methodSourcePresenter := (self add: JadeiteMethodSourcePresenter new name: 'methodSource')
				menuTitle: '&Method Source'.
	comparisonPresenter := self add: DifferencesPresenter new name: 'comparisonTab'
]

{ #category : 'as yet unclassified' }
JadeiteRenameClassMethodListPresenter >> createSchematicWiring [
	super createSchematicWiring.
	methodListPresenter methodListPresenter
		when: #selectionChanged
		send: #selectionChanged
		to: self
]

{ #category : 'as yet unclassified' }
JadeiteRenameClassMethodListPresenter >> findString: anObject [
	findString := anObject
]

{ #category : 'as yet unclassified' }
JadeiteRenameClassMethodListPresenter >> newClassName [
	^newClassName
]

{ #category : 'as yet unclassified' }
JadeiteRenameClassMethodListPresenter >> newClassName: anObject [
	newClassName := anObject
]

{ #category : 'as yet unclassified' }
JadeiteRenameClassMethodListPresenter >> nextSelection [
	| sourceView offset |
	sourceView := self methodSourcePresenter documentPresenter view.
	sourceView selectionRanges size > 1 ifTrue: [^self resetAndFindFirstIn: sourceView].
	self methodSourcePresenter documentPresenter view setFocus.
	offset := sourceView findString: findString startingAt: sourceView selectionRange start + 1.
	offset = 0
		ifTrue: 
			[methodListPresenter selection = methodListPresenter methodListPresenter list last
				ifTrue: 
					[sourceView isModified ifTrue: [methodSourcePresenter isOkayToChange ifFalse: [^self]].
					methodListPresenter methodListPresenter selectionByIndex: 1.
					^self resetAndFindFirstIn: sourceView].
			sourceView isModified ifTrue: [methodSourcePresenter isOkayToChange ifFalse: [^self]].
			methodListPresenter methodListPresenter
				selectionByIndex: methodListPresenter methodListPresenter selectionByIndex + 1.
			^self resetAndFindFirstIn: sourceView].
	sourceView selectionRange: (offset to: offset + findString size - 1)
]

{ #category : 'as yet unclassified' }
JadeiteRenameClassMethodListPresenter >> onViewOpened [

	super onViewOpened. 
	self registerPresentersForUpdates.
	self updateAutoCommitButton.
]

{ #category : 'as yet unclassified' }
JadeiteRenameClassMethodListPresenter >> previousSelection [
	| sourceView offset |
	sourceView := self methodSourcePresenter documentPresenter view.
	self methodSourcePresenter documentPresenter view setFocus.
	offset := sourceView findString: findString startingAt: 1.
	(offset = 0 or:[offset >= sourceView selectionRange start])
		ifTrue: 
			[methodListPresenter selection = methodListPresenter methodListPresenter list first
				ifTrue: 
					[sourceView isModified ifTrue: [methodSourcePresenter isOkayToChange ifFalse: [^self]].
					methodListPresenter methodListPresenter
						selectionByIndex: methodListPresenter methodListPresenter list size.
					^self resetAndFindLastIn: sourceView].
			sourceView isModified ifTrue: [methodSourcePresenter isOkayToChange ifFalse: [^self]].
			methodListPresenter methodListPresenter
				selectionByIndex: methodListPresenter methodListPresenter selectionByIndex - 1.
			^self resetAndFindLastIn: sourceView].
	sourceView selectionRange: (offset to: offset + findString size - 1)
]

{ #category : 'as yet unclassified' }
JadeiteRenameClassMethodListPresenter >> resetAndFindFirstIn: sourceView [
	| offset |
	sourceView selectionRange: (0 to: 0).
	offset := sourceView findString: findString startingAt: 1.
	sourceView selectionRange: (offset to: offset + findString size - 1).
	self methodSourcePresenter documentPresenter view setFocus.
	
]

{ #category : 'as yet unclassified' }
JadeiteRenameClassMethodListPresenter >> resetAndFindLastIn: sourceView [
	| offset  lastOffset |
	sourceView selectionRange: (0 to: 0).
	offset := 0.
	[offset := sourceView findString: findString startingAt: offset + 1.
	offset = 0] whileFalse: [lastOffset := offset].
	lastOffset ifNil:[^self].
	sourceView selectionRange: (lastOffset to: lastOffset + findString size - 1).
	self methodSourcePresenter documentPresenter view setFocus
]

{ #category : 'as yet unclassified' }
JadeiteRenameClassMethodListPresenter >> selectionChanged [
	| sourceView selectionRanges offset selection |
	findString ifNil: [^self].
	selection := methodListPresenter methodListPresenter selectionIfNone: [^self].
	findString := selection failedCompile ifTrue: [selection comparisonSource] ifFalse: [newClassName].
	sourceView := self methodSourcePresenter documentPresenter view.
	selectionRanges := OrderedCollection new.
	offset := 1.
	[(offset := sourceView model value findString: findString startingAt: offset + 1) = 0]
		whileFalse: [selectionRanges add: (offset to: offset + findString size - 1)].
	sourceView selectionRanges: selectionRanges.
	self showComparison
]

{ #category : 'as yet unclassified' }
JadeiteRenameClassMethodListPresenter >> showComparison [
	| selection |
	selection := methodListPresenter methodListPresenter selectionIfNone: [^self].
	selection failedCompile
		ifTrue: 
			[comparisonPresenter
				beforeTitle: 'Current Source';
				afterTitle: 'Proposed Source';
				compare: selection source
					with: (selection source copyReplaceAll: selection comparisonSource with: newClassName)]
		ifFalse: 
			[comparisonPresenter
				beforeTitle: 'Old Source';
				afterTitle: 'Current Source';
				compare: selection comparisonSource with: selection source]
]

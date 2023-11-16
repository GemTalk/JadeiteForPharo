Class {
	#name : 'JadeMethodHistoryBrowser',
	#superclass : 'JadeiteShell',
	#instVars : [
		'versionListPresenter',
		'editorPresenter'
	],
	#category : 'Jadeite-MethodBrowser'
}

{ #category : 'as yet unclassified' }
JadeMethodHistoryBrowser >> createComponents [

	super createComponents.
	versionListPresenter 	:= self add: ListPresenter	new name: 'versionList'.
	editorPresenter		:= self add: TextPresenter	new name: 'editor'.


]

{ #category : 'as yet unclassified' }
JadeMethodHistoryBrowser >> createSchematicWiring [

	super createSchematicWiring.
	versionListPresenter when: #'selectionChanged' send: #'fillMethodSource' to: self.

]

{ #category : 'as yet unclassified' }
JadeMethodHistoryBrowser >> fillMethodSource [

	editorPresenter value: (versionListPresenter selection at: 3).

]

{ #category : 'as yet unclassified' }
JadeMethodHistoryBrowser >> setContents: aReadStream [

	| versions | 
	versions := OrderedCollection new.
	[
		aReadStream atEnd not.
	] whileTrue: [
		| category timeStamp writeStream |
		category := aReadStream upTo: Character tab.
		timeStamp := aReadStream upTo: Character tab.
		writeStream := WriteStream on: String new.
		writeStream nextPutAll: aReadStream nextLine; lf.
		[
			aReadStream peekFor: $%.
		] whileFalse: [
			writeStream nextPutAll: aReadStream nextLine; lf.
		].
		aReadStream nextLine.
		versions add: (Array with: category with: timeStamp with: writeStream contents).
	].
	versionListPresenter 
		list: versions;
		selection: versions first;
		yourself.

]

{ #category : 'as yet unclassified' }
JadeMethodHistoryBrowser >> shellName [

	^'Jadeite Method History Browser'.

]

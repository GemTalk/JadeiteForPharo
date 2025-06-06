Class {
	#name : 'JadeiteTextEditorDialogWindow',
	#superclass : 'TextEditorDialogWindow',
	#instVars : [
		'completionBlock'
	],
	#category : 'Jadeite-SupportClasses',
	#package : 'Jadeite-SupportClasses'
}

{ #category : 'as yet unclassified' }
JadeiteTextEditorDialogWindow >> basicEntryText: anObject [

	entryText := anObject.
	self changed: #entryText.
	self textEditorMorph selectAll.
	self textEditorMorph hasUnacceptedEdits: true
]

{ #category : 'actions' }
JadeiteTextEditorDialogWindow >> cancel [

	self basicEntryText: nil.
	^ self close
]

{ #category : 'accessing' }
JadeiteTextEditorDialogWindow >> completionBlock [

	^ completionBlock
]

{ #category : 'accessing' }
JadeiteTextEditorDialogWindow >> completionBlock: anObject [

	completionBlock := anObject
]

{ #category : 'initialize' }
JadeiteTextEditorDialogWindow >> initialize [ 

	super initialize. 
	self textEditorMorph beWrapped.
]

{ #category : 'actions' }
JadeiteTextEditorDialogWindow >> ok [

	super ok.
	self completionBlock value: entryText
]

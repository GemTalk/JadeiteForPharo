Class {
	#name : 'JadeiteTextEditorDialogWindow',
	#superclass : 'TextEditorDialogWindow',
	#category : 'Jadeite-SupportClasses'
}

{ #category : 'initialize' }
JadeiteTextEditorDialogWindow >> initialize [ 

	super initialize. 
	self textEditorMorph beWrapped.
]

"
JadeiteConsole is the initial window opened after connecting to a GemStone server. 
The two tabs (so far) are a project list with project details and a server transcript. 
Column widths are sticky for convenience. 
"
Class {
	#name : 'JadeiteConsoleTableColumn',
	#superclass : 'SpStringTableColumn',
	#traits : 'SpTDecoratedText',
	#classTraits : 'SpTDecoratedText classTrait',
	#category : 'Jadeite-Console',
	#package : 'Jadeite-Console'
}

{ #category : 'api' }
JadeiteConsoleTableColumn >> width: aNumber [

	width := aNumber.
	JadeiteConsole setColumnWidths
]

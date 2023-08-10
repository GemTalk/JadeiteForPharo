Class {
	#name : 'FileStream',
	#superclass : 'Object',
	#category : 'JadeiteToolsSupportClasses'
}

{ #category : 'instance creation' }
FileStream class >> fileActionFor: aSymbol [

	^self fileStreamSymbolMapping at: aSymbol
]

{ #category : 'instance creation' }
FileStream class >> fileStreamSymbolMapping [
	"map dolphin file creation method symbols to pharo methods"

	^ Dictionary new
		  at: #append put: #openForAppend;
		  yourself
]

{ #category : 'instance creation' }
FileStream class >> write: fileName mode: aSymbol [

	^ (File named: fileName) perform: (self fileActionFor: aSymbol)
]

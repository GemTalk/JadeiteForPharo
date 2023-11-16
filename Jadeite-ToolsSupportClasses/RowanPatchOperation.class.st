Class {
	#name : 'RowanPatchOperation',
	#superclass : 'MCPatchOperation',
	#instVars : [
		'gciSession',
		'oopType'
	],
	#category : 'Jadeite-ToolsSupportClasses'
}

{ #category : 'instance creation' }
RowanPatchOperation class >> fromStream: aStream session: aGciSession [

	| char theClass |
	char := aStream next.
	aStream next.
	theClass := 
		char = $A ifTrue: [MCAddition] ifFalse: [
		char = $M ifTrue: [MCModification] ifFalse: [
		char = $R ifTrue: [MCRemoval] ifFalse: [
		self error: 'Invalid MCPatchOperation']]].
	^theClass new
		initialize: aStream
		session:  aGciSession.

]

{ #category : 'initialization' }
RowanPatchOperation >> initialize: aList [
	
]

{ #category : 'initialization' }
RowanPatchOperation >> initialize: aStream session: aGciSession [

	| string |
	gciSession := aGciSession.
	string := aStream upTo: Character tab.
	oopType := string asNumber.
	self initialize: aStream.  

]

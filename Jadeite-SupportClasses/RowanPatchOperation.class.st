Class {
	#name : 'RowanPatchOperation',
	#superclass : 'MCPatchOperation',
	#instVars : [
		'gciSession',
		'oopType',
		'reverted'
	],
	#category : 'Jadeite-SupportClasses',
	#package : 'Jadeite-SupportClasses'
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
RowanPatchOperation >> initialize [ 
	super initialize. 
	reverted := false. 
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

{ #category : 'accessing' }
RowanPatchOperation >> reverted [

	^ reverted
]

{ #category : 'accessing' }
RowanPatchOperation >> reverted: anObject [

	reverted := anObject
]

{ #category : 'acccessing' }
RowanPatchOperation >> typeString [
	"This browser is going away someday. Do ugly string parsing for now to make modifications that are reverted more visible"

	| typeString |
	typeString := self class name copyFrom: 3 to: self class name size.
	self reverted ifTrue: [typeString := typeString , ' ' , '(reverted)'].
	^typeString
]

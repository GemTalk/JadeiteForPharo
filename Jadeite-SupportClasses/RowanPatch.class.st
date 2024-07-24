Class {
	#name : 'RowanPatch',
	#superclass : 'MCPatch',
	#instVars : [
		'gciSession',
		'oopType',
		'name'
	],
	#category : 'Jadeite-SupportClasses',
	#package : 'Jadeite-SupportClasses'
}

{ #category : 'instance creation' }
RowanPatch class >> fromString: aString session: aGciSession [

	^self new 
		initialize: aString
		session:  aGciSession.

]

{ #category : 'accessing' }
RowanPatch >> gciSession [

	^gciSession
]

{ #category : 'accessing' }
RowanPatch >> gciSession: session [

	gciSession := session
]

{ #category : 'initialization' }
RowanPatch >> initialize: aString session: aGciSession [

	| stream list |
	stream := ReadStream on: aString.
	gciSession := aGciSession.
	list := stream nextLine subStrings: (Array with: Character tab). 
	oopType := (list at: 1) asNumber.
	name := list at: 2.
	operations := OrderedCollection new.
	[ stream atEnd ] whileFalse: [ 
		operations add:
			(RowanPatchOperation fromStream: stream session: aGciSession) ]
]

{ #category : 'accessing' }
RowanPatch >> operations: aCollection [ 

	operations := aCollection
]

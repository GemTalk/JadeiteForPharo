Class {
	#name : 'MockPage',
	#superclass : 'Object',
	#instVars : [
		'title'
	],
	#category : 'Jadeite-Tests',
	#package : 'Jadeite-Tests'
}

{ #category : 'initialization' }
MockPage >> initialize [

	title := 'title not updated'
]

{ #category : 'accessing' }
MockPage >> owner: anObject [
]

{ #category : 'accessing' }
MockPage >> title [

	^ title
]

{ #category : 'accessing' }
MockPage >> title: anObject [

	title := anObject
]

{ #category : 'private - updating' }
MockPage >> updateTitle [

	title := 'title updated'
]

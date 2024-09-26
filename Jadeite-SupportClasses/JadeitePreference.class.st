Class {
	#name : 'JadeitePreference',
	#superclass : 'Object',
	#instVars : [
		'preference',
		'action',
		'value'
	],
	#category : 'Jadeite-SupportClasses',
	#package : 'Jadeite-SupportClasses'
}

{ #category : 'instance creation' }
JadeitePreference class >> for: aSymbol [

	| inst |
	inst := self new. 
	inst preference: aSymbol. 
	^inst
]

{ #category : 'accessing' }
JadeitePreference >> action [

	^ action
]

{ #category : 'accessing' }
JadeitePreference >> action: anObject [

	action := anObject
]

{ #category : 'private' }
JadeitePreference >> apply [ 

	action value: value
]

{ #category : 'accessing' }
JadeitePreference >> preference [

	^ preference
]

{ #category : 'accessing' }
JadeitePreference >> preference: anObject [

	preference := anObject
]

{ #category : 'accessing' }
JadeitePreference >> value [

	^ value
]

{ #category : 'accessing' }
JadeitePreference >> value: anObject [

	value := anObject
]

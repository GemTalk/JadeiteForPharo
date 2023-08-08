Class {
	#name : 'JadeiteConnectionProfile',
	#superclass : 'Object',
	#instVars : [
		'host',
		'connection'
	],
	#category : 'JadeiteConnection'
}

{ #category : 'accessing' }
JadeiteConnectionProfile >> connection [

	^ connection
]

{ #category : 'accessing' }
JadeiteConnectionProfile >> connection: anObject [

	connection := anObject
]

{ #category : 'accessing' }
JadeiteConnectionProfile >> host [

	^ host
]

{ #category : 'accessing' }
JadeiteConnectionProfile >> host: anObject [

	host := anObject
]

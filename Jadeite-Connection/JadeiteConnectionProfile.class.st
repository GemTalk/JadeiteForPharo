Class {
	#name : 'JadeiteConnectionProfile',
	#superclass : 'Object',
	#traits : 'TObservable',
	#classTraits : 'TObservable classTrait',
	#instVars : [
		'#host => ObservableSlot',
		'#connection => ObservableSlot'
	],
	#classVars : [
		'#ConnectionProfile'
	],
	#category : 'Jadeite-Connection'
}

{ #category : 'accessing' }
JadeiteConnectionProfile class >> connectionProfile [

	ConnectionProfile ifNil: [
		ConnectionProfile := JadeiteGCIConnectionProfile new ].
	^ ConnectionProfile
]

{ #category : 'accessing' }
JadeiteConnectionProfile class >> connectionProfile: anObject [

	ConnectionProfile := anObject
]

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

{ #category : 'initialization' }
JadeiteConnectionProfile >> initialize [

	self class initializeSlots: self.
	super initialize.
]

{ #category : 'testing' }
JadeiteConnectionProfile >> isGciConnection [

	^false
]

{ #category : 'events' }
JadeiteConnectionProfile >> whenConnectionChangedDo: aBlock [

	self property: #connection whenChangedDo: aBlock
]

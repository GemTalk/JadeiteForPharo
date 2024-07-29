Class {
	#name : 'JadeiteConnectionProfile',
	#superclass : 'Object',
	#traits : 'TObservable',
	#classTraits : 'TObservable classTrait',
	#instVars : [
		'#host => ObservableSlot',
		'#connection => ObservableSlot',
		'#jadeiteWindows'
	],
	#classVars : [
		'#ConnectionProfile'
	],
	#category : 'Jadeite-Connection',
	#package : 'Jadeite-Connection'
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
	jadeiteWindows := OrderedCollection new. 
]

{ #category : 'testing' }
JadeiteConnectionProfile >> isGciConnection [

	^false
]

{ #category : 'accessing' }
JadeiteConnectionProfile >> jadeiteWindows [

	jadeiteWindows ifNil: [ jadeiteWindows := OrderedCollection new ].
	^ jadeiteWindows
]

{ #category : 'accessing' }
JadeiteConnectionProfile >> jadeiteWindows: anObject [

	jadeiteWindows := anObject
]

{ #category : 'events' }
JadeiteConnectionProfile >> whenConnectionChangedDo: aBlock [

	self property: #connection whenChangedDo: aBlock
]

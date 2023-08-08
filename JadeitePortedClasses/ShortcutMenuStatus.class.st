Class {
	#name : 'ShortcutMenuStatus',
	#superclass : 'Notification',
	#classVars : [
		'Status'
	],
	#category : 'JadeitePortedClasses'
}

{ #category : 'public' }
ShortcutMenuStatus class >> isClosed [

	^Status = #'stop'
]

{ #category : 'public' }
ShortcutMenuStatus class >> isOpen [

	^Status = #'start'
]

{ #category : 'public' }
ShortcutMenuStatus class >> reset [

	self signalWith: nil.

]

{ #category : 'public' }
ShortcutMenuStatus class >> start [

	self signalWith: #'start'.

]

{ #category : 'public' }
ShortcutMenuStatus class >> status [

	^Status

]

{ #category : 'public' }
ShortcutMenuStatus class >> stop [

	self signalWith: #'stop'.

]

{ #category : 'public' }
ShortcutMenuStatus >> defaultAction [

	Status := tag.

]

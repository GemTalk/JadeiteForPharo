"
Don't expect to have a session for things like the caption
"
Class {
	#name : 'JadeiteNonSessionWorkspace',
	#superclass : 'JadeiteTextDocument',
	#category : 'Jadeite-TextPanes'
}

{ #category : 'initialization' }
JadeiteNonSessionWorkspace >> initializeFileMenu [

	^ self newMenu
]

{ #category : 'initialization' }
JadeiteNonSessionWorkspace >> setCaption: aString [

	self caption: aString
]

{ #category : 'initialization' }
JadeiteNonSessionWorkspace >> updateCaption [

	self caption: 'Jadeite Non-Session Workspace'.
]

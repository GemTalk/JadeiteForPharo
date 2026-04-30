"
JadeiteAIChatMessage — immutable value object representing a single turn in a conversation.
role: #user | #assistant | #system
"
Class {
	#name : 'JadeiteAIChatMessage',
	#superclass : 'Object',
	#instVars : [
		'role',
		'content',
		'timestamp'
	],
	#category : 'Jadeite-AI',
	#package : 'Jadeite-AI'
}

{ #category : 'instance creation' }
JadeiteAIChatMessage class >> role: aSymbol content: aString [

	^ self new
		  role: aSymbol;
		  content: aString;
		  timestamp: DateAndTime now;
		  yourself
]

{ #category : 'accessing' }
JadeiteAIChatMessage >> content [

	^ content
]

{ #category : 'accessing' }
JadeiteAIChatMessage >> content: aString [

	content := aString
]

{ #category : 'displaying' }
JadeiteAIChatMessage >> displayPrefix [

	role = #user ifTrue: [ ^ 'You' ].
	role = #assistant ifTrue: [ ^ 'AI' ].
	^ 'System'
]

{ #category : 'displaying' }
JadeiteAIChatMessage >> displayString [

	^ '[' , self displayPrefix , '] ' , content
]

{ #category : 'accessing' }
JadeiteAIChatMessage >> role [

	^ role
]

{ #category : 'accessing' }
JadeiteAIChatMessage >> role: aSymbol [

	role := aSymbol
]

{ #category : 'accessing' }
JadeiteAIChatMessage >> timestamp [

	^ timestamp
]

{ #category : 'accessing' }
JadeiteAIChatMessage >> timestamp: aDateAndTime [

	timestamp := aDateAndTime
]

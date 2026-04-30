"
JAIChatMessage — immutable value object representing a single turn in a conversation.
role: #user | #assistant | #system
"
Class {
	#name : 'JAIChatMessage',
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
JAIChatMessage class >> role: aSymbol content: aString [

	^ self new
		  role: aSymbol;
		  content: aString;
		  timestamp: DateAndTime now;
		  yourself
]

{ #category : 'accessing' }
JAIChatMessage >> content [

	^ content
]

{ #category : 'accessing' }
JAIChatMessage >> content: aString [

	content := aString
]

{ #category : 'displaying' }
JAIChatMessage >> displayPrefix [

	role = #user ifTrue: [ ^ 'You' ].
	role = #assistant ifTrue: [ ^ 'AI' ].
	^ 'System'
]

{ #category : 'displaying' }
JAIChatMessage >> displayString [

	^ '[' , self displayPrefix , '] ' , content
]

{ #category : 'accessing' }
JAIChatMessage >> role [

	^ role
]

{ #category : 'accessing' }
JAIChatMessage >> role: aSymbol [

	role := aSymbol
]

{ #category : 'accessing' }
JAIChatMessage >> timestamp [

	^ timestamp
]

{ #category : 'accessing' }
JAIChatMessage >> timestamp: aDateAndTime [

	timestamp := aDateAndTime
]

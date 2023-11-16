Class {
	#name : 'JadeiteCodeDebugItCommand',
	#superclass : 'SpToolCommand',
	#category : 'Jadeite-Debugger'
}

{ #category : 'default' }
JadeiteCodeDebugItCommand class >> defaultDescription [

	^ 'Debug selection.'
]

{ #category : 'default' }
JadeiteCodeDebugItCommand class >> defaultIconName [

	^ #smallDebug
]

{ #category : 'default' }
JadeiteCodeDebugItCommand class >> defaultName [ 

	^ 'Debug it'
]

{ #category : 'default' }
JadeiteCodeDebugItCommand class >> defaultShortcutKey [

	^ $d shift command mac 
		| $d shift control win
		| $d shift control unix
]

{ #category : 'private' }
JadeiteCodeDebugItCommand >> debug: aStream [
	^self context executeSelectionOrLine: aStream contents shouldDebug: true onCompileError:[^self]
]

{ #category : 'executing' }
JadeiteCodeDebugItCommand >> execute [
	| selection |

	selection := self selectedTextOrLine.
	selection ifEmpty: [ ^ '' ].
	
	self debug: selection readStream
]

{ #category : 'executing' }
JadeiteCodeDebugItCommand >> selectedTextOrLine [

	^ self context selectedTextOrLine
]

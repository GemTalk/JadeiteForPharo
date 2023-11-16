Class {
	#name : 'MessageBox',
	#superclass : 'DolphinClass',
	#category : 'JadeiteToolsSupportClasses'
}

{ #category : 'pharo specific layer' }
MessageBox class >> confirm: aString [

	^UIManager default confirm: aString
]

{ #category : 'pharo specific layer' }
MessageBox class >> confirm: aString caption: ignore [

	^self confirm: aString
]

{ #category : 'pharo specific layer' }
MessageBox class >> notify: aString [

	^UIManager default inform: aString
]

{ #category : 'pharo specific layer' }
MessageBox class >> warning: aString [

	^UIManager default alert: aString
]

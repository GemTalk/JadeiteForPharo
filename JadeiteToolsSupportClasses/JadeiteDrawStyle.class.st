Class {
	#name : 'JadeiteDrawStyle',
	#superclass : 'SpDrawStyle',
	#category : 'JadeiteToolsSupportClasses'
}

{ #category : 'operations' }
JadeiteDrawStyle >> applyTo: aMorph [
	"overriden so we don't send #backgroundColor: which blocks the change indicator 
	in a text morph"

	self color ifNotNil: [ :aColor |
		(aMorph respondsTo: #barFillStyle:)
			ifTrue: [ aMorph barFillStyle: aColor asStyleVariable valueAsColor ]
			ifFalse: [ aMorph color: aColor asStyleVariable valueAsColor ] ].
	self backgroundColor ifNotNil: [ :aColor |
		aMorph fillStyle: aColor asStyleVariable valueAsColor]
]

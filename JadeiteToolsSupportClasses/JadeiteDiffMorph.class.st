Class {
	#name : 'JadeiteDiffMorph',
	#superclass : 'DiffMorph',
	#category : 'JadeiteToolsSupportClasses'
}

{ #category : 'initialization' }
JadeiteDiffMorph >> initialize [
	"Initialize the receiver."

	super initialize.
	self srcMorph textArea newJadeiteEditor.
	self dstMorph textArea newJadeiteEditor
]

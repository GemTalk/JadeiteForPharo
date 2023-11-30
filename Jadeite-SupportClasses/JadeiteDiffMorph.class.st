Class {
	#name : 'JadeiteDiffMorph',
	#superclass : 'DiffMorph',
	#category : 'Jadeite-SupportClasses'
}

{ #category : 'initialization' }
JadeiteDiffMorph >> initialize [
	"Initialize the receiver."

	super initialize.
	self srcMorph textArea newJadeiteEditor.
	self dstMorph textArea newJadeiteEditor
]

Class {
	#name : 'JadeiteServerFileSaveTestDialog',
	#superclass : 'JadeiteServerFileSaveDialog',
	#category : 'Jadeite-FileDialog',
	#package : 'Jadeite-FileDialog'
}

{ #category : 'instance creation' }
JadeiteServerFileSaveTestDialog class >> showOnSession: aGciSession defaultPath: path defaultFileName: fileName [
	"same as super, but return the dialog for testing"
	| inst modal answer expandedPath |
	(ProvideAnswerNotification signal: path) ifNotNil: [ :theAnswer |
		^ theAnswer ].
	inst := self createDialogOn: aGciSession path: path.
	expandedPath := inst fileSelectorPresenter pathText text. 
	modal := (inst application: JadeiteSpApplication new) asModalWindow.
	modal centered.
	inst initializeWith: expandedPath fileName: fileName.
	answer := modal open. "open non-modal"
	^ inst
]

{ #category : 'defaults' }
JadeiteServerFileSaveTestDialog >> defaultModalWindowPresenterClass [

	^JadeiteTestModalWindowPresenter 
]

{ #category : 'as yet unclassified' }
JadeiteServerFileSaveTestDialog >> showModal [
	^self show
]

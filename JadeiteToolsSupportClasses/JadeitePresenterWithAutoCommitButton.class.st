Class {
	#name : 'JadeitePresenterWithAutoCommitButton',
	#superclass : 'JadeitePresenter',
	#instVars : [
		'autoCommitButton'
	],
	#category : 'JadeiteToolsSupportClasses'
}

{ #category : 'accessing' }
JadeitePresenterWithAutoCommitButton >> autoCommitButton [
	"for testing"
	^ autoCommitButton
]

{ #category : 'autocommit' }
JadeitePresenterWithAutoCommitButton >> flipAutoCommit [
	self gciSession flipAutoCommit
]

{ #category : 'autocommit' }
JadeitePresenterWithAutoCommitButton >> initializeAutoCommitPresenter [

	| autoCommitBox |
	autoCommitBox := SpBoxLayout newHorizontal.
	autoCommitButton := SpButtonPresenter new.
	autoCommitButton action: [ self flipAutoCommit ].
	autoCommitBox
		add: autoCommitButton
		withConstraints: [ :constraints | 
			constraints
				height: 25;
				width: 150 ].
	self layout add: autoCommitBox expand: false
]

{ #category : 'autocommit' }
JadeitePresenterWithAutoCommitButton >> redrawAutoCommitButton [

	autoCommitButton withAdapterDo: [ :a |
		a widgetDo: [ :w | w changed ] ]
]

{ #category : 'autocommit' }
JadeitePresenterWithAutoCommitButton >> updateAutoCommitButton [

	self gciSession autoCommit value == #failed ifTrue: [
		autoCommitButton label: 'Auto Commit - failed'.
		^ autoCommitButton color: Color red ].
	self gciSession autoCommit value
		ifTrue: [
			autoCommitButton color: Color green.
			autoCommitButton label: 'Auto Commit - true' ]
		ifFalse: [
			autoCommitButton color: autoCommitButton defaultColor.
			autoCommitButton label: 'Auto Commit - false' ].
	self redrawAutoCommitButton
]

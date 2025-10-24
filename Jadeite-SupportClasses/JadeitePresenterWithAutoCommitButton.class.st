Class {
	#name : 'JadeitePresenterWithAutoCommitButton',
	#superclass : 'JadeiteSessionPresenter',
	#instVars : [
		'autoCommitButton',
		'autoCommitBox'
	],
	#category : 'Jadeite-SupportClasses',
	#package : 'Jadeite-SupportClasses'
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

	autoCommitBox := SpBoxLayout newHorizontal.
	autoCommitButton := SpButtonPresenter new.
	autoCommitButton action: [ self flipAutoCommit ].
	autoCommitBox
		add: autoCommitButton
		withConstraints: [ :constraints |
			constraints
				height: 3 * StandardFonts defaultFont pointSize;
				width: 20 * StandardFonts defaultFont pointSize ].
	self layout add: autoCommitBox expand: false
]

{ #category : 'autocommit' }
JadeitePresenterWithAutoCommitButton >> redrawAutoCommitButton [

	autoCommitButton withAdapterDo: [ :a |
		a widgetDo: [ :w | w changed ] ]
]

{ #category : 'autocommit' }
JadeitePresenterWithAutoCommitButton >> updateAutoCommitButton [

	| widget |
	self uiManager defer: [
			widget := autoCommitButton withAdapterDo: [ :a | a widget ].
			self gciSession autoCommit value == #failed
				ifTrue: [
						autoCommitButton label: 'Auto Commit - failed'.
						autoCommitButton color: Color red ]
				ifFalse: [
						self gciSession autoCommit value
							ifTrue: [
									autoCommitButton color: Color green.
									autoCommitButton label: 'Auto Commit - true'.
									widget ifNotNil: [ :w | w labelMorph textColor: Color black ] ]
							ifFalse: [
									autoCommitButton color: autoCommitButton defaultColor.
									autoCommitButton label: 'Auto Commit - false'.
									PharoDarkTheme isCurrent ifTrue: [
										widget ifNotNil: [ :w | w labelMorph textColor: Color white ] ] ].
						self redrawAutoCommitButton ] ]
]

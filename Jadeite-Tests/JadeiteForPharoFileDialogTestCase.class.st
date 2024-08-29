Class {
	#name : 'JadeiteForPharoFileDialogTestCase',
	#superclass : 'JadeiteForPharoGUITestCase',
	#instVars : [
		'fileDialog'
	],
	#category : 'Jadeite-Tests',
	#package : 'Jadeite-Tests'
}

{ #category : 'support' }
JadeiteForPharoFileDialogTestCase >> setUp [

	super setUp.
	fileDialog := JadeiteServerFileSelectorDialog
		              _showOnSession: GciSession current
		              defaultPath:
		              JadePresenter rowanProjectsHomeEnvVarString
		              shellName: nil
]

{ #category : 'support' }
JadeiteForPharoFileDialogTestCase >> tearDown [

	super tearDown.
	self destroy: fileDialog
]

{ #category : 'support' }
JadeiteForPharoFileDialogTestCase >> test_dive [
	"the default directory is $ROWAN_PROJECTS_HOME
	so we know that JadeiteForPharo directory will be there."

	| presenter item keys |
	presenter := fileDialog fileSelectorPresenter.
	item := presenter directoryContentsList list detect: [ :assoc |
		        assoc key = 'JadeiteForPharo' ].
	presenter directoryContentsList selectItem: item.
	self assert: presenter pathText text equals: '$ROWAN_PROJECTS_HOME'.
	keys := presenter directoryContentsList list collect: [ :assoc |
		        assoc key ].
	self deny: (keys includes: 'Jadeite-Browser').
	presenter dive.
	self
		assert: presenter pathText text
		equals: '$ROWAN_PROJECTS_HOME/JadeiteForPharo'.
	keys := presenter directoryContentsList list collect: [ :assoc |
		        assoc key ].
	self assert: (keys includes: 'Jadeite-Browser').
	presenter pop.
	presenter directoryContentsList selectItem: item.
	presenter directoryContentsList doActivateAtIndex:
		presenter directoryContentsList selection selectedIndex.
	keys := presenter directoryContentsList list collect: [ :assoc |
		        assoc key ].
	self assert: (keys includes: 'Jadeite-Browser')
]

"
Simple command that will count Jadeite For Pharo tests. 
"
Class {
	#name : 'JadeiteTestCountCommand',
	#superclass : 'ClyShowClassRefCommand',
	#category : 'Jadeite-Tests',
	#package : 'Jadeite-Tests'
}

{ #category : 'testing' }
JadeiteTestCountCommand class >> canBeExecutedInContext: aToolContext [

	aToolContext isClassSelected ifFalse: [ ^ false ].
	(aToolContext class canUnderstand: #selectedClassItems) ifFalse: [
		^ false ].
	^ aToolContext selectedClassItems allSatisfy: [ :item |
		  item actualObject = JadeiteForPharoTestCase or: [
			  item actualObject allSuperclasses includes:
				  JadeiteForPharoGUITestCase ] ]
]

{ #category : 'activation' }
JadeiteTestCountCommand class >> fullBrowserMenuActivation [
	<classAnnotation>

	^CmdContextMenuActivation byItemOf: CmdExtraMenuGroup for: ClyFullBrowserClassContext
]

{ #category : 'activation' }
JadeiteTestCountCommand class >> queryBrowserMenuActivation [
	<classAnnotation>

	^CmdContextMenuActivation byItemOf: CmdExtraMenuGroup for: ClyQueryBrowserContext
]

{ #category : 'activation' }
JadeiteTestCountCommand class >> sourceCodeMenuActivation [
	<classAnnotation>

	^SycSourceCodeMenuActivation byItemOf: CmdExtraMenuGroup for: ClySourceCodeContext
]

{ #category : 'accessing' }
JadeiteTestCountCommand >> defaultMenuItemName [
	^'Jadeite Test Count'
]

{ #category : 'execution' }
JadeiteTestCountCommand >> execute [

	| total |
	total := 0.
	classes do: [ :theClass |
		total := total + theClass testCount.
		theClass allSubclassesDo: [ :sub | total := total + sub testCount ] ].
	'======================' traceCr.
	('Total test count - ' , total printString) traceCr.
	'======================' traceCr.
	MessageBox notify: 'Total test count - ' , total printString , '
Check transcript for details'
]

Class {
	#name : 'JadeiteTestCodeCoverageCommand',
	#superclass : 'ClyShowClassRefCommand',
	#category : 'Jadeite-Tests',
	#package : 'Jadeite-Tests'
}

{ #category : 'testing' }
JadeiteTestCodeCoverageCommand class >> canBeExecutedInContext: aToolContext [

	aToolContext isClassSelected ifFalse: [ ^ false ].
	(aToolContext class canUnderstand: #selectedClassItems) ifFalse: [
		^ false ].
	^ aToolContext selectedClassItems allSatisfy: [ :item |
		  item actualObject = JadeiteForPharoTestCase or: [
			  item actualObject allSuperclasses includes:
				  JadeiteForPharoGUITestCase ] ]
]

{ #category : 'activation' }
JadeiteTestCodeCoverageCommand class >> fullBrowserMenuActivation [
	<classAnnotation>

	^CmdContextMenuActivation byItemOf: CmdExtraMenuGroup for: ClyFullBrowserClassContext
]

{ #category : 'activation' }
JadeiteTestCodeCoverageCommand class >> fullBrowserShortcutActivation [
]

{ #category : 'activation' }
JadeiteTestCodeCoverageCommand class >> queryBrowserMenuActivation [
	<classAnnotation>

	^CmdContextMenuActivation byItemOf: CmdExtraMenuGroup for: ClyQueryBrowserContext
]

{ #category : 'activation' }
JadeiteTestCodeCoverageCommand class >> sourceCodeMenuActivation [
	<classAnnotation>

	^SycSourceCodeMenuActivation byItemOf: CmdExtraMenuGroup for: ClySourceCodeContext
]

{ #category : 'accessing' }
JadeiteTestCodeCoverageCommand >> defaultMenuItemName [
	^'Jadeite Run Test Class With Coverage'
]

{ #category : 'execution' }
JadeiteTestCodeCoverageCommand >> execute [

	| collector coverage methods |
	methods := OrderedCollection new.
	collector := CoverageCollector new.
	classes do: [ :theClass |
		(theClass class includesSelector: #codeCoverageClasses) ifFalse: [
			^ UIManager default alert: theClass printString
				  , 'needs to define a class method, #codeCoverageClasses' ].
		methods addAll: theClass codeCoverageMethods ].
	collector methods: methods.
	Cursor wait showWhile: [
		coverage := collector runOn: [
			            classes do: [ :theClass |
				            theClass suite run: TestResult new ] ].
		ClyQueryBrowserMorph openOn: ((ClyConstantMethodQuery
				  named: 'Uncovered Methods for '
					  , (classes collect: [ :ea | ea name ]) printString
				  with: coverage uncoveredMethods) scope: (ClyClassScope
					  ofAll: (Smalltalk globals allClasses select: [ :ea |
							   'Jadeite-*' match: ea package name ])
					  in: ClyNavigationEnvironment currentImage)) ]
]

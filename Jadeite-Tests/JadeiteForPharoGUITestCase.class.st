"
This class contains tests for Jadeite for Pharo that (presumably) should pass. 

Other tests in the JadeiteAbstractTestCase hierarchy were ported from Jadeite for Dolphin and are not known to work in pharo yet. 
"
Class {
	#name : 'JadeiteForPharoGUITestCase',
	#superclass : 'JadeiteForPharoTestCase',
	#instVars : [
		'workspace',
		'methodListBrowser',
		'progressBarState',
		'fileOperationSemaphore',
		'preferredExtent'
	],
	#category : 'Jadeite-Tests',
	#package : 'Jadeite-Tests'
}

{ #category : 'as yet unclassified' }
JadeiteForPharoGUITestCase class >> isAbstract [ 
	^ self name = #JadeiteForPharoGUITestCase 
]

{ #category : 'support' }
JadeiteForPharoGUITestCase >> assertAlertDialogProvideAnswerTextMatches: aString [
	"alert dialogs can be modal and raised in the morphic gui thread
	making testing a problem.  The JadeiteTestManager provides a 
	ProvideAnswerNotification that we can handle to verify if the 
	message that would have been presented in the dialog is more
	or less what we expect"

	| dialogs count |
	count := 0.
	[
		(dialogs := self currentWorld windowsSatisfying: [ :each |
			            each isKindOf: AlertDialogWindow ]) isEmpty and: [
			count < 10 ] ] whileTrue: [
			count := count + 1.
			(Delay forMilliseconds: 10) wait.
			[ WorldMorph doOneCycle ]
				on: ProvideAnswerNotification
				do: [ :ex | ^ self assert: ('*RSR Error*' match: ex messageText) ] ].
	self error: 'ProvideAnswerNotification not signaled'
]

{ #category : 'support' }
JadeiteForPharoGUITestCase >> assertTextPaneResetFor: presenter [

	| text |
	self
		testsJadeiteForPharoIssue: #issue290
		title:
		'In a method source pane, menu item Cancel and Ctrl-L do different things'
		url: 'https://github.com/GemTalk/JadeiteForPharo/issues/290'.
	text := presenter text.
	presenter adapter widget setText: 'changed the text!' replaceCrWithLf.
	self
		assert: presenter adapter widget text
		equals: 'changed the text!'.

	"cancel using Ctrl-L"
	presenter adapter widget textArea dispatchKeystrokeForEvent: (self
			 simulatedKeyStrokeFromChar: $l
			 alt: false
			 ctrl: true
			 command: false
			 shift: false).
	WorldMorph doOneCycle.
	self assert: presenter text equals: text.
	presenter adapter widget setText: 'changed the text with menu item!'.
	WorldMorph doOneCycle.
	self
		assert: presenter adapter widget text
		equals: 'changed the text with menu item!'.

	"cancel using menu item"
	(SpCancelChangesCommand forContext: presenter) execute.
	WorldMorph doOneCycle.
	self assert: presenter text equals: text
]

{ #category : 'support' }
JadeiteForPharoGUITestCase >> classCategoryServices [

	^ self classCategoryPresenter adapter widget dataSource allShownItems
		  collect: [ :service | service data ]
]

{ #category : 'constants' }
JadeiteForPharoGUITestCase >> compileErrorMethodText [

	^'hasCompileErrorInText
	
	| coll |
	coll := Array with: 1 with: 2. 
	coll do: [ :int |
		"missing right bracket".
	^coll'
]

{ #category : 'constants' }
JadeiteForPharoGUITestCase >> compileErrorMethodTextShowingCompileError [

	^ 'hasCompileErrorInText
	
	| coll |
	coll := Array with: 1 with: 2. 
	coll do: [ :int |
		"missing right bracket" expected a right bracket (]).
	^coll'
]

{ #category : 'support' }
JadeiteForPharoGUITestCase >> dismissPopoverAndPrint [

	SpCodePopoverPrintPresenter allInstances do: [ :popup |
		popup dismissAndPrint ].
	JadeitePopoverPrintPresenter allInstances do: [ :popup |
		popup dismissAndPrint ]
]

{ #category : 'support' }
JadeiteForPharoGUITestCase >> displayAndPrint [

	workspace codePane jadeDisplay.
	self dismissPopoverAndPrint
]

{ #category : 'support' }
JadeiteForPharoGUITestCase >> ensureConnectionProfileEstablished [

	self ensureLauncherOpened.
	JadeiteConnectionLauncher soleInstance presenter basicImportProfile:
		self jadeiteTestResourceClass current testConnectionProfile
]

{ #category : 'support' }
JadeiteForPharoGUITestCase >> ensureLauncherOpened [
	"make sure we only have one launcher per tests that require it"

	| launchers |
	launchers := JadeiteConnectionLauncher allInstances select: [
		             :theLauncher |
		             theLauncher window notNil and: [
			             theLauncher window isOpen ] ].
	launchers do: [ :launcher |
			launcher isConnected ifTrue: [ launcher disconnect ].
			launcher window close ].
	JadeiteConnectionLauncher soleInstance ifNil: [
		JadeiteConnectionApplication singleton start ]
]

{ #category : 'support' }
JadeiteForPharoGUITestCase >> fileOperationComplete [

	fileOperationSemaphore signal
]

{ #category : 'support' }
JadeiteForPharoGUITestCase >> jfpwor_classDefinitionFor: className superclass: superName instVars: instVars category: aString [

	self
		jfpwor_saveClass: className
		superclass: instVars
		instVars: aString
		package: superName.
	^ self projectsPresenter editSaveClass
]

{ #category : 'accessing' }
JadeiteForPharoGUITestCase >> preferredExtent [

	^ preferredExtent
]

{ #category : 'accessing' }
JadeiteForPharoGUITestCase >> preferredExtent: anObject [

	preferredExtent := anObject
]

{ #category : 'support' }
JadeiteForPharoGUITestCase >> registerForFileOperationAnnouncements [

	fileOperationSemaphore := RowanSemaphore new.
	GciSession current announcer
		when: JadeiteFileOperationCompleted
		send: #fileOperationComplete
		to: self
]

{ #category : 'support' }
JadeiteForPharoGUITestCase >> selectClassCategoryNamed: name [

	| services service |
	services := self classCategoryServices.
	service := services detect: [ :classCategoryService |
		           classCategoryService name = name ].
	self classCategoryPresenter selectItem: service
]

{ #category : 'support' }
JadeiteForPharoGUITestCase >> selectRowanAnsweringService [

	self selectRowanClientServicesDictionaryOrPackage.
	self
		selectServiceNamed: 'RowanAnsweringService'
		in: self classListPresenter
]

{ #category : 'support' }
JadeiteForPharoGUITestCase >> selectRowanClientServicesDictionaryOrPackage [

	JadeitePreferences isRowanLoaded
		ifTrue: [
			self
				selectServiceNamed: 'RowanClientServices'
				in: self projectListPresenter.
			self
				selectServiceNamed: 'Rowan-Services-Core'
				in: self packageListPresenter ]
		ifFalse: [
			self
				selectServiceNamed: 'RowanClientServices'
				in: self dictionaryListPresenter.
			self classCategoryPresenter selectItem:
				(RowanClassCategoryService new
					 name: 'Rowan';
					 substringIndex: 1;
					 yourself) ]
]

{ #category : 'support' }
JadeiteForPharoGUITestCase >> selectRowanDictionaryOrPackage [

	JadeitePreferences isRowanLoaded
		ifTrue: [
		self selectServiceNamed: 'Rowan' in: self projectListPresenter ]
		ifFalse: [
		self selectServiceNamed: 'Rowan' in: self dictionaryListPresenter ]
]

{ #category : 'support' }
JadeiteForPharoGUITestCase >> setUp [

	self ensureConnectionProfileEstablished.
	super setUp
]

{ #category : 'utilities' }
JadeiteForPharoGUITestCase >> simulatedKeyStrokeFromChar: aCharacter [

	^ self simulatedKeyStrokeFromChar: aCharacter alt: false ctrl: false command: false shift: false
]

{ #category : 'utilities' }
JadeiteForPharoGUITestCase >> simulatedKeyStrokeFromChar: aCharacter alt: useAlt ctrl: useCtrl command: useCommand shift: useShift [
	| event modifier code |
	event := KeyboardEvent new.
	modifier := 0.
	useShift
		ifTrue: [ modifier := modifier + 8 ].
	useCtrl
		ifTrue: [ modifier := modifier + 16 ].
	useAlt
		ifTrue: [ modifier := modifier + 32 ].
	useCommand
		ifTrue: [ modifier := modifier + 64 ].
	code := aCharacter asInteger.
	event
		setType: #keystroke
		buttons: modifier
		position: 0 @ 0
		keyValue: code
		charCode: code
		hand: self currentWorld currentHand
		stamp: Time now.
	^ event
]

{ #category : 'support' }
JadeiteForPharoGUITestCase >> tearDown [

	super tearDown.
	workspace ifNotNil: [
		workspace isModified: false.
		self destroy: workspace ].
	self destroy: methodListBrowser.
]

{ #category : 'tests' }
JadeiteForPharoGUITestCase >> test_openBrowser [
	"verify toolbar button works"

	| browser |
	self toolUsedForCommonTests ifNil: [
		^ self skip:
			  'Only subclasses that define toolTested can run this test. Classes testing tools have a tool bar that can open a browser' ].
	browser := self toolUsedForCommonTests openBrowser.
	[ self assert: (browser isKindOf: JadeiteBrowser) ] ensure: [
		self destroy: browser ]
]

{ #category : 'tests' }
JadeiteForPharoGUITestCase >> test_windowTitleShowsUser [

	| sem proc |
	self toolUsedForCommonTests ifNil: [
			^ self skip:
				  'Only subclasses that define toolTested can run this test' ].
	sem := Semaphore new.
	[
		proc := [
			        self toolUsedForCommonTests window notNil and: [
				        self toolUsedForCommonTests window isOpen ] ] whileFalse: [
			        (Delay forMilliseconds: 10) wait ].
		sem signal ] fork.
	sem
		waitTimeoutSeconds: 5
		onCompletion: [
				self assert: ('*for ' , self userId , '*' match:
						 self toolUsedForCommonTests window title) ]
		onTimeout: [ proc terminate ]
]

{ #category : 'tests' }
JadeiteForPharoGUITestCase >> toolUsedForCommonTests [
	"if a test specifies a tool, then use it for common tests"

	^ nil
]

{ #category : 'support' }
JadeiteForPharoGUITestCase >> userId [

	^ JadeiteConnectionProfile connectionProfile user
]

{ #category : 'support' }
JadeiteForPharoGUITestCase >> waitFor: aBlock errorMessage: errorString [

	| sem |
	sem := Semaphore new.
	[
	aBlock whileTrue: [ (Delay forMilliseconds: 1) wait ].
	sem signal ] fork.
	(sem waitTimeoutSeconds: 2) ifTrue: [ Error signal: errorString ]
]

{ #category : 'support' }
JadeiteForPharoGUITestCase >> waitForCloseDialog [

	| dialogs count |
	count := 0.
	[
		(dialogs := self currentWorld windowsSatisfying: [ :each |
			            each isKindOf: QuestionWithoutCancelDialogWindow ])
			isEmpty and: [ count < 10 ] ] whileTrue: [
			count := count + 1.
			(Delay forMilliseconds: 10) wait ].
	self assert: dialogs size equals: 1.
	Processor yield. "presumably, the dialog was opened in a forked thread, we want to let it finish activating before continuing. "
	^ dialogs first
]

{ #category : 'support' }
JadeiteForPharoGUITestCase >> waitForFileOperationSemaphore [

	WorldMorph doOneCycle.
	fileOperationSemaphore wait
]

{ #category : 'support' }
JadeiteForPharoGUITestCase >> waitForMethodListBrowserWhile: aBlock [

	methodListBrowser := self
		                     waitForNewPresenter: JadeiteMethodListPresenter
		                     while: aBlock
]

{ #category : 'support' }
JadeiteForPharoGUITestCase >> waitForNewBrowserWhile: aBlock [

	projectsBrowser := self
		                   waitForNewPresenter: JadeiteBrowser browserClass
		                   while: aBlock
]

{ #category : 'support' }
JadeiteForPharoGUITestCase >> waitForSaveDialog [

	| dialogs count |
	count := 0.
	[
	(dialogs := self currentWorld windowsSatisfying: [ :each |
		            (each model class canUnderstand: #presenter)
			            ifTrue: [
			            each model presenter isKindOf:
				            JadeiteServerFileSaveDialog ]
			            ifFalse: [ false ] ]) isEmpty and: [ count < 10 ] ]
		whileTrue: [
			count := count + 1.
			(Delay forMilliseconds: 10) wait ].
	self assert: dialogs size equals: 1.
	^ dialogs first model
]

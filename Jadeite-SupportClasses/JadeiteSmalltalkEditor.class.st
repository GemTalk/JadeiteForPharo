"
Redirect Morphic menu items to a GemStone equivalent
"
Class {
	#name : 'JadeiteSmalltalkEditor',
	#superclass : 'RubSmalltalkEditor',
	#traits : 'JadeiteMethodsTrait + JadeiteToolbarTrait + JadeiteClassTrait',
	#classTraits : 'JadeiteMethodsTrait classTrait + JadeiteToolbarTrait classTrait + JadeiteClassTrait classTrait',
	#instVars : [
		'gciSession'
	],
	#category : 'Jadeite-SupportClasses',
	#package : 'Jadeite-SupportClasses'
}

{ #category : 'keymapping' }
JadeiteSmalltalkEditor class >> buildShortcutsOn: aBuilder [
	"override to remove meta-shift-C compareToClipboard modal window functionality.
	Causes havoc if Find Class window happens to be open. Can still compareToClipboard
	in pharo windows. "

	<keymap>
	(aBuilder shortcut: #cancel)
		category: RubTextEditor name
		default: $l meta
		do: [ :target | target editor cancel ]
		description: 'Cancel unsaved editings'.

	(aBuilder shortcut: #accept)
		category: RubTextEditor name
		default: $s meta
		do: [ :target | target editor accept ]
		description: 'Accept unsaved editings'.

	(aBuilder shortcut: #selectAll)
		category: RubTextEditor name
		default: $a meta
		do: [ :target | target editor selectAll: nil ]
		description: 'Select all'.

	(aBuilder shortcut: #copySelection)
		category: RubTextEditor name
		default: $c meta
		do: [ :target | target editor copySelection ]
		description: 'Copy selection'.

	(aBuilder shortcut: #paste)
		category: RubTextEditor name
		default: $v meta
		do: [ :target | target editor paste ]
		description: 'Paste'.

	(aBuilder shortcut: #cut)
		category: RubTextEditor name
		default: $x meta
		do: [ :target | target editor cut ]
		description: 'Cut selection'.

	(aBuilder shortcut: #undometa)
		category: RubTextEditor name
		default: $z meta
		do: [ :target | target editor undo ]
		description: 'Undo'.

	(aBuilder shortcut: #redometa)
		category: RubTextEditor name
		default: $z meta shift
		do: [ :target | target editor redo ]
		description: 'Redo'.

	(aBuilder shortcut: #find)
		category: RubTextEditor name
		default: $f meta
		do: [ :target | target editor find: nil ]
		description: 'Find text'.

	(aBuilder shortcut: #findAgainmeta)
		category: RubTextEditor name
		default: $g meta
		do: [ :target | target editor findAgain: nil ]
		description: 'Find text again'.

	(aBuilder shortcut: #indent)
		category: RubTextEditor name
		default: $r meta shift
		do: [ :target | target editor indent: nil ]
		description: 'Indent'.

	(aBuilder shortcut: #outdent)
		category: RubTextEditor name
		default: $l meta shift
		do: [ :target | target editor outdent: nil ]
		description: 'Outdent'
]

{ #category : 'completion engine' }
JadeiteSmalltalkEditor class >> completionEngineClass [

	^JadeiteCompletionEngine
]

{ #category : 'accessing' }
JadeiteSmalltalkEditor >> application [ 

	^JadeiteApplication new
]

{ #category : 'new selection' }
JadeiteSmalltalkEditor >> beginningOfLine [
	^(self encompassJadeiteParagraph: self selectionInterval) first. 

]

{ #category : 'editing keys' }
JadeiteSmalltalkEditor >> browseClassOfExpression [

	self evaluateSelectionAndDo: [ :result |
		| classService browser |
		classService := RowanClassService new name: result.
		browser := self openBrowser.
		browser activePresenter
			updateAfterFindClass: classService
			methodService: nil
			onCompletion: [  ] ].
	^ true
]

{ #category : 'menu messages' }
JadeiteSmalltalkEditor >> classCommentsContainingIt [

	MessageBox notify: 'Not implemented yet'
]

{ #category : 'menu messages' }
JadeiteSmalltalkEditor >> classNamesContainingIt [

	MessageBox notify: 'Not implemented yet'
]

{ #category : 'completion engine' }
JadeiteSmalltalkEditor >> completionEngine [

	^ completionEngine ifNil: [
		CompletionEngineClass ifNotNil: [
			self completionEngine: JadeiteCompletionEngine new.
			completionEngine ] ]
]

{ #category : 'new selection' }
JadeiteSmalltalkEditor >> encompassJadeiteParagraph: anInterval [

	^ self string encompassJadeiteParagraph: anInterval
]

{ #category : 'new selection' }
JadeiteSmalltalkEditor >> endOfLine [

	^ (self encompassJadeiteParagraph: self selectionInterval) last
]

{ #category : 'accessing' }
JadeiteSmalltalkEditor >> gciSession [

	^ gciSession
]

{ #category : 'accessing' }
JadeiteSmalltalkEditor >> gciSession: anObject [

	gciSession := anObject
]

{ #category : 'menu messages' }
JadeiteSmalltalkEditor >> implementorsOf: aSelector [

	self browseImplementorsOf: aSelector
]

{ #category : 'menus' }
JadeiteSmalltalkEditor >> inspectIt [

	self halt.
]

{ #category : 'menu messages' }
JadeiteSmalltalkEditor >> methodCaseSensitiveStringsContainingIt [
	self lineSelectAndEmptyCheck: [ ^ self ].
	self browseLiteralReferences: self selection string
	
]

{ #category : 'menu messages' }
JadeiteSmalltalkEditor >> methodNamesContainingIt [

	MessageBox notify: 'Not implemented yet'
]

{ #category : 'menu messages' }
JadeiteSmalltalkEditor >> methodSourceContainingIt [
	"Open a browser on methods which contain the current selection as part of a string constant."

	self lineSelectAndEmptyCheck: [ ^ self ].
	self browseMethodsContaining: self selection string
	
]

{ #category : 'menu messages' }
JadeiteSmalltalkEditor >> methodStringsContainingit [
	"for now, just do a case sensitive search"
	self lineSelectAndEmptyCheck: [ ^ self ].
	self browseLiteralReferences: self selection string
	
]

{ #category : 'menu messages' }
JadeiteSmalltalkEditor >> referencesTo: className [

	self browseClassReferences: className
]

{ #category : 'menu messages' }
JadeiteSmalltalkEditor >> sendersOf: aSelector [

	self browseSendersOf: aSelector
]

{ #category : 'menu messages' }
JadeiteSmalltalkEditor >> sendersOfIt [

	| selectedSelector |
	(selectedSelector := self selectedSelector) ifNil: [
		^ textArea flash ].
	self sendersOf: selectedSelector
]

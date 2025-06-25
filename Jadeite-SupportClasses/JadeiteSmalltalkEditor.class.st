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

{ #category : 'editing keys' }
JadeiteSmalltalkEditor >> browseIt: aKeyboardEvent [
	"do nothing for now. Might want to integrate JadeiteBrowseClassCommand someday"

	
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

{ #category : 'typing/selecting keys' }
JadeiteSmalltalkEditor >> crWithIndent: aKeyboardEvent [
	"Replace the current text selection with CR followed by as many tabs
	as on the current line (+/- bracket count) -- initiated by Shift-Return."

	| char s i tabCount crChars |
	self closeTypeIn.
	s := self string.
	i := self stopIndex.
	tabCount := 0.
	crChars := Array with: Character cr with: Character lf.
	[
	(i := i - 1) > 0 and: [ (crChars includes: (char := s at: i)) not ] ]
		whileTrue: [ "Count tabs and brackets (but not a leading bracket)"
			(char = Character tab and: [
				 i < s size and: [ (s at: i + 1) ~= $[ ] ]) ifTrue: [
				tabCount := tabCount + 1 ].
			char = $[ ifTrue: [ tabCount := tabCount + 1 ].
			char = $] ifTrue: [ tabCount := tabCount - 1 ] ].
	"Now inject CR with tabCount tabs"
	self addString:
		(String streamContents: [ :strm | strm lftab: tabCount ]).
	self unselect.
	^ false
]

{ #category : 'private' }
JadeiteSmalltalkEditor >> cursorEnd: aKeyboardEvent [
	"Private - Move cursor end of current line."

	| string |
	self closeTypeIn.
	string := self string.
	self
		moveCursor: [ :position | string indexOf: Character lf startingAt: position ifAbsent: [ string size + 1 ] ]
		forward: true
		specialBlock: [ :dummy | string size + 1 ]
		event: aKeyboardEvent.
	^ true
]

{ #category : 'private' }
JadeiteSmalltalkEditor >> cursorHome: aKeyboardEvent [
	"Private - Move cursor from position in current line to beginning of
	current line. If control key is pressed put cursor at beginning of text"

	| string |
	string := self string.
	self
		moveCursor: [ :position | (string lastIndexOf: Character lf startingAt: position - 1 ifAbsent: [ 0 ]) + 1 ]
		forward: false
		specialBlock: [ :dummy | 1 ]
		event: aKeyboardEvent.
	^ true
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

{ #category : 'private' }
JadeiteSmalltalkEditor >> inOutdent: aKeyboardEvent delta: delta [
	"Add/remove a tab at the front of every line occupied by the selection.
	Derived from work by Larry Tesler back in December 1985."

	| cr realStart realStop lines startLine stopLine start stop adjustStart indentation size numLines inStream newString outStream |
	cr := Character lf. "<<<<< Jadeite change"

	"Operate on entire lines, but remember the real selection for re-highlighting later"
	realStart := self startIndex.
	realStop := self stopIndex - 1.

	"Special case a caret on a line of its own, including weird case at end of paragraph"
	(realStart > realStop and: [
				realStart < 2 or: [(self string at: realStart - 1) == cr]])
		ifTrue:
			[delta < 0
				ifTrue: [
					textArea flash]
				ifFalse: [
					self replaceSelectionWith: Character tab asSymbol asText.
					self selectAt: realStart + 1].
			^true].

	lines := self paragraph lines.
	startLine := self paragraph lineIndexOfCharacterIndex: realStart.
	stopLine := self paragraph lineIndexOfCharacterIndex: (realStart max: realStop).
	start := (lines at: startLine) first.
	stop := (lines at: stopLine) last.

	"Pin the start of highlighting unless the selection starts a line"
	adjustStart := realStart > start.

	"Find the indentation of the least-indented non-blank line; never outdent more"
	indentation := (startLine to: stopLine) inject: 1000 into: [ :previousValue :each |
		previousValue min: (self paragraph indentationOfLineIndex: each ifBlank: [ :tabs | 1000 ])].

	size :=  stop + 1 - start.
	numLines := stopLine + 1 - startLine.
	inStream := ReadStream on: self string from: start to: stop.

	newString := String new: size + ((numLines * delta) max: 0).
	outStream := ReadWriteStream on: newString.

	"This subroutine does the actual work"
	self indent: delta fromStream: inStream toStream: outStream.

	"Adjust the range that will be highlighted later"
	adjustStart ifTrue: [realStart := (realStart + delta) max: start].
	realStop := realStop + outStream position - size.

	"Prepare for another iteration"
	indentation := indentation + delta.
	size := outStream position.
	inStream := outStream setFrom: 1 to: size.

	outStream == nil
		ifTrue: 	"tried to outdent but some line(s) were already left flush"
			[textArea flash]
		ifFalse:
			[self selectInvisiblyFrom: start to: stop.
			size = newString size ifFalse: [newString := outStream contents].
			self replaceSelectionWith: newString asText].
	self selectFrom: realStart to: realStop. 	"highlight only the original range"
	^ true
]

{ #category : 'private' }
JadeiteSmalltalkEditor >> indent: delta fromStream: inStream toStream: outStream [
	"Append the contents of inStream to outStream, adding or deleting delta or -delta
	 tabs at the beginning, and after every CR except a final CR.  Do not add tabs
	 to totally empty lines, and be sure nothing but tabs are removed from lines."

	| ch skip cr tab prev atEnd |
	cr := Character lf.
	tab := Character tab.
	delta > 0
		ifTrue: "shift right"
			[prev := cr.
			 [ch := (atEnd := inStream atEnd) ifTrue: [cr] ifFalse: [inStream next].
			  (prev == cr and: [ch ~~ cr]) ifTrue:
				[delta timesRepeat: [outStream nextPut: tab]].
			  atEnd]
				whileFalse:
					[outStream nextPut: ch.
					prev := ch]]
		ifFalse: "shift left"
			[skip := delta. "a negative number"
			 [inStream atEnd] whileFalse:
				[((ch := inStream next) == tab and: [skip < 0]) ifFalse:
					[outStream nextPut: ch].
				skip := ch == cr ifTrue: [delta] ifFalse: [skip + 1]]]
]

{ #category : 'menus' }
JadeiteSmalltalkEditor >> inspectIt [

	self halt.
]

{ #category : 'private' }
JadeiteSmalltalkEditor >> lineStart: position [
	"The offset of the start of the line of `postion`"

	^ (self string
		   lastIndexOf: Character lf
		   startingAt: position - 1
		   ifAbsent: [ 0 ]) + 1
]

{ #category : 'private' }
JadeiteSmalltalkEditor >> lines [
	"Compute lines based on logical line breaks, not optical (which may change due to line wrapping of the editor).
	Subclasses using kinds of Paragraphs can instead use the service provided by it.
	"
	| lines string index lineIndex stringSize |
	string := self string.
	"Empty strings have no lines at all. Think of something."
	string isEmpty ifTrue:[^{#(1 0 0)}].
	stringSize := string size.
	lines := OrderedCollection new: (string size // 15).
	index := 0.
	lineIndex := 0.
	string linesDo:[:line |
		lines addLast: (Array
			with: (index := index + 1)
			with: (lineIndex := lineIndex + 1)
			with: (index := index + line size min: stringSize))].
	"Special workaround for last line empty."
	string last == Character lf "<<<<<<<<<<<<<<<<<<<<<Jadeite change here"
	"lines last last < stringSize" ifTrue:[lines addLast:{stringSize +1. lineIndex+1. stringSize}].
	^lines
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

{ #category : 'private' }
JadeiteSmalltalkEditor >> nextWord: position stopOnUpperCase: stopOnUpperCase [

	| string index size initialPosition groupAtStart currentGroup |
	"Positions go from 1 to size + 1
	Position N + 1 is after the Nth character"
	string := self string.
	size := string size + 1.
	index := initialPosition := 1 max: position.

	position >= string size ifTrue: [ ^ size ].

	[ "Skip blanks"
	index < string size and: [
		{
			Character space.
			Character tab } includes: (string at: index) ] ] whileTrue: [
		index := index + 1 ].

	groupAtStart := self characterGroupAt: index in: string.

	"Go at least once forward to guarantee progress"
	index = initialPosition ifTrue: [ index := index + 1 ].

	"Do not stop if we are in an uppercase->lowercase transition"
	(groupAtStart = #upper and: [
		 stopOnUpperCase not or: [
			 (self characterGroupAt: index in: string) = #lower ] ]) ifTrue: [
		groupAtStart := #lower ].

	[ "Stop when we reach the end, a new line, or a different character group"
	index >= size ifTrue: [ ^ size ].
	(string at: index) = Character lf ifTrue: [ ^ index ].

	currentGroup := self characterGroupAt: index in: string.
	(stopOnUpperCase not and: [ currentGroup = #upper ]) ifTrue: [
		currentGroup := #lower ].

	currentGroup = groupAtStart ] whileTrue: [ index := index + 1 ].

	"Moving to the right from upper to lower, we want to stop left of the upper"
	(stopOnUpperCase and: [
		 groupAtStart = #upper and: [ currentGroup = #lower ] ]) ifTrue: [
		index := index - 1 ].

	^ index
]

{ #category : 'private' }
JadeiteSmalltalkEditor >> previousWord: position stopOnUpperCase: stopOnUpperCase [

	| string index size initialPosition groupAtStart currentGroup |
	"Positions go from 1 to size + 1
	Position N + 1 is after the Nth character"
	string := self string.
	size := string size + 1.
	index := initialPosition := size min: position.

	position <= 2 ifTrue: [ ^ 1 ].

	[ "Skip blanks"
	index > 1 and: [
		{
			Character space.
			Character tab } includes: (string at: index - 1) ] ] whileTrue: [
		index := index - 1 ].

	groupAtStart := self characterGroupAt: index - 1 in: string.

	"Go at least once backward to guarantee progress"
	index = initialPosition ifTrue: [ index := index - 1 ].

	"Stop if we are in a lowercase->uppercase transition"
	groupAtStart = #upper ifTrue: [
		stopOnUpperCase
			ifFalse: [ groupAtStart := #lower ]
			ifTrue: [
				(index < string size and: [
					 (self characterGroupAt: index + 1 in: string) = #lower ])
					ifTrue: [ ^ index ] ] ].

	[ "Stop when we reach the end, a new line, or a different character group"
	index <= 1 ifTrue: [ ^ 1 ].
	(string at: index - 1) = Character lf ifTrue: [ ^ index ].

	currentGroup := self characterGroupAt: index - 1 in: string.
	(stopOnUpperCase not and: [ currentGroup = #upper ]) ifTrue: [
		currentGroup := #lower ].

	currentGroup = groupAtStart ] whileTrue: [ index := index - 1 ].

	"Moving to the left from lower to upper, we want to stop left of the upper"
	(stopOnUpperCase and: [
		 groupAtStart = #lower and: [ currentGroup = #upper ] ]) ifTrue: [
		index := index - 1 ].

	^ index
]

{ #category : 'menu messages' }
JadeiteSmalltalkEditor >> referencesTo: className [

	self browseClassReferences: className
]

{ #category : 'private' }
JadeiteSmalltalkEditor >> selectedSymbol [
	"Return the currently selected symbol, or nil if none.  Spaces, tabs and returns are ignored"

	| aString |
	self hasCursor ifTrue: [^self findSelectorFromAST].
	aString := self selection string copyWithoutAll:
		{Character space.  Character lf.  Character tab}.
	aString size = 0 ifTrue: [^ nil].
	Symbol hasInterned: aString ifTrue: [:sym | ^sym].

	^ nil
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

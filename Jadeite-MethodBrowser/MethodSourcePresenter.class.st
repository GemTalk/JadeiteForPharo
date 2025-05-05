Class {
	#name : 'MethodSourcePresenter',
	#superclass : 'CodeSourcePresenter',
	#instVars : [
		'currentSelector',
		'gsMethod',
		'originalSource',
		'offsets'
	],
	#category : 'Jadeite-MethodBrowser',
	#package : 'Jadeite-MethodBrowser'
}

{ #category : 'as yet unclassified' }
MethodSourcePresenter class >> publishedEventsOfInstances [
    
    	^super publishedEventsOfInstances
			add: #'needUser';
			add: #'savedMethod:inClass:';
			yourself.

]

{ #category : 'as yet unclassified' }
MethodSourcePresenter >> canSetBreakpoints [

	^true.

]

{ #category : 'as yet unclassified' }
MethodSourcePresenter >> clearBreakAtStepPoint: anInteger [
	gsMethod clearBreakAtStepPoint: anInteger session: gciSession.
	self updateMethodStepPoints.

]

{ #category : 'as yet unclassified' }
MethodSourcePresenter >> codePresenterIsMethod [

	^true
]

{ #category : 'as yet unclassified' }
MethodSourcePresenter >> createSchematicWiring [
	super createSchematicWiring.
	documentPresenter
		when: #hoverStart:
			send: #hoverStart:
			to: self;
		when: #hoverEnd:
			send: #hoverEnd:
			to: self;
		when: #focusLost
			send: #cancelCallTip
			to: documentPresenter view;
		yourself
]

{ #category : 'as yet unclassified' }
MethodSourcePresenter >> defaultMethod [
	^JadePresenter defaultMethodTemplate
]

{ #category : 'as yet unclassified' }
MethodSourcePresenter >> gsMethod [
	"testing only"
	^gsMethod
]

{ #category : 'as yet unclassified' }
MethodSourcePresenter >> gsMethod: aGsMethod [
	gsMethod := aGsMethod.
	self update.
]

{ #category : 'as yet unclassified' }
MethodSourcePresenter >> hoverEnd: anObject [

	documentPresenter view cancelCallTip.
]

{ #category : 'as yet unclassified' }
MethodSourcePresenter >> hoverStart: aPoint [

	| charIndex indicator |
	charIndex := documentPresenter view charNearestPosition: aPoint.
	indicator := documentPresenter view indicators
		detect: [:each | each range includes: charIndex]
		ifNone: [^self].
	documentPresenter view 
		showCallTip: indicator tag
		at: charIndex.

]

{ #category : 'as yet unclassified' }
MethodSourcePresenter >> methodMenu: aMenu [
	self methodMenuBreak: aMenu
]

{ #category : 'as yet unclassified' }
MethodSourcePresenter >> methodSource [

	^documentPresenter value.

]

{ #category : 'as yet unclassified' }
MethodSourcePresenter >> newSelector [

	| string index list stream |
	string := documentPresenter value.
	#($" $| $. $;) do: [:each | 
		index := string indexOf: each.
		2 < index ifTrue: [string := string copyFrom: 1 to: index - 1].
	].
	list := string subStrings.
	string first isPunctuation ifTrue: [^list first asSymbol].
	list first last = $: ifFalse: [^list first asSymbol].
	stream := WriteStream on: String new.
	index := 1.
	[
		index < list size and: [(list at: index) last = $:].
	] whileTrue: [
		stream nextPutAll: (list at: index).
		index := index + 2.
	].
	^stream contents asSymbol.



]

{ #category : 'as yet unclassified' }
MethodSourcePresenter >> offsetAt: index [
	"offsets are set by the debugger if we are in one"

	^offsets ifNil: [0] ifNotNil: [offsets at: index]
]

{ #category : 'as yet unclassified' }
MethodSourcePresenter >> offsets [
	^offsets
]

{ #category : 'as yet unclassified' }
MethodSourcePresenter >> offsets: anObject [
	offsets := anObject
]

{ #category : 'as yet unclassified' }
MethodSourcePresenter >> onViewOpened [
	super onViewOpened.
	documentPresenter view contextMenu: (Menu fromStrings: self editMenuStrings).
	self 
		updateCodeFont;
		setDefaultMethod;
		yourself.

]

{ #category : 'as yet unclassified' }
MethodSourcePresenter >> setBreakAtStepPoint: anInteger [

	gsMethod setBreakAtStepPoint: anInteger session: gciSession.
	self updateMethodStepPoints.

]

{ #category : 'as yet unclassified' }
MethodSourcePresenter >> setDefaultMethod [

	documentPresenter 
		value: self defaultMethod;
		isModified: false;
		isReadOnly: false;
		yourself.

]

{ #category : 'as yet unclassified' }
MethodSourcePresenter >> setEmptyMethod [

	self statusBarText: ''.
	documentPresenter 
		value: '';
		isModified: false;
		isReadOnly: true;
		selectionRange: (1 to: 0);
		yourself.

]

{ #category : 'as yet unclassified' }
MethodSourcePresenter >> showStepPoint: anInteger [
	| lineNumber range stepPoint |
	stepPoint := gsMethod stepPoints at: anInteger ifAbsent: [^self].
	documentPresenter view selectionRange: stepPoint key.
	(range := documentPresenter view selectionRange) isEmpty ifTrue: [^self].
	lineNumber := documentPresenter view lineFromPosition: range first.
	lineNumber := lineNumber - 4 max: 1.
	documentPresenter view lineScroll: lineNumber
]

{ #category : 'as yet unclassified' }
MethodSourcePresenter >> stepPointAt: aPoint [

	| charIndex stepPoints |
	stepPoints := gsMethod stepPoints.
	charIndex := documentPresenter view charNearestPosition: aPoint.
	stepPoints size to: 1 by: -1 do: [:stepPoint | 
		| range |
		range := (stepPoints at: stepPoint) key.
		(range start <= charIndex and: [charIndex <= range stop]) ifTrue: [
			^stepPoint.
		].
	].
	^nil.

]

{ #category : 'as yet unclassified' }
MethodSourcePresenter >> update [
	| newSource string |
	documentPresenter view cancelCallTip.
	newSource := gsMethod source.
	documentPresenter view isModified
		ifTrue: 
			[newSource = originalSource ifTrue: [^self].
			(MessageBox confirm: 'Copy changes to clipboard?' caption: 'Method has unsaved changes!')
				ifTrue: 
					[documentPresenter value isString
						ifTrue: [documentPresenter value copyToClipboard	"come in through debugger"]
						ifFalse: [documentPresenter value value copyToClipboard]]].
	self setEmptyMethod.
	gsMethod ifNil: [^self].
	string := ' -- ' , gsMethod category , ' -- '.	"package"	"mcTimestamp"
	self statusBarText: string.
	originalSource := newSource.
	documentPresenter
		value: originalSource;
		isModified: false;
		isReadOnly: gsMethod isReadOnly;
		yourself.
	documentPresenter view
		backcolor: JadeiteTextStyles default colorForNoEdits;
		isEnabled: true;
		yourself.
	self updateMethodStepPoints.
	currentSelector := gsMethod selector
]

Class {
	#name : 'JadeiteMethodSourcePane',
	#superclass : 'JadeiteTextDocument',
	#traits : 'JadeiteMethodsTrait + JadeiteClassTrait',
	#classTraits : 'JadeiteMethodsTrait classTrait + JadeiteClassTrait classTrait',
	#instVars : [
		'methodService'
	],
	#category : 'Jadeite-TextPanes',
	#package : 'Jadeite-TextPanes'
}

{ #category : 'adding' }
JadeiteMethodSourcePane >> addTextSegmentDecoration: aDecorationSegment [

	[ super addTextSegmentDecoration: aDecorationSegment ]
		on: Error
		do: [ :ex |
			Transcript
				cr;
				show: 'JadeiteMethodSourcePane>>#addTextSegmentDecoration: error - ';
				print: ex;
				flush ]
]

{ #category : 'commands' }
JadeiteMethodSourcePane >> clearAllMethodBreakpoints [

	| service |
	service := RowanAnsweringService
		           command: #clearMethodBreaks:
		           withArgs: (Array with: (Array with: self methodService)).
	self issueCommand: service onCompletion: [self outerBrowser updateMethodSource]
]

{ #category : 'breakpoints' }
JadeiteMethodSourcePane >> clearBreakPointAt: stepPoint onCompletion: completionBlock [

	self methodService
		command: #clearBreakAt:;
		commandArgs: (Array with: stepPoint).
	self issueCommand: self methodService onCompletion: completionBlock
]

{ #category : 'commands' }
JadeiteMethodSourcePane >> clearBreakpoint: stepPoint [

	stepPoint isNil ifTrue: [ ^ self ].
	self
		clearBreakPointAt: stepPoint
		onCompletion: [ self outerBrowser updateMethodSource ]
]

{ #category : 'actions - saving methods' }
JadeiteMethodSourcePane >> currentMethodSourceFrom: sourceString [

	| source fromStream writeStream |
	sourceString isEmpty ifTrue:[^sourceString]. 
	fromStream := ReadStream on: sourceString.
	writeStream := WriteStream on: String new.
	[
		fromStream atEnd not.
	] whileTrue: [
		| char |
		(char := fromStream next) == Character cr ifTrue: [
			fromStream peek ~~ Character lf ifTrue: [
				writeStream nextPut: Character lf.
			].
		] ifFalse: [
			writeStream nextPut: char.
		].
	].
	source := writeStream contents.
	[
		source last codePoint <= 32.
	] whileTrue: [
		source := source copyFrom: 1 to: source size - 1.
	].
	^source.

]

{ #category : 'events' }
JadeiteMethodSourcePane >> displayStepPointAt: sourcePosition [

	| stepPoint range ranges |
	methodService ifNil: [ ^self ].
	ranges := methodService stepPoints collect: [ :array |
		          methodService stepPointRangeFrom: array ].
	range := ranges
		         detect: [ :theRange | theRange includes: sourcePosition ]
		         ifNone: [  ].
	stepPoint := ranges indexOf: range.
	stepPoint = 0 ifTrue: [ stepPoint := '*' ].
	self outerBrowser statusBarText pushMessage:
		'Step Point: ' , stepPoint asString
]

{ #category : 'as yet unclassified' }
JadeiteMethodSourcePane >> ensureVisible [

	self todo:'may need to implement this'
]

{ #category : 'private' }
JadeiteMethodSourcePane >> findClassService: classService [

	classService ifNil: [ ^ self ].

	self owner owner "ick"
		updateAfterFindClass: classService
		onCompletion: nil
]

{ #category : 'as yet unclassified' }
JadeiteMethodSourcePane >> formatSource [

	| answeringService |
	answeringService := RowanAnsweringServiceClient new
		                    command: #formatSource:;
		                    commandArgs:
			                    (Array with: self text asString replaceCrWithLf).
	self issueCommand: answeringService onCompletion: [self text: answeringService answer]
]

{ #category : 'initialization' }
JadeiteMethodSourcePane >> initializePresenters [

	super initializePresenters.
	self bindKeyCombination: $f shift ctrl toAction: [ self findClass ].
	self bindKeyCombination: $f alt toAction: [ self formatSource ]
]

{ #category : 'events' }
JadeiteMethodSourcePane >> keystrokeAt: click [

	| sourcePosition |
	click morph textArea scrollPane owner hasUnacceptedEdits ifTrue: [
		^ self outerBrowser statusBarText pushMessage:
			  'Step Point: <method changed>' ].
	sourcePosition := click morph textArea startIndex.
	self displayStepPointAt: sourcePosition
]

{ #category : 'accessing' }
JadeiteMethodSourcePane >> methodService [

	^ methodService
]

{ #category : 'accessing' }
JadeiteMethodSourcePane >> methodService: anObject [

	methodService := anObject
]

{ #category : 'events' }
JadeiteMethodSourcePane >> mouseClickedAt: click [

	| sourcePosition |
	click event handler hasUnacceptedEdits ifTrue: [
		^ self outerBrowser statusBarText pushMessage:
			  'Step Point: <method changed>' ].
	sourcePosition := click event handler scrollPane textArea startIndex.
	self displayStepPointAt: sourcePosition
]

{ #category : 'commands' }
JadeiteMethodSourcePane >> outerBrowser [
	"yuck" 

	^ ((self owner isKindOf: SpWindowPresenter) or:[self owner isKindOf: JadeiteNotebookPresenter])
		  ifTrue: [ self owner owner ]
		  ifFalse: [ self owner ]
]

{ #category : 'adding' }
JadeiteMethodSourcePane >> removeAllTextSegmentDecorations [

	self withAdapterDo: [ :anAdapter |
		anAdapter widgetDo: [ :w | w segments: OrderedCollection new ] ]
]

{ #category : 'actions - saving methods' }
JadeiteMethodSourcePane >> saveMethodIn: classService category: jadeiteCategory completionBlock: completionBlock [

	| methodSource1 theCategory |
	self text: self adapter widget textArea text. "this should NOT be necessary. Something is broken in the way we set the Jadeite editor in JadeiteMorphicTextAdapter>>buildWidget"
	methodSource1 := self currentMethodSourceFrom: self text.
	theCategory := jadeiteCategory isString
		               ifTrue: [ jadeiteCategory ]
		               ifFalse: [ jadeiteCategory categoryName ].
	classService
		command: #saveMethodSource:category:;
		commandArgs: (Array with: methodSource1 with: theCategory);
		compileErrorHandler: [ :ex |
			self reportCompileError: ex gsArguments ].
	self issueCommand: classService onCompletion: [
		self hasUnacceptedEdits: false.
		completionBlock value ]
]

{ #category : 'selections' }
JadeiteMethodSourcePane >> selectMessageAt: sourceOffset [

	| readStream |
	readStream := ReadStream on: methodService source.
	readStream position: sourceOffset.
	[ readStream atEnd ] whileFalse:[
		| char |
		char := readStream next. 
		char isSeparator ifTrue:[^self selectionInterval: (sourceOffset to: readStream position)]
	].	
	self selectionInterval: (sourceOffset to: readStream position)
]

{ #category : 'accessing' }
JadeiteMethodSourcePane >> selectedSelector [
	"simplified from superclass - always find the true selector and not the selection"
	| extractor fullSource index |
	fullSource := self text.
	fullSource ifNil: [ ^ nil ].
	extractor := CNSelectorExtractor new. 
	index := self cursorPositionIndex ifNil: [ 1 ].
	^ extractor
		  extractSelectorFromAST: (RBParser parseFaultyMethod: fullSource)
		  atPosition: index
]

{ #category : 'accessing' }
JadeiteMethodSourcePane >> selectedStepPoint [

	| stepPoint localPoint charBlock |
	localPoint := adapter widget textArea globalPointToLocal:
		              self currentWorld activeHand position.
	charBlock := adapter widget paragraph characterBlockAtPoint:
		             localPoint.
	self methodService ifNil: [
		^ 1 "user may not have a method selected" ].
	stepPoint := self methodService
		             stepPointFromCursorIn: self
		             cursorPosition: charBlock stringIndex.
	^ stepPoint
]

{ #category : 'breakpoints' }
JadeiteMethodSourcePane >> setBreakPointAt: stepPoint onCompletion: completionBlock [

	self methodService
		command: #setBreakAt:;
		commandArgs: (Array with: stepPoint).
	RowanServiceUpdater current
		issueCommand: self methodService
		session: self gciSession
		onCompletion: completionBlock
]

{ #category : 'commands' }
JadeiteMethodSourcePane >> setBreakpoint: stepPoint [

	stepPoint isNil ifTrue: [ ^ self ].
	self setBreakPointAt: stepPoint onCompletion: [self outerBrowser updateMethodSource]
]

{ #category : 'as yet unclassified' }
JadeiteMethodSourcePane >> showStepPoint: anInteger [
	| stepPoint stringToHighlight |
	anInteger ifNil: [ ^self ].
	methodService ifNil:[^self]. 
	stepPoint := methodService  stepPoints at: anInteger ifAbsent: [^self]. 
	stringToHighlight := (ReadStream on: stepPoint last) upTo: $:. 
	stringToHighlight isEmpty ifTrue:[
		self selectMessageAt: stepPoint first]
 	ifFalse:[ self selectionInterval: (stepPoint first to: (stepPoint first + stringToHighlight size - 1))]. 
]

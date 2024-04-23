Class {
	#name : 'JadeiteMethodSourcePane',
	#superclass : 'JadeiteTextDocument',
	#traits : 'JadeiteMethodsTrait + JadeiteClassTrait',
	#classTraits : 'JadeiteMethodsTrait classTrait + JadeiteClassTrait classTrait',
	#instVars : [
		'methodService'
	],
	#category : 'Jadeite-TextPanes'
}

{ #category : 'commands' }
JadeiteMethodSourcePane >> clearAllMethodBreakpoints [

	| service |
	service := RowanAnsweringService
		           command: #clearMethodBreaks:
		           withArgs: (Array with: (Array with: self methodService)).
	self issueCommand: service onCompletion: nil.
	self outerJadeiteBrowser updateMethodSource
]

{ #category : 'breakpoints' }
JadeiteMethodSourcePane >> clearBreakPointAt: stepPoint [

	self methodService
		command: #clearBreakAt:;
		commandArgs: (Array with: stepPoint).
	self issueCommand: self methodService onCompletion: nil
]

{ #category : 'commands' }
JadeiteMethodSourcePane >> clearBreakpoint: stepPoint [

	stepPoint isNil ifTrue: [ ^ self ].
	self clearBreakPointAt: stepPoint.
	self outerJadeiteBrowser updateMethodSource
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

{ #category : 'as yet unclassified' }
JadeiteMethodSourcePane >> ensureVisible [

	self todo:'may need to implement this'
]

{ #category : 'as yet unclassified' }
JadeiteMethodSourcePane >> formatSource [

	| answeringService |
	answeringService := RowanAnsweringServiceClient new
		                    command: #formatSource:;
		                    commandArgs:
			                    (Array with: self text asString replaceCrWithLf).
	self issueCommand: answeringService onCompletion: nil.
	self text: answeringService answer
]

{ #category : 'initialization' }
JadeiteMethodSourcePane >> initialize [

	super initialize. 
	"self withoutSyntaxHighlight"
]

{ #category : 'initialization' }
JadeiteMethodSourcePane >> initializeBindings [

	self bindKeyCombination: $f shift ctrl toAction: [ self findClass ]
]

{ #category : 'initialization' }
JadeiteMethodSourcePane >> initializePresenters [

	super initializePresenters.
	self bindKeyCombination: $f shift ctrl toAction: [ self findClass ].
	self bindKeyCombination: $f alt toAction: [ self formatSource ]
]

{ #category : 'accessing' }
JadeiteMethodSourcePane >> methodService [

	^ methodService
]

{ #category : 'accessing' }
JadeiteMethodSourcePane >> methodService: anObject [

	methodService := anObject
]

{ #category : 'commands' }
JadeiteMethodSourcePane >> outerJadeiteBrowser [
	"yuck" 

	^ ((self owner isKindOf: SpWindowPresenter) or:[self owner isKindOf: JadeiteNotebookPresenter])
		  ifTrue: [ self owner owner ]
		  ifFalse: [ self owner ]
]

{ #category : 'actions - saving methods' }
JadeiteMethodSourcePane >> saveMethodIn: classService category: jadeiteCategory [

	| methodSource1 theCategory |
	self text: self adapter widget textArea text. "this should NOT be necessary. Something is broken in the way we set the Jadeite editor in JadeiteMorphicTextAdapter>>buildWidget"
	methodSource1 := self currentMethodSourceFrom: self text.
	theCategory := jadeiteCategory isString ifTrue:[jadeiteCategory] ifFalse: [ jadeiteCategory categoryName ].
	classService
		command: #saveMethodSource:category:;
		commandArgs: (Array with: methodSource1 with: theCategory).
	[ self issueCommand: classService onCompletion: nil ]
		on: GsCompileError
		do: [ :ex |
			self reportCompileError: ex gsArguments.
			^ false ].
	self value: methodSource1.
	self hasUnacceptedEdits: false.
	^ true
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
	stepPoint := self methodService
		             stepPointFromCursorIn: self
		             cursorPosition: charBlock stringIndex.
	^ stepPoint
]

{ #category : 'breakpoints' }
JadeiteMethodSourcePane >> setBreakPointAt: stepPoint [
	
	self methodService
		command: #setBreakAt:;
		commandArgs: (Array with: stepPoint).
	RowanServiceUpdater current issueCommand: self methodService session: self gciSession.
]

{ #category : 'commands' }
JadeiteMethodSourcePane >> setBreakpoint: stepPoint [

	stepPoint isNil ifTrue: [ ^ self ].
	self setBreakPointAt: stepPoint.
	self outerJadeiteBrowser updateMethodSource
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

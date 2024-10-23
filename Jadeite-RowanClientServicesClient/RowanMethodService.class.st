"
Don't change the order of the inst vars without checking
the index of the firstReference & testResults inst vars. These have
constant methods for performance. 

#indexOfTestResultInstVar
#indexOfFirstReferenceInstVar
"
Class {
	#name : 'RowanMethodService',
	#superclass : 'RowanService',
	#instVars : [
		'oop',
		'source',
		'selector',
		'methodDefinitions',
		'category',
		'packageName',
		'projectName',
		'className',
		'meta',
		'hasSupers',
		'hasSubs',
		'compilationWarnings',
		'isExtension',
		'inSelectedPackage',
		'references',
		'stepPoints',
		'selectedPackageServices',
		'superDisplayString',
		'accessedInstVars',
		'breakPoints',
		'testResult',
		'definedPackage',
		'isTestMethod',
		'testRunClassName',
		'failedCompile',
		'comparisonSource',
		'firstReference',
		'renamedName',
		'isMethodForBlock',
		'homeMethodOop',
		'hasMethodHistory',
		'searchString',
		'definedClassName'
	],
	#category : 'Jadeite-RowanClientServicesClient',
	#package : 'Jadeite-RowanClientServicesClient'
}

{ #category : 'private' }
RowanMethodService class >> defaultIconName [
	"Answer a filename to use for an icon of this class."

	^File composeStem: 'Behavior' extension: 'ico'.
]

{ #category : 'instance creation' }
RowanMethodService class >> fakeMethodFor: className selector: selector source: source [
	| inst |
	inst := self new.
	inst
		className: className;
		selector: selector;
		source: source.
	^inst
]

{ #category : 'public' }
RowanMethodService class >> icon [
	"Answers an Icon that can be used to represent this class"

	^##(self) defaultIcon 
]

{ #category : 'accessing' }
RowanMethodService class >> templateClassName [ 

	^#RowanMethodService
]

{ #category : 'comparing' }
RowanMethodService >> <= methodService [

	^ methodService isService and: [
		  methodService isMethodService and: [
			  className = methodService className
				  ifTrue: [ selector <= methodService selector ]
				  ifFalse: [ className <= methodService className ] ] ]
]

{ #category : 'comparing' }
RowanMethodService >> = methodService [

	^ methodService isService and: [
		  methodService isMethodService and: [
			  selector = methodService selector and: [
				  className = methodService className and: [
					  meta = methodService meta ] ] ] ]
]

{ #category : 'comparing' }
RowanMethodService >> >= methodService [

	^ methodService isService and: [
		  methodService isMethodService and: [
			  className = methodService className
				  ifTrue: [ selector >= methodService selector ]
				  ifFalse: [ className >= methodService className ] ] ]
]

{ #category : 'accessing' }
RowanMethodService >> accessedInstVars [
	^accessedInstVars
]

{ #category : 'accessing' }
RowanMethodService >> accessedInstVars: anObject [
	accessedInstVars := anObject
]

{ #category : 'method menu support' }
RowanMethodService >> addBreakPointMenuAt: stepPoint to: aMenu presenter: presenter [
	| desc args menuCommand |
	args := Array with: stepPoint with: presenter parentPresenter.
	(self positiveBreakpoints includes: stepPoint)
		ifTrue: 
			[command := #clearBreakPointAt:in:.
			desc := 'Clear break at step point ' , stepPoint printString.
			menuCommand := MessageSend
						receiver: presenter parentPresenter
						selector: command
						arguments: args.
			aMenu addCommand: menuCommand description: desc.
			(breakPoints includes: stepPoint)
				ifTrue: 
					[command := #disableBreakPointAt:in:.
					desc := 'Disable break at step point ' , stepPoint printString]
				ifFalse: 
					[command := #enableBreakPointAt:in:.
					desc := 'Enable break at step point ' , stepPoint printString].
			menuCommand := MessageSend
						receiver: presenter parentPresenter
						selector: command
						arguments: args.
			aMenu addCommand: menuCommand description: desc]
		ifFalse: 
			[command := #setBreakPointAt:in:.
			desc := 'Break at step point ' , stepPoint printString.
			menuCommand := MessageSend
						receiver: presenter parentPresenter
						selector: command
						arguments: args.
			aMenu addCommand: menuCommand description: desc].
	^menuCommand
]

{ #category : 'method menu support' }
RowanMethodService >> appendToSourceMenu: aMenu presenter: methodSourcePresenter [
	| stepPoint menuCommand messageSelector |
	self removeTrailingMenuItemsFrom: aMenu.
	stepPoint := self stepPointFromCursorIn: methodSourcePresenter.
	stepPoint isNil ifTrue: [^self removeJadeiteSeparatorFrom: aMenu].
	('*Edit*' match: aMenu text) ifFalse: [^self removeJadeiteSeparatorFrom: aMenu].	"popup or edit menu only"	
	menuCommand := self
				addBreakPointMenuAt: stepPoint
				to: aMenu
				presenter: methodSourcePresenter.
	messageSelector := (stepPoints at: stepPoint) value.
	messageSelector isEmpty ifTrue: [^self removeJadeiteSeparatorFrom: aMenu].
	aMenu addSeparator.
	menuCommand := MessageSend
				receiver: methodSourcePresenter parentPresenter
				selector: #browseImplementorsOf:
				argument: messageSelector.
	aMenu addCommand: menuCommand description: 'Browse Implementors of ' , messageSelector printString.
	menuCommand := MessageSend
				receiver: methodSourcePresenter parentPresenter
				selector: #browseSendersOf:
				argument: messageSelector.
	aMenu addCommand: menuCommand description: 'Browse Senders of ' , messageSelector printString
]

{ #category : 'public' }
RowanMethodService >> basicPrepareForReplication [
	testRunClassName := nil.
	stepPoints := Array new
]

{ #category : 'public' }
RowanMethodService >> breakPoints [
	^breakPoints
]

{ #category : 'accessing' }
RowanMethodService >> breakPoints: anObject [
	breakPoints := anObject
]

{ #category : 'displaying' }
RowanMethodService >> breakpointDisplayString [
	| count writeStream disabledCount |
	breakPoints ifNil: [^self displayString].
	count := breakPoints size.
	disabledCount := (breakPoints select: [:bp | bp < 0]) size.
	writeStream := WriteStream on: String new.
	meta ifTrue: [writeStream nextPutAll: 'class>>'].
	writeStream
		nextPutAll: self displayString;
		space.
	writeStream
		nextPut: $(;
		nextPutAll: count printString.
	disabledCount > 0
		ifTrue: 
			[writeStream
				nextPut: $,; space;
				nextPutAll: 'disabled=';
				nextPutAll: disabledCount printString].
	writeStream nextPut: $).
	^writeStream contents
]

{ #category : 'accessing' }
RowanMethodService >> category [
	^category ifNil: ['']
]

{ #category : 'accessing' }
RowanMethodService >> category: anObject [
	category := anObject
]

{ #category : 'displaying' }
RowanMethodService >> classMethodDisplayString [
	| stream |
	stream := WriteStream on: String new.
	self displayOn: stream.
	^stream contents
]

{ #category : 'accessing' }
RowanMethodService >> className [
	^className asString
]

{ #category : 'accessing' }
RowanMethodService >> className: anObject [
	className := anObject asString
]

{ #category : 'public' }
RowanMethodService >> classService [

	^ (RowanClassService named: className)
		  meta: meta;
		  shouldUpdate: true;
		  updateAfterCommand: true;
		  yourself
]

{ #category : 'accessing' }
RowanMethodService >> comparisonSource [
	^comparisonSource
]

{ #category : 'accessing' }
RowanMethodService >> comparisonSource: anObject [
	comparisonSource := anObject
]

{ #category : 'accessing' }
RowanMethodService >> compilationWarnings [
	^compilationWarnings
]

{ #category : 'public' }
RowanMethodService >> copyBasicsFrom: oldService [

	oop 		:= oldService oop.
	selector 	:= oldService selector.
	className := oldService className asString.
	meta 	:= oldService meta.
]

{ #category : 'public' }
RowanMethodService >> debuggerMethodSourceUpdate: presenter browser: browser [
	"don't replicate the method - debugger is debugging the old method"

	self todo:[^browser refreshBreakPointsIn: presenter]
]

{ #category : 'accessing' }
RowanMethodService >> definedClassName [
	^definedClassName
]

{ #category : 'accessing' }
RowanMethodService >> definedClassName: anObject [
	definedClassName := anObject
]

{ #category : 'accessing' }
RowanMethodService >> definedPackage [
	^definedPackage
]

{ #category : 'displaying' }
RowanMethodService >> displayClassName [
	^className , (meta ifTrue: [' class'] ifFalse: [String new])
]

{ #category : 'displaying' }
RowanMethodService >> displayName [
	"protect against invalid entries"

	^[className , '>>' , selector] on: Error
		do: [:ex | className printString , '>>' , selector printString]
]

{ #category : 'displaying' }
RowanMethodService >> displayOn: aStream [
	aStream
		nextPutAll: (className ifNil: ['?']);
		nextPutAll: '>>';
		nextPutAll: (selector ifNil: ['?'])
]

{ #category : 'displaying' }
RowanMethodService >> displayString [
	^selector
]

{ #category : 'displaying' }
RowanMethodService >> displayStringFor: displayThing [
	isExtension
		ifTrue: 
			[displayThing forecolor: Color darkMagenta.
			inSelectedPackage ifFalse: [displayThing font beUnderlined ]]
]

{ #category : 'comparing' }
RowanMethodService >> equalBeforeRename: aMethodService [
	^renamedName = aMethodService className
		and: [selector = aMethodService selector and: [meta = aMethodService meta]]
]

{ #category : 'accessing' }
RowanMethodService >> failedCompile [
	^failedCompile
]

{ #category : 'accessing' }
RowanMethodService >> firstReference [
	^firstReference
]

{ #category : 'accessing' }
RowanMethodService >> firstReference: integer [
	firstReference := integer
]

{ #category : 'accessing' }
RowanMethodService >> fullSelector [

	| stream |
	stream := WriteStream on: String new. 
	self printFullSelectorOn: stream. 
	^stream contents
]

{ #category : 'accessing' }
RowanMethodService >> hasMethodHistory [

	^hasMethodHistory
]

{ #category : 'accessing' }
RowanMethodService >> hasSubs [
	^hasSubs
]

{ #category : 'accessing' }
RowanMethodService >> hasSubs: anObject [
	hasSubs := anObject
]

{ #category : 'accessing' }
RowanMethodService >> hasSupers [
	^hasSupers
]

{ #category : 'accessing' }
RowanMethodService >> hasSupers: anObject [
	hasSupers := anObject
]

{ #category : 'comparing' }
RowanMethodService >> hash [
	^(selector hash bitXor: className hash) bitXor: meta hash
]

{ #category : 'accessing' }
RowanMethodService >> homeMethodOop [
	^homeMethodOop
]

{ #category : 'public' }
RowanMethodService >> icon [
	testResult ifNil: [^self class icon].
	testResult = 'passed' ifTrue: [^true icon].
	testResult = 'failure' ifTrue: [^Warning icon].
	testResult = 'error' ifTrue: [^false icon].
	^self class icon
]

{ #category : 'method accessing' }
RowanMethodService >> implementorsOf: aString [

	^methodDefinitions
]

{ #category : 'public' }
RowanMethodService >> inSelectedPackage [

	^inSelectedPackage
]

{ #category : 'accessing' }
RowanMethodService >> inSelectedPackage: anObject [
	inSelectedPackage := anObject
]

{ #category : 'constants' }
RowanMethodService >> indexOfFirstReferenceInstVar [

	^35
]

{ #category : 'constants' }
RowanMethodService >> indexOfSourceInstVar [
	^8
]

{ #category : 'constants' }
RowanMethodService >> indexOfStepPointsInstVar [
	^22
]

{ #category : 'constants' }
RowanMethodService >> indexOfTestResultInstVar [
	^31
]

{ #category : 'initialization' }
RowanMethodService >> initialize [
	super initialize.
	inSelectedPackage := true.
	failedCompile := false.
	meta := false.
	stepPoints := Array new.
	breakPoints := OrderedCollection new.
	hasSupers := false.
	hasSubs := false.
	hasMethodHistory := true.
	isExtension := false.
	inSelectedPackage := true
]

{ #category : 'accessing' }
RowanMethodService >> isExtension [
	^isExtension
]

{ #category : 'public' }
RowanMethodService >> isMethodService [

	^true
]

{ #category : 'public' }
RowanMethodService >> isReadOnly [

	self rowanFixMe.
	^false
]

{ #category : 'public' }
RowanMethodService >> isTestMethod [
	^isTestMethod
]

{ #category : 'printing' }
RowanMethodService >> logReceivedOn: aStream [
	super logReceivedOn: aStream.
	aStream
		space;
		nextPutAll: className;
		nextPutAll: '>>';
		nextPutAll: selector
]

{ #category : 'printing' }
RowanMethodService >> logSentOn: aStream [
	super logSentOn: aStream.
	aStream
		space;
		nextPutAll: className;
		nextPutAll: '>>';
		nextPutAll: selector
]

{ #category : 'accessing' }
RowanMethodService >> meta [
	^meta
]

{ #category : 'accessing' }
RowanMethodService >> meta: anObject [
	meta := anObject
]

{ #category : 'accessing' }
RowanMethodService >> methodDefinitions [
	^methodDefinitions
]

{ #category : 'accessing' }
RowanMethodService >> methodDefinitions: anObject [
	methodDefinitions := anObject.
	self trigger: #changed
]

{ #category : 'public' }
RowanMethodService >> methodHistoryUpdated: historyBrowser [
	
	^historyBrowser methodHistoryUpdated: self
]

{ #category : 'public' }
RowanMethodService >> methodListUpdate: presenter browser: browser [
	browser updateMethodList: self
]

{ #category : 'accessing' }
RowanMethodService >> methodName [
	"for the old sunit in class browser tab"
	^selector
]

{ #category : 'public' }
RowanMethodService >> methodsRemoved: presenter [ 
	presenter list remove: self
]

{ #category : 'accessing' }
RowanMethodService >> name [
	selector isNil ifTrue:[^String new].
	^selector asString
]

{ #category : 'public' }
RowanMethodService >> oop [

	^oop
]

{ #category : 'public' }
RowanMethodService >> oopType [

	^OopType64 fromInteger: oop
]

{ #category : 'accessing' }
RowanMethodService >> packageName [
	^packageName
]

{ #category : 'accessing' }
RowanMethodService >> packageName: anObject [
	packageName := anObject
]

{ #category : 'accessing' }
RowanMethodService >> positiveBreakpoints [
	^breakPoints collect: [:bp | bp abs]
]

{ #category : 'replication' }
RowanMethodService >> preUpdate: browser [

	super preUpdate: browser. 
	selectedPackageServices := browser selectedPackageServices
]

{ #category : 'public' }
RowanMethodService >> prepareForReplication [
	super prepareForReplication.
	self basicPrepareForReplication
]

{ #category : 'printing' }
RowanMethodService >> printFullSelectorOn: aStream [

	aStream nextPutAll: className asString.
	self meta ifTrue: [
		aStream
			nextPut: Character space;
			nextPutAll: 'class' ].
	aStream
		nextPutAll: '>>';
		nextPutAll: selector asString
]

{ #category : 'printing' }
RowanMethodService >> printOn: target [
	"Append, to the <puttableStream>, target, a string whose characters are a 
	the same as those which would result from sending a #printString
	message to the receiver.
	N.B. This is really intended for development use. #displayOn: and #displayString
	are complementary methods for generating strings for presentation to an
	end-user."

	| serviceClassName |
	serviceClassName := self class name.

	[
	target
		nextPutAll: (serviceClassName first isVowel
				 ifTrue: [ 'an ' ]
				 ifFalse: [ 'a ' ]);
		nextPutAll: serviceClassName;
		nextPut: $..
	self printFullSelectorOn: target.
	target
		nextPut: $);
		space;
		nextPut: $(;
		nextPutAll: command printString;
		nextPutAll: '->';
		nextPutAll: commandArgs printString;
		nextPut: $) ]
		on: Error
		do: [ :ex |
			target
				nextPutAll: 'Error in RowanMethodService>>printOn: ';
				print: ex ]
]

{ #category : 'accessing' }
RowanMethodService >> projectName [
	^projectName
]

{ #category : 'accessing' }
RowanMethodService >> projectName: anObject [
	projectName := anObject
]

{ #category : 'accessing' }
RowanMethodService >> references [
	^references
]

{ #category : 'accessing' }
RowanMethodService >> references: anObject [
	references := anObject
]

{ #category : 'must not strip' }
RowanMethodService >> remoteServiceName [
	^'Rowan methodServiceClass'
]

{ #category : 'method menu support' }
RowanMethodService >> removeJadeiteSeparatorFrom: aMenu [
	| last |
	last := aMenu items last.
	last id = #jadeiteDivider ifTrue: [aMenu removeItem: last]
]

{ #category : 'accessing' }
RowanMethodService >> renamedName [
	^renamedName
]

{ #category : 'accessing' }
RowanMethodService >> renamedName: anObject [
	renamedName := anObject
]

{ #category : 'public' }
RowanMethodService >> replicateFrom: newService [

	^ self = newService and: [
		  (self = newService or: [ newService equalBeforeRename: self ])
			  ifTrue: [
				  super replicateFrom: newService.
				  renamedName := nil ] ]
]

{ #category : 'public' }
RowanMethodService >> rowanPostUpdate [
	super rowanPostUpdate.
	renamedName := nil
]

{ #category : 'accessing' }
RowanMethodService >> searchString [
	^searchString
]

{ #category : 'accessing' }
RowanMethodService >> searchString: anObject [
	searchString := anObject
]

{ #category : 'accessing' }
RowanMethodService >> selectedPackageServices [
	^selectedPackageServices
]

{ #category : 'accessing' }
RowanMethodService >> selectedPackageServices: anObject browser: anObject1 [
	selectedPackageServices := anObject
]

{ #category : 'accessing' }
RowanMethodService >> selector [
	^selector
]

{ #category : 'accessing' }
RowanMethodService >> selector: anObject [
	selector := anObject
]

{ #category : 'printing' }
RowanMethodService >> selectorPrintString [

	| ws |
	ws := WriteStream on: String new.
	ws nextPutAll: className.
	meta ifTrue: [
		ws
			space;
			nextPutAll: 'class';
			space ].
	ws
		nextPutAll: '>>';
		nextPutAll: selector.
	^ ws contents
]

{ #category : 'displaying' }
RowanMethodService >> selectorsDisplayString [

	^className, '>>', selector
]

{ #category : 'public' }
RowanMethodService >> setError [
	testResult := 'error'
]

{ #category : 'public' }
RowanMethodService >> setFailure [
	testResult := 'failure'
]

{ #category : 'public' }
RowanMethodService >> setPassed [
	testResult := 'passed'
]

{ #category : 'public' }
RowanMethodService >> shouldReplicateInstVarAtIndex: index newService: newService [
	"first reference is only valid on the first return of a method service for a particular browser. 
	It may be better to (someday) move firstReference to the browser state"

	| isTestResultInstVar |
	(super shouldReplicateInstVarAtIndex: index newService: newService)
		ifFalse: [ ^ false ].
	index = self indexOfFirstReferenceInstVar ifTrue: [
		firstReference ifNotNil: [ ^ false ] ].
	isTestResultInstVar := self indexOfTestResultInstVar = index.
	isTestResultInstVar ifTrue: [ ^ false ].
	self indexOfSourceInstVar = index ifTrue: [
		^ newService source isNil not ]. "fastRefresh nils out stepPoints and sources for performance"
	self indexOfStepPointsInstVar = index ifTrue: [
		^ newService stepPoints isNil not ].
	^ self indexOfSourceInstVar = index and: [
		  (newService instVarAt: index) notNil ]
]

{ #category : 'accessing' }
RowanMethodService >> sortAspect [

	^selector
]

{ #category : 'accessing' }
RowanMethodService >> source [
	^source
]

{ #category : 'accessing' }
RowanMethodService >> source: anObject [ 
	source := anObject
]

{ #category : 'presenter support' }
RowanMethodService >> stepPointFromCursorIn: methodSourcePresenter [
	| charIndex |
	charIndex := methodSourcePresenter cursorPositionIndex.
	^self stepPointFromCursorIn: methodSourcePresenter cursorPosition: charIndex
]

{ #category : 'presenter support' }
RowanMethodService >> stepPointFromCursorIn: methodSourcePresenter cursorPosition: cursorPosition [

	self stepPoints size to: 1 by: -1 do: [ :index |
		((self stepPointRangeFrom: (self stepPoints at: index)) includes:
			 cursorPosition) ifTrue: [ ^ index ] ].
	^ nil"default bp to start of method if cursor isn't on a step point"
]

{ #category : 'presenter support' }
RowanMethodService >> stepPointRangeFrom: stepPointAssoc [
	"anonymous methods don't have selector"

	| start stop |
	start := stepPointAssoc key.
	stop := start = 1
		        ifTrue: [
			        selector
				        ifNil: [ start ]
				        ifNotNil: [ start + (selector copyUpThrough: $:) size ] ]
		        ifFalse: [
		        start + (stepPointAssoc value last copyUpThrough: $:) size ].
	^ start to: stop
]

{ #category : 'public' }
RowanMethodService >> stepPoints [
	self todo:[
	(stepPoints notEmpty and: [stepPoints first key isInteger])
		ifTrue: 
			[stepPoints := stepPoints collect: 
							[:each |
							| range start char length |
							self todo:[start := source indexOfNth: each key "handle unicode"] inTheMeanTime: [start := each key].
							self todo:[char := [source codePointAt: start] on: BoundsError do:[:ex | source last]] inTheMeanTime: [char := source at: start].
							length := (char isAlphaNumeric or: [char = $_])
										ifTrue: 
											[(source copyFrom: start + 1 to: source size)
												findFirst: [:eachChar | (eachChar isAlphaNumeric or: [eachChar = $_ or: [eachChar = $:]]) not]]
										ifFalse: [2].
							length = 0 ifTrue: [length := source size - start + 1].
							[2 < length and: [(source at: start) = $_]] whileTrue: 
									[start := start + 1.
									length := length - 1].
							range := Interval from: start to: start + length - 1.
							range -> each value]]].
	^stepPoints
]

{ #category : 'displaying' }
RowanMethodService >> subSuperIcon [
	^(self basicSubSuperIcon) imageIndex
]

{ #category : 'accessing' }
RowanMethodService >> superDisplayString [
	^superDisplayString
]

{ #category : 'accessing' }
RowanMethodService >> superDisplayString: anObject [
	superDisplayString := anObject
]

{ #category : 'accessing' }
RowanMethodService >> testResult [
	^testResult
]

{ #category : 'accessing' }
RowanMethodService >> testResult: anObject [
	testResult := anObject
]

{ #category : 'accessing' }
RowanMethodService >> testResultIconForBrowser: browser [
	^ IconicButtonMorph new
		  target: browser;
		  labelGraphic: (testResult
				   ifNil: [ Smalltalk ui icons iconNamed: #testNotRun ]
				   ifNotNil: [
					   Smalltalk ui icons iconNamed:
							   (self testResultMap at: testResult) ]);
		  actionSelector: #debugTests:;
		  arguments: (Array with: { self });
		  color: Color transparent;
		  helpText: 'Run Tests';
		  borderWidth: 0;
		  yourself
]

{ #category : 'accessing' }
RowanMethodService >> testResultMap [

	| map |
	map := Dictionary new.
	map
		at: #passed put: #testGreen;
		at: #failure put: #testYellow;
		at: #error put: #testRed.
	^map
]

{ #category : 'public' }
RowanMethodService >> testResultUpdate: presenter browser: browser [

	| existingService |
	existingService := presenter list
		                   detect: [ :methodService | methodService = self ]
		                   ifNone: [ ^ self ].
	testRunClassName ifNotNil: [
		browser selectedClass name = testRunClassName ifFalse: [ ^ self ] ].
	existingService testResult: self testResult.
	presenter view invalidate
]

{ #category : 'accessing' }
RowanMethodService >> toolTip [
	| ws |
	ws := WriteStream on: String new.
	ws
		nextPutAll: 'Defined package: ';
		nextPutAll: definedPackage;
		cr;
		nextPutAll: 'Category: '; 
		nextPutAll: category.
	^ws contents
]

{ #category : 'public' }
RowanMethodService >> unimplementedSelectors [

	self rowanFixMe.
	^#()
]

{ #category : 'public' }
RowanMethodService >> updateBreakPoints: presenter browser: browser [
	presenter view invalidate
]

{ #category : 'private' }
RowanMethodService >> updateSelectorFromCompiledMethod: aString [

	| stream | 
	stream := ReadStream on: aString. 
	stream skipWhile:[:char | char isDigit].
	selector := stream upToEnd. 



]

{ #category : 'accessing' }
RowanMethodService >> user [
	^user
]

{ #category : 'accessing' }
RowanMethodService >> user: anObject [
	user := anObject
]

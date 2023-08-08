Class {
	#name : 'JadeMethodListPresenter',
	#superclass : 'JadeBrowserPresenter',
	#instVars : [
		'methodListPresenter',
		'methodSourcePresenter',
		'searchBlock'
	],
	#classVars : [
		'JadeMethodBrowserPresenterClass'
	],
	#category : 'JadeiteMethodBrowser'
}

{ #category : 'as yet unclassified' }
JadeMethodListPresenter class >> getJadeMethodBrowserPresenterClass [

	JadeMethodBrowserPresenterClass ifNil: [JadeMethodBrowserPresenterClass := JadeMethodListPresenter].

	^JadeMethodBrowserPresenterClass
]

{ #category : 'as yet unclassified' }
JadeMethodListPresenter class >> getJadeShellViewName [

	^(self getJadeMethodBrowserPresenterClass == JadeMethodListPresenter) 
	ifTrue: ['List view']
	ifFalse: ['Tree view']
]

{ #category : 'as yet unclassified' }
JadeMethodListPresenter class >> resource_Default_view [
	"Answer the literal data from which the 'Default view' resource can be reconstituted.
	DO NOT EDIT OR RECATEGORIZE THIS METHOD.

	If you wish to modify this resource evaluate:
	ViewComposer openOn: (ResourceIdentifier class: self selector: #resource_Default_view)
	"

	^#(#'!STL' 3 788558 10 ##(Smalltalk.STBViewProxy)  8 ##(Smalltalk.ContainerView)  98 15 0 0 98 2 8 1409286144 131073 416 0 0 0 5 0 0 0 416 1180166 ##(Smalltalk.ProportionalLayout)  234 240 98 4 410 8 ##(Smalltalk.ReferenceView)  98 14 0 416 98 2 8 1140850688 131073 560 0 524550 ##(Smalltalk.ColorRef)  8 4278190080 0 5 0 0 0 560 1180166 ##(Smalltalk.ResourceIdentifier)  8 ##(Smalltalk.MethodListPresenter)  8 #resource_MultiClass_view 0 983302 ##(Smalltalk.MessageSequence)  202 208 98 1 721670 ##(Smalltalk.MessageSend)  8 #createAt:extent: 98 2 328198 ##(Smalltalk.Point)  1 1 882 1201 351 560 983302 ##(Smalltalk.WINDOWPLACEMENT)  8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 88 2 0 0 175 0 0 0] 98 0 882 193 193 0 27 9 410 576 98 14 0 416 98 2 8 1140850688 131073 1008 0 642 672 0 5 0 0 0 1008 690 8 ##(Smalltalk.MethodSourcePresenter)  8 #resource_Default_view 0 754 202 208 98 1 818 848 98 2 882 1 361 882 1201 441 1008 930 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 180 0 0 0 88 2 0 0 144 1 0 0] 976 992 0 27 11 16 234 256 98 4 560 8 'methodList' 1008 8 'methodSource' 0 754 202 208 98 1 818 848 98 2 882 2799 21 882 1201 801 416 930 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 119 5 0 0 10 0 0 0 207 7 0 0 154 1 0 0] 98 3 560 410 8 ##(Smalltalk.Splitter)  98 12 0 416 98 2 8 1140850688 1 1504 0 642 8 4278190080 0 517 0 0 0 1504 754 202 208 98 1 818 848 98 2 882 1 351 882 1201 11 1504 930 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 175 0 0 0 88 2 0 0 180 0 0 0] 98 0 992 0 27 1008 992 0 27 )
]

{ #category : 'as yet unclassified' }
JadeMethodListPresenter class >> setJadeMethodBrowserPresenterClass: aJadeMethodListPresenterClass [

	JadeMethodBrowserPresenterClass := aJadeMethodListPresenterClass
]

{ #category : 'as yet unclassified' }
JadeMethodListPresenter class >> setListView [

	self setJadeMethodBrowserPresenterClass: JadeMethodListPresenter
]

{ #category : 'as yet unclassified' }
JadeMethodListPresenter class >> setTreeView [

	self setJadeMethodBrowserPresenterClass: JadeTreeMethodListPresenter
]

{ #category : 'as yet unclassified' }
JadeMethodListPresenter >> browse: performSelector gsMethod: aGsMethod [

	| string |
	string := self gciSession 
		serverPerform: performSelector
		with: aGsMethod.
	self browseMethodsFromString: string.

]

{ #category : 'as yet unclassified' }
JadeMethodListPresenter >> browse: performSelector method: aGsMethodOrString [

	| string |

	(aGsMethodOrString isKindOf: String) ifTrue: [
		self browse: performSelector methodSelector: aGsMethodOrString.
		string := aGsMethodOrString.
	] ifFalse: [
		self browse: performSelector gsMethod: aGsMethodOrString.
		string := aGsMethodOrString name.
	].
	self selecting: string.

]

{ #category : 'as yet unclassified' }
JadeMethodListPresenter >> browse: performSelector methodSelector: aString [

	| string |
	string := self gciSession 
		serverPerform: performSelector
		with: aString.
	self browseMethodsFromString: string.

]

{ #category : 'as yet unclassified' }
JadeMethodListPresenter >> browseMethods: aGsMethodColl [

	| string |
	string := self gciSession 
		serverPerform: #streamOfMethods:
		with: aGsMethodColl.
	self browseMethodsFromString: string.

]

{ #category : 'as yet unclassified' }
JadeMethodListPresenter >> browseMethodsContaining: aString [

	self
		browse: #'methodsContaining:' 
		method: aString.

]

{ #category : 'as yet unclassified' }
JadeMethodListPresenter >> browseMethodsFromString: aString [

	| list |
	list := GsMethod2
		listFromString: aString
		session: self gciSession.
	methodListPresenter list: list asSortedCollection.
	list notEmpty ifTrue: [
		methodListPresenter selectFirstMethod.
	].

]

{ #category : 'as yet unclassified' }
JadeMethodListPresenter >> browseMethodsFromString: aString methodName: methodName [
	| list |

	list := GsMethod2
		listFromString: aString
		session: self gciSession.
	methodListPresenter list: list asSortedCollection.
	list notEmpty ifTrue: [
		methodListPresenter selectFirstMethod.
	].
]

{ #category : 'as yet unclassified' }
JadeMethodListPresenter >> browseMethodsFromString: aString methodName: methodName type: browseType [
	| list |
	list := GsMethod2
		listFromString: aString
		session: self gciSession.
	methodListPresenter list: list asSortedCollection.
	list notEmpty ifTrue: [
		methodListPresenter selectFirstMethod.
	].
]

{ #category : 'as yet unclassified' }
JadeMethodListPresenter >> codePresenterIsMethod [

	^true
]

{ #category : 'as yet unclassified' }
JadeMethodListPresenter >> createComponents [

	super createComponents.
	methodListPresenter 	:= self add: MethodListPresenter	new name: 'methodList'.
	methodSourcePresenter	:= (self add: MethodSourcePresenter	new name: 'methodSource') menuTitle: '&Method Source'; yourself.

]

{ #category : 'as yet unclassified' }
JadeMethodListPresenter >> createSchematicWiring [

	super createSchematicWiring.
	methodListPresenter
		when: #'methodSelectionChanged'	send: #'updateSource'		to: self;
		when: #'selectionChanging:'		send: #'selectionChanging:'	to: self;
		when: #'leftButtonPressed:'		send: #'onLeftButtonPressed:'	to: self;
		yourself.
	methodSourcePresenter
		when: #'needUser'				send: #'userSelection'			to: self;
		when: #'savedMethod:inClass:' 		send: #'doSearch'			to: self;
		yourself.

]

{ #category : 'as yet unclassified' }
JadeMethodListPresenter >> doSearch [

	searchBlock notNil ifTrue: [searchBlock value].

]

{ #category : 'as yet unclassified' }
JadeMethodListPresenter >> gciSession: aGciSession [

	super gciSession: aGciSession.
	methodListPresenter gciSession: aGciSession .
	methodSourcePresenter gciSession: aGciSession.

]

{ #category : 'as yet unclassified' }
JadeMethodListPresenter >> getOopToNewMethod [
	"The receiver answer <aOopType64> to the new method"

	self halt.
	^gciSession executeString: (self getSelectedClassName, ' perform: #compiledMethodAt: with: #',  self getSelectedMethodName)

]

{ #category : 'as yet unclassified' }
JadeMethodListPresenter >> getSelectedMethod [

	^methodListPresenter selectedMethod
]

{ #category : 'as yet unclassified' }
JadeMethodListPresenter >> getSelectedMethodName [

	^self getSelectedMethod name
]

{ #category : 'as yet unclassified' }
JadeMethodListPresenter >> insertIfFalse [
	^self insertIfFalse: methodSourcePresenter documentPresenter
]

{ #category : 'as yet unclassified' }
JadeMethodListPresenter >> insertIfTrue [
	^self insertIfTrue: methodSourcePresenter documentPresenter
]

{ #category : 'as yet unclassified' }
JadeMethodListPresenter >> jadeMenuStrings [

	false ifTrue: [
		self abortTransaction; commitTransaction; beginTransaction; newWorkspace; newProjectsBrowser; exit
	]. 
	^#(
		'&Jadeite'
		'&Abort Transaction//abortTransaction'
		'&Commit Transaction//commitTransaction'
		'&Begin Transaction//beginTransaction'
		'-'
		'&New Workspace/Ctrl+N/newWorkspace'
		'&Open Projects Browser/Ctrl+P/newProjectsBrowser'
		'E&xit/Shift+F4/exit'
	).

]

{ #category : 'as yet unclassified' }
JadeMethodListPresenter >> methodListPresenter [

	^methodListPresenter
]

{ #category : 'as yet unclassified' }
JadeMethodListPresenter >> onLeftButtonPressed: aMouseEvent [
	"don't think we want to do this anymore. Leave hooks in just in case" 
	"[self doSearch] forkAt: Processor userBackgroundPriority."

]

{ #category : 'as yet unclassified' }
JadeMethodListPresenter >> searchFor: aString [

	| sourceView selectionRange textRange found |
	sourceView := methodSourcePresenter view viewNamed: 'document'.
	selectionRange := sourceView selectionRange.
	textRange := sourceView textRange.
	found := sourceView
		find: aString
		range: (selectionRange stop + 1 to: textRange stop)
		flags: 4 + 2. "SCFIND_MATCHCASE + SCFIND_WHOLEWORD"
	0 < found stop ifTrue: [
		sourceView
			selectionStart: found start 
			end: found stop.
		sourceView ensureVisible: found stop.
	].

]

{ #category : 'as yet unclassified' }
JadeMethodListPresenter >> selectFirstMethod [

	methodListPresenter selectFirstMethod.

]

{ #category : 'as yet unclassified' }
JadeMethodListPresenter >> selectedCategory [

	| method |
	(method := methodListPresenter selectedMethod) notNil ifTrue: [
		^method category.
	].
	^'as yet unclassified'.

]

{ #category : 'as yet unclassified' }
JadeMethodListPresenter >> selectedClass [

	| methodService |
	(methodService := self methodListPresenter selectionOrNil) isNil 
		ifTrue: [ ^ nil ].
	^ (RowanClassServiceClient new name: methodService className) meta:
		  methodService meta
]

{ #category : 'as yet unclassified' }
JadeMethodListPresenter >> selecting: stringOrIndex [
	self todo:[stringOrIndex isNumber
		ifTrue: 
			[| range stream |
			stream := ReadStream on: methodSourcePresenter documentPresenter value.
			stream position: stringOrIndex.
			stream nextWord.
			range := Interval from: stringOrIndex to: stream position - 1.
			methodSourcePresenter documentPresenter selectionRange: range]
		ifFalse: 
			[searchBlock := [self searchFor: stringOrIndex].
			self doSearch].
	methodSourcePresenter documentPresenter view ensureCaretVisible]
]

{ #category : 'as yet unclassified' }
JadeMethodListPresenter >> selectingAnyMatch: aString [
	searchBlock := [self searchForAnyTextMatching: aString].
	self doSearch
]

{ #category : 'as yet unclassified' }
JadeMethodListPresenter >> updateMenuBar: aMenuBar [

	| menu |
	menu := Menu fromStrings: self jadeMenuStrings.
	aMenuBar addItem: menu.
	methodListPresenter updateMenuBar: aMenuBar.

]

{ #category : 'as yet unclassified' }
JadeMethodListPresenter >> updateSaveMethodOop: anInteger [

	| newGsMethod |  
 	methodListPresenter selectedMethod isNil ifTrue: [^self].

	newGsMethod := methodListPresenter selectedMethod copy
		oopType: (gciSession oopTypeWithOop: anInteger);
		yourself.
	methodListPresenter primaryPresenter model add: newGsMethod.

 	methodListPresenter primaryPresenter model remove: methodListPresenter selectedMethod ifAbsent: [].

	methodListPresenter primaryPresenter selection: newGsMethod.

]

{ #category : 'as yet unclassified' }
JadeMethodListPresenter >> updateSource [
	| gsClass gsMethod2 gsMethod |
	(gsClass := self selectedClass)
		ifNotNil: 
			[(gsMethod2 := methodListPresenter selectedMethod)
				ifNotNil: 
					[gsMethod2 gsClass ~= gsClass ifTrue: [self error: 'Method not from selected class!'].
					gsMethod := GsMethod fromOopType: gsMethod2 oopType session: gsMethod2 gciSession]].
	gsMethod
		ifNotNil: 
			[methodSourcePresenter gsMethod: gsMethod.
			self doSearch].
	methodListPresenter selectedMethod ifNil: [^self].
	self displayUncompilableSourceIn: methodSourcePresenter documentPresenter
		
]

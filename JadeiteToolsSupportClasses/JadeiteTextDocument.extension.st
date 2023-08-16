Extension { #name : 'JadeiteTextDocument' }

{ #category : '*JadeiteToolsSupportClasses' }
JadeiteTextDocument class >> buildCommandsGroupWith: presenter forRoot: aCmCommandsGroup [

	super buildCommandsGroupWith: presenter forRoot: aCmCommandsGroup.
	self registerFileActionsWithCommandGroup: aCmCommandsGroup. 
	self registerSourceActionsWithCommandGroup: aCmCommandsGroup
]

{ #category : '*JadeiteToolsSupportClasses' }
JadeiteTextDocument >> caption: aString [

	self owner title: aString
]

{ #category : '*JadeiteToolsSupportClasses' }
JadeiteTextDocument >> currentSelectionOrLine [

	^self selectedTextOrLine
]

{ #category : '*JadeiteToolsSupportClasses' }
JadeiteTextDocument >> evaluate: aString onCompileError: compileErrorBlock onError: errorBlock [ 
	^self executeSelectionOrLine: aString shouldDebug: false onCompileError: compileErrorBlock
]

{ #category : '*JadeiteToolsSupportClasses' }
JadeiteTextDocument >> evaluateInspectingResult: aString onCompileError: compileErrorBlock onError: errorBlock [ 
	^self executeSelectionOrLineInspectingResult: aString shouldDebug: false
]

{ #category : '*JadeiteToolsSupportClasses' }
JadeiteTextDocument >> executeSelectionOrLineInspectingResult: aString shouldDebug: aBoolean [

	^ JadeiteInspectorApplication
		  executeThenShowOn: aString
		  session: gciSession
		  context: (context ifNil: [ 20 ])
]

{ #category : '*JadeiteToolsSupportClasses' }
JadeiteTextDocument >> filename [

	^nil
]

{ #category : '*JadeiteToolsSupportClasses' }
JadeiteTextDocument >> parentPresenter [ 
	^application 
]

{ #category : '*JadeiteToolsSupportClasses' }
JadeiteTextDocument class >> registerFileActionsWithCommandGroup: commandGroup [

	| group |
	group := (CmCommandGroup named: 'File actions') asSpecGroup
		         description: 'Perform file operations';
		         yourself.

	group register: JadeiteFileInServerFileCommand forSpec.
	group register: JadeiteFileInSelectedTextCommand forSpec.

	commandGroup register: group
]

{ #category : '*JadeiteToolsSupportClasses' }
JadeiteTextDocument class >> registerSourceActionsWithCommandGroup: commandGroup [
]

{ #category : '*JadeiteToolsSupportClasses' }
JadeiteTextDocument >> selection [

	^self selectedTextOrLine 
]

{ #category : '*JadeiteToolsSupportClasses' }
JadeiteTextDocument >> updateCaption [
	self subclassResponsibility
]

{ #category : '*JadeiteToolsSupportClasses' }
JadeiteTextDocument >> updateCaption: aString [

	self owner titleText: aString
]

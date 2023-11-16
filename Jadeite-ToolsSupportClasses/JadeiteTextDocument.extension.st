Extension { #name : 'JadeiteTextDocument' }

{ #category : '*Jadeite-ToolsSupportClasses' }
JadeiteTextDocument class >> buildCommandsGroupWith: presenter forRoot: aCmCommandsGroup [

	super buildCommandsGroupWith: presenter forRoot: aCmCommandsGroup.
	self registerFileActionsWithCommandGroup: aCmCommandsGroup. 
	self registerSourceActionsWithCommandGroup: aCmCommandsGroup
]

{ #category : '*Jadeite-ToolsSupportClasses' }
JadeiteTextDocument >> caption: aString [

	self owner title: aString
]

{ #category : '*Jadeite-ToolsSupportClasses' }
JadeiteTextDocument >> currentSelectionOrLine [

	^self selectedTextOrLine
]

{ #category : '*Jadeite-ToolsSupportClasses' }
JadeiteTextDocument >> evaluate: aString onCompileError: compileErrorBlock onError: errorBlock [ 
	^self executeSelectionOrLine: aString shouldDebug: false onCompileError: compileErrorBlock
]

{ #category : '*Jadeite-ToolsSupportClasses' }
JadeiteTextDocument >> evaluateInspectingResult: aString onCompileError: compileErrorBlock onError: errorBlock [ 
	^self executeSelectionOrLineInspectingResult: aString shouldDebug: false
]

{ #category : '*Jadeite-ToolsSupportClasses' }
JadeiteTextDocument >> executeSelectionOrLineInspectingResult: aString shouldDebug: aBoolean [

	^ JadeiteInspectorApplication
		  executeThenShowOn: aString
		  session: gciSession
		  context: (context ifNil: [ 20 ])
]

{ #category : '*Jadeite-ToolsSupportClasses' }
JadeiteTextDocument >> filename [

	^nil
]

{ #category : '*Jadeite-ToolsSupportClasses' }
JadeiteTextDocument >> parentPresenter [ 
	^application 
]

{ #category : '*Jadeite-ToolsSupportClasses' }
JadeiteTextDocument class >> registerFileActionsWithCommandGroup: commandGroup [

	| group |
	group := (CmCommandGroup named: 'File actions') asSpecGroup
		         description: 'Perform file operations';
		         yourself.

	group register: JadeiteFileInServerFileCommand forSpec.
	group register: JadeiteFileInSelectedTextCommand forSpec.

	commandGroup register: group
]

{ #category : '*Jadeite-ToolsSupportClasses' }
JadeiteTextDocument class >> registerSourceActionsWithCommandGroup: commandGroup [
]

{ #category : '*Jadeite-ToolsSupportClasses' }
JadeiteTextDocument >> selection [

	^self selectedTextOrLine 
]

{ #category : '*Jadeite-ToolsSupportClasses' }
JadeiteTextDocument >> updateCaption [
	self subclassResponsibility
]

{ #category : '*Jadeite-ToolsSupportClasses' }
JadeiteTextDocument >> updateCaption: aString [

	self owner titleText: aString
]

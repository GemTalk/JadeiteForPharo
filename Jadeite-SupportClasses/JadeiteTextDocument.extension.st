Extension { #name : 'JadeiteTextDocument' }

{ #category : '*Jadeite-SupportClasses' }
JadeiteTextDocument class >> buildCommandsGroupWith: presenter forRoot: aCmCommandsGroup [

	super buildCommandsGroupWith: presenter forRoot: aCmCommandsGroup.
	self registerFileActionsWithCommandGroup: aCmCommandsGroup. 
	self registerSourceActionsWithCommandGroup: aCmCommandsGroup
]

{ #category : '*Jadeite-SupportClasses' }
JadeiteTextDocument >> caption: aString [

	self owner title: aString
]

{ #category : '*Jadeite-SupportClasses' }
JadeiteTextDocument >> currentSelectionOrLine [

	^self selectedTextOrLine
]

{ #category : '*Jadeite-SupportClasses' }
JadeiteTextDocument >> evaluate: aString onCompileError: compileErrorBlock onError: errorBlock [ 
	^self executeSelectionOrLine: aString shouldDebug: false onCompileError: compileErrorBlock
]

{ #category : '*Jadeite-SupportClasses' }
JadeiteTextDocument >> evaluateInspectingResult: aString onCompileError: compileErrorBlock onError: errorBlock [ 
	^self executeSelectionOrLineInspectingResult: aString shouldDebug: false
]

{ #category : '*Jadeite-SupportClasses' }
JadeiteTextDocument >> executeSelectionOrLineInspectingResult: aString shouldDebug: aBoolean [

	^ JadeiteInspectorApplication
		  executeThenShowOn: aString
		  session: gciSession
		  context: (context ifNil: [ 20 ])
]

{ #category : '*Jadeite-SupportClasses' }
JadeiteTextDocument >> filename [

	^nil
]

{ #category : '*Jadeite-SupportClasses' }
JadeiteTextDocument >> parentPresenter [ 
	^application 
]

{ #category : '*Jadeite-SupportClasses' }
JadeiteTextDocument class >> registerFileActionsWithCommandGroup: commandGroup [

	| group |
	group := (CmCommandGroup named: 'File actions') asSpecGroup
		         description: 'Perform file operations';
		         yourself.

	group register: JadeiteFileInServerFileCommand forSpec.
	group register: JadeiteFileInSelectedTextCommand forSpec.

	commandGroup register: group
]

{ #category : '*Jadeite-SupportClasses' }
JadeiteTextDocument class >> registerSourceActionsWithCommandGroup: commandGroup [
	| command |
	command := JadeiteSelectAllCommand new.
	commandGroup register: command asSpecCommand
]

{ #category : '*Jadeite-SupportClasses' }
JadeiteTextDocument >> selection [

	^self selectedTextOrLine 
]

{ #category : '*Jadeite-SupportClasses' }
JadeiteTextDocument >> updateCaption [
	self subclassResponsibility
]

{ #category : '*Jadeite-SupportClasses' }
JadeiteTextDocument >> updateCaption: aString [

	self owner titleText: aString
]

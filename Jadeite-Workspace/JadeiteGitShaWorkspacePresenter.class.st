Class {
	#name : 'JadeiteGitShaWorkspacePresenter',
	#superclass : 'JadeiteWorkspacePresenter',
	#instVars : [
		'copyToClipboardButton'
	],
	#category : 'Jadeite-Workspace',
	#package : 'Jadeite-Workspace'
}

{ #category : 'actions' }
JadeiteGitShaWorkspacePresenter >> copyMarkdownToClipboard: inputString [

	| lines markdownStream |
	lines := inputString lines collect: [ :ea | ea trimBlanks ].
	lines := lines reject: [ :ea | ea isEmpty ].
	lines := lines reject: [ :ea |
		         ea = '---------------------------------------------' ].
	markdownStream := WriteStream on: String new.
	markdownStream
		nextPutAll: '<details>';
		cr;
		nextPutAll: '<summary>Version Information</summary>';
		cr;
		cr.

	lines do: [ :line |
			line last = $:
				ifTrue: [
						markdownStream
							nextPutAll: (self markdownHeaderRowFrom: line);
							cr ]
				ifFalse: [
						markdownStream
							nextPutAll: (self markdownRowFrom: line);
							cr ] ].


	markdownStream nextPutAll: '</details>'.
	markdownStream contents asText copyToClipboard
]

{ #category : 'accessing' }
JadeiteGitShaWorkspacePresenter >> copyToClipboardButton [

	^ copyToClipboardButton
]

{ #category : 'accessing' }
JadeiteGitShaWorkspacePresenter >> copyToClipboardButton: anObject [

	copyToClipboardButton := anObject
]

{ #category : 'initialization' }
JadeiteGitShaWorkspacePresenter >> firstColumnFrom: rs [

	| string |
	string := rs contents.
	self specialFirstColumns do: [ :special |
		(special , '*' match: string) ifTrue: [ ^ rs next: special size ] ].
	^ rs upTo: Character space
]

{ #category : 'initialization' }
JadeiteGitShaWorkspacePresenter >> initializeButton [

	| box |
	box := SpBoxLayout newHorizontal.
	copyToClipboardButton := self newButton.
	copyToClipboardButton
		label: 'Copy to Clipboard';
		help:
			'Copy Git Commit Ids to clipboard in a more readable format when reporting a GitHub issue';
		action: [ self copyMarkdownToClipboard: workspace text ].
	box add: copyToClipboardButton withConstraints: [ :constraints |
			constraints
				width: copyToClipboardButton label size / 1.5
					* StandardFonts defaultFont pointSize;
				height: 2.5 * StandardFonts defaultFont pointSize ].

	^ box
]

{ #category : 'initialization' }
JadeiteGitShaWorkspacePresenter >> initializePresenters [

	| waitBox buttonBox |
	waitBox := self initializeWaitPresenter.
	self layout add: waitBox expand: false.
	self showNotWait.
	workspace := self workspaceClass new.
	self layout add: workspace.
	buttonBox := self initializeButton.
	self layout add: buttonBox expand: false.
	statusBarText := self newStatusBar.
	self layout
		add: statusBarText
		height: 2 * StandardFonts defaultFont pointSize
]

{ #category : 'initialization' }
JadeiteGitShaWorkspacePresenter >> markdownHeaderRowFrom: string [

	| ws |
	ws := WriteStream on: String new.
	ws
		nextPutAll: '#### ';
		nextPutAll: string;
		cr.
	^ ws contents
]

{ #category : 'initialization' }
JadeiteGitShaWorkspacePresenter >> markdownRowFrom: string [
	"most rows will be of the format first <space> rest of line"

	| row restOfLine first rs |
	rs := ReadStream on: string.
	first := self firstColumnFrom: rs.
	restOfLine := rs upToEnd trimBlanks.
	row := first , ': ' , restOfLine.
	^ row
]

{ #category : 'initialization' }
JadeiteGitShaWorkspacePresenter >> specialFirstColumns [
	"columns with more than one word"

	^ #( 'Build information:' 'Build date:' )
]

{ #category : 'initialization' }
JadeiteGitShaWorkspacePresenter >> workspaceTitle [

	^ 'Jadeite Git Commit Ids'
]

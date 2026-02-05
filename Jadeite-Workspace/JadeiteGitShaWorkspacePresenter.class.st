Class {
	#name : 'JadeiteGitShaWorkspacePresenter',
	#superclass : 'JadeiteWorkspacePresenter',
	#instVars : [
		'copyToClipboardButton'
	],
	#category : 'Jadeite-Workspace',
	#package : 'Jadeite-Workspace'
}

{ #category : 'initialization' }
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
		nextPutAll: '<summary>View Version Information</summary>';
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
JadeiteGitShaWorkspacePresenter >> initializeCopyToMarkdownButton [

	| box |
	box := SpBoxLayout newHorizontal.
	copyToClipboardButton := self newButton.
	copyToClipboardButton
		label: 'Copy to Clipboard in Markdown format';
		help:
			'Copy Git Commit Ids in Markdown format to clipboard for pasting into GitHub issue';
		action: [ self copyMarkdownToClipboard: workspace text ].
	box add: copyToClipboardButton withConstraints: [ :constraints |
			constraints
				width: copyToClipboardButton label size / 2
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
	buttonBox := self initializeCopyToMarkdownButton.
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
		nextPutAll: '## ';
		nextPutAll: string;
		cr.
	ws
		nextPutAll:
			'| Details                       | Information         |';
		cr;
		nextPutAll: '|-------------------------------|------------|'.
	^ ws contents
]

{ #category : 'initialization' }
JadeiteGitShaWorkspacePresenter >> markdownRowFrom: string [
	"most rows will be of the format first <space> rest of line"

	| markdownRow restOfLine first rs |
	rs := ReadStream on: string.
	first := self firstColumnFrom: rs.
	restOfLine := rs upToEnd trimBlanks.
	markdownRow := ' **' , first , '**' , ' | ' , restOfLine.
	^ '| ' , markdownRow , ' |'
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

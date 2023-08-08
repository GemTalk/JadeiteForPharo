Extension { #name : 'FileSaveDialog' }

{ #category : '*JadeiteTests' }
FileSaveDialog class >> on: aModel [
	"Creates an instance of the receiver connected to aModel. 
	The view is displayed modal to the current active window. 
	Answers the result of dialog if confirmed or nil otherwise"

	| testsActive |
	testsActive := Smalltalk at: #JadeiteTestsActive ifAbsent: [^super on: aModel].
	^testsActive ifTrue: [(Smalltalk at: #TestFileSaveDialog) basicNew on: aModel] ifFalse: [super on: aModel]
]

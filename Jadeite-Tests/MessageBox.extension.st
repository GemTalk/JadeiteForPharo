Extension { #name : 'MessageBox' }

{ #category : '*Jadeite-Tests' }
MessageBox class >> new [
	"#JadeiteTestsActive should never be present without the tests loaded"

	| testsActive |
	testsActive := Smalltalk at: #JadeiteTestsActive ifAbsent: [^self basicNew initialize].
	^testsActive
		ifTrue: [(Smalltalk at: #TestMessageBox) basicNew initialize]
		ifFalse: [self basicNew initialize] 
]

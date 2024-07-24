Class {
	#name : 'JadeiteInspectorTestCase',
	#superclass : 'JadeiteInspectorDataCuratorTestCase',
	#category : 'Jadeite-Tests',
	#package : 'Jadeite-Tests'
}

{ #category : 'as yet unclassified' }
JadeiteInspectorTestCase >> setUp [
	user := 'SystemUser'.
	super setUp
]

{ #category : 'as yet unclassified' }
JadeiteInspectorTestCase >> test_inspectorRootObjectRegistered [
	| remoteObject |
	self testsIssue: #issue735
		withTitle: 'In multi-monitor setupt, inconsistent locations for opening windows (3.0.93-7)'.
	remoteObject := session executeString: 'Object new'.
	inspector := JadeInspector showOn: remoteObject session: session.
	self assert: inspector view position
		equals: transcript view position + JadePresenter defaultWindowOffset
]

{ #category : 'as yet unclassified' }
JadeiteInspectorTestCase >> test_inspectorRootSpecialObjectNotRegistered [
	| remoteObject inspectorHandle |
	self testsIssue: #issue385 withTitle: 'Inspector should keep associated root object alive'.
	remoteObject := session executeString: '$a'.
	inspector := JadeInspector showOn: remoteObject session: session.
	inspectorHandle := inspector view handle value.
	self assert: (session
				executeString: '(RowanBrowserService new openWindows at: ' , inspectorHandle printString
						, ' ifAbsent:[]) first')
		equals: $a
]

{ #category : 'as yet unclassified' }
JadeiteInspectorTestCase >> test_openProjectsBrowser [
	| remoteObject shell |
	remoteObject := session
				executeString: 'RowanClassService new'
				fromContext: nil
				environment: 0.
	inspector := JadeInspector showOn: remoteObject session: session.
	shell := inspector browseClass.
	[self assert: (shell isKindOf: JadeiteBrowser)] ensure: [self destroy: shell]
]

{ #category : 'as yet unclassified' }
JadeiteInspectorTestCase >> test_openProjectsBrowserOnClass [
	| remoteObject shell |
	remoteObject := session
				executeString: 'RowanClassService'
				fromContext: nil
				environment: 0.
	inspector := JadeInspector showOn: remoteObject session: session.
	shell := inspector browseClass.
	[self assert: (shell isKindOf: JadeiteBrowser)] ensure: [self destroy: shell]
]

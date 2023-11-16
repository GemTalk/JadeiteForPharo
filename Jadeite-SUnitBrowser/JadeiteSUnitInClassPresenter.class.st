Class {
	#name : 'JadeiteSUnitInClassPresenter',
	#superclass : 'JadeiteSUnitAbstractPresenter',
	#instVars : [
		'testClassService'
	],
	#category : 'Jadeite-SUnitBrowser'
}

{ #category : 'as yet unclassified' }
JadeiteSUnitInClassPresenter >> addSystemBrowser [

	^parentPresenter addSystemBrowser
]

{ #category : 'as yet unclassified' }
JadeiteSUnitInClassPresenter >> addWorkspace [

	^self topShell addWorkspace
]

{ #category : 'as yet unclassified' }
JadeiteSUnitInClassPresenter >> basicDelete [
	testClassService
		command: #removeMethods:;
		commandArgs: (Array with: methodListPresenter selections).
	self issueCommand: testClassService
]

{ #category : 'as yet unclassified' }
JadeiteSUnitInClassPresenter >> browseClassReferences [

	^parentPresenter browseClassReferences
]

{ #category : 'as yet unclassified' }
JadeiteSUnitInClassPresenter >> browseIt [ 
	^self debug
]

{ #category : 'as yet unclassified' }
JadeiteSUnitInClassPresenter >> closeCard [
	^parentPresenter topShell closeCard
]

{ #category : 'as yet unclassified' }
JadeiteSUnitInClassPresenter >> debug [
	testClassService ifNil: [^self].
	self debugTests: methodListPresenter selections.
	methodListPresenter view invalidate
]

{ #category : 'as yet unclassified' }
JadeiteSUnitInClassPresenter >> debugTests: methodServices [
	^self debugTestMethodServices: methodServices className: self selectedClass name
]

{ #category : 'as yet unclassified' }
JadeiteSUnitInClassPresenter >> doesNotUnderstand: failedMessage [
	"a little dangerous but this is the sunit tab in the browser. The parentPresenter
	performs most of the menu operations for the browser's toolbar. A true dnu
	should get caught in the parent also"

	^failedMessage forwardTo: parentPresenter
]

{ #category : 'as yet unclassified' }
JadeiteSUnitInClassPresenter >> editFind [

	"do nothing"
]

{ #category : 'as yet unclassified' }
JadeiteSUnitInClassPresenter >> editReplace [

	"do nothing"
]

{ #category : 'as yet unclassified' }
JadeiteSUnitInClassPresenter >> editSave [

	"do nothing" 
]

{ #category : 'as yet unclassified' }
JadeiteSUnitInClassPresenter >> findClass [

	^parentPresenter findClass
]

{ #category : 'as yet unclassified' }
JadeiteSUnitInClassPresenter >> findMethod [

	^parentPresenter findMethod
]

{ #category : 'as yet unclassified' }
JadeiteSUnitInClassPresenter >> gotoMethodDefinedPackage [
	^self parentPresenter gotoMethodDefinedPackage
]

{ #category : 'as yet unclassified' }
JadeiteSUnitInClassPresenter >> jadeBrowseTests [

	^parentPresenter topShell jadeBrowseTests
]

{ #category : 'as yet unclassified' }
JadeiteSUnitInClassPresenter >> jadeDebug [
	"hot key hook"  
	self debug
]

{ #category : 'as yet unclassified' }
JadeiteSUnitInClassPresenter >> jadeDisplay [

	"do nothing"
]

{ #category : 'as yet unclassified' }
JadeiteSUnitInClassPresenter >> jadeExecute [

	"do nothing"
]

{ #category : 'as yet unclassified' }
JadeiteSUnitInClassPresenter >> jadeInspect [

	"do nothing"
]

{ #category : 'as yet unclassified' }
JadeiteSUnitInClassPresenter >> maximizeCode [
	^parentPresenter topShell maximizeCode
]

{ #category : 'as yet unclassified' }
JadeiteSUnitInClassPresenter >> moveCardLeft [
	^parentPresenter topShell moveCardLeft
]

{ #category : 'as yet unclassified' }
JadeiteSUnitInClassPresenter >> moveCardRight [

	^parentPresenter topShell moveCardRight
]

{ #category : 'as yet unclassified' }
JadeiteSUnitInClassPresenter >> newBrowser [

	^parentPresenter newBrowser
]

{ #category : 'as yet unclassified' }
JadeiteSUnitInClassPresenter >> onViewOpened [
	super onViewOpened. 
	self registerPresentersForUpdates.
	
]

{ #category : 'as yet unclassified' }
JadeiteSUnitInClassPresenter >> queryCommand: aCommandQuery [
	(self topShell queryCommand: aCommandQuery) ifTrue: [^true].	"make sure card actions are appropriately enabled"
	(#(#runSelected #runMethodTests #runAndMesureTime #debug #browseSelectedMethods)
		includes: aCommandQuery command)
			ifTrue: 
				[aCommandQuery isEnabled: methodListPresenter selections notEmpty.
				^true].
	(#(#stopTestProcess) includes: aCommandQuery command)
		ifTrue: 
			[aCommandQuery isEnabled: testProcess notNil.
			^true].
	(self parentPresenter queryCommand: aCommandQuery)
		ifFalse: 
			[aCommandQuery isEnabled: true.
			^true].
	^false
]

{ #category : 'as yet unclassified' }
JadeiteSUnitInClassPresenter >> refresh [
	parentPresenter selectedClass
		ifNil: [self resetTestList]
		ifNotNil: 
			[parentPresenter updateService: parentPresenter selectedClass.
			self parentPresenter updateSUnitTab].
	self ensureVisible.
	self reset
]

{ #category : 'as yet unclassified' }
JadeiteSUnitInClassPresenter >> resetTestList [
	^methodListPresenter list: ListModel new
]

{ #category : 'as yet unclassified' }
JadeiteSUnitInClassPresenter >> runAll [
	testProcess := 
			[[self runTests: methodListPresenter model in: testClassService name] ensure: 
					[testProcess := nil.
					shouldStopTestRun := false]]
					fork
]

{ #category : 'as yet unclassified' }
JadeiteSUnitInClassPresenter >> runAndMesureTime [
	| millisecondsToRun timeMessage time |
	"(testCasesPresenter selection size = 1) ifFalse: [^MessageBox notify: 'Select only one Test' ]."
	timeMessage := WriteStream on: String new.
	timeMessage nextPutAll: 'Total Time'.
	millisecondsToRun := Time millisecondsToRun: [self runSelected].
	time := Time fromMilliseconds: millisecondsToRun.
	time asSeconds = 0
		ifTrue: [timeMessage nextPutAll: 'milliseconds - ' , millisecondsToRun printString]
		ifFalse: 
			[timeMessage nextPutAll: String lineDelimiter , time minutes printString , ' minutes or'.
			timeMessage nextPutAll: String lineDelimiter , time asSeconds printString , ' seconds or'.
			timeMessage nextPutAll: String lineDelimiter , millisecondsToRun printString , ' milliseconds'].
	MessageBox notify: timeMessage contents
]

{ #category : 'as yet unclassified' }
JadeiteSUnitInClassPresenter >> runMethodTests [
	^self runSelected
]

{ #category : 'as yet unclassified' }
JadeiteSUnitInClassPresenter >> runSelected [
	testProcess := 
			[[self runTests: methodListPresenter selections in: testClassService name] ensure: 
					[testProcess := nil.
					shouldStopTestRun := false]]
					fork
]

{ #category : 'as yet unclassified' }
JadeiteSUnitInClassPresenter >> runTests: methodServices [
	^self runTestMethodServices: methodServices className: self selectedClass name
]

{ #category : 'as yet unclassified' }
JadeiteSUnitInClassPresenter >> selectedClass [
	^self parentPresenter selectedClass
]

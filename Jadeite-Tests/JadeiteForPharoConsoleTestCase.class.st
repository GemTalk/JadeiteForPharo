Class {
	#name : 'JadeiteForPharoConsoleTestCase',
	#superclass : 'JadeiteForPharoGUITestCase',
	#category : 'Jadeite-Tests',
	#package : 'Jadeite-Tests'
}

{ #category : 'tests' }
JadeiteForPharoConsoleTestCase >> test_basicSelect [
	"bug found just selecting projects - was trying to disconnect.
Just select everything and assert the selection index changed."

	| projectsPresenter |
	projectsPresenter := jadeiteShell projectListPresenter.
	1 to: projectsPresenter items size do: [ :index |
		projectsPresenter selectIndex: index.
		self assert: projectsPresenter selection selectedIndex equals: index ]
]

{ #category : 'tests' }
JadeiteForPharoConsoleTestCase >> test_browseProject [

	| projectsPresenter service |
	RowanServiceUpdater uninstallTestUpdater.
	projectsPresenter := jadeiteShell projectListPresenter.
	service := projectsPresenter items detect: [ :projectService |
		           projectService name = 'Rowan' ].
	projectsPresenter selectItem: service.
	projectsBrowser := jadeiteShell browseProject.
	[ self projectsPresenter projectListPresenter selectedItem isNil ]
		whileTrue: [ (Delay forMilliseconds: 10) wait ].
	self assert: [
		self projectsPresenter projectListPresenter selectedItem name
		= 'Rowan' ]
]

{ #category : 'tests' }
JadeiteForPharoConsoleTestCase >> test_close [
	"try to test that a dialog is opened before console is closed and that the answer does the right thing"

	| dialog |
	self
		testsIssue: #issue155
		withTitle: '[jfpWor] All JfP windows closed without a promprt'. "https://github.com/GemTalk/JadeiteForPharo/issues/155"

	self openProjectBrowser.
	self denyIsNil: projectsBrowser.
	[ jadeiteShell window close ] fork.
	dialog := self waitForCloseDialog.
	dialog no.
	self denyIsNil: projectsBrowser.
	self deny: jadeiteShell window isClosed.
	self assert: session connection isOpen.

	[ jadeiteShell window close ] fork.
	dialog := self waitForCloseDialog.
	dialog yes.
	(Delay forMilliseconds: 250) wait. "must give windows time to close"
	self assert: projectsBrowser window isClosed.
	self deny: session connection isOpen
]

{ #category : 'support' }
JadeiteForPharoConsoleTestCase >> waitForCloseDialog [

	| dialogs count |
	count := 0.
	[
	(dialogs := self currentWorld windowsSatisfying: [ :each |
		            each isKindOf: QuestionWithoutCancelDialogWindow ])
		isEmpty or: [ count < 10 ] ] whileTrue: [
		count := count + 1.
		(Delay forMilliseconds: 10) wait ].
	self assert: dialogs size equals: 1.
	^ dialogs first
]

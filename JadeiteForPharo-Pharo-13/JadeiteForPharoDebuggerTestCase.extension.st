Extension { #name : 'JadeiteForPharoDebuggerTestCase' }

{ #category : '*JadeiteForPharo-Pharo-13' }
JadeiteForPharoDebuggerTestCase >> test_debugTestProcessHangingAround [

	self
		testsJadeiteForPharoIssue: #issue329
		title:
		'Debugging failed test in browser leaves pharo process hanging around'
		url: 'https://github.com/GemTalk/JadeiteForPharo/issues/329'.
		
	JadeitePreferences isRowanAvailable ifFalse: [
		self skip: 'server tests not yet present in rowan stub image' ].

	projectsBrowser := JadeiteConsole currentConsole openBrowser.
	session := GciSession current.
	RowanServiceUpdater uninstallTestUpdater. "this forces commands to be forked which manifests the problem"
	self assertIsNil: self debugTestProcesses.
	self projectsPresenter findClassNamed: 'JadeServerTest'.
	[ self projectsPresenter selectedClass ] whileNil: [
		(Delay forMilliseconds: 5) wait ].
	self saveMethod: 'test_fail	self assert: false' in: 'JadeServerTest'.
	[
		self projectsPresenter debugMethodTests:
			self projectsPresenter selectedClass ] fork.
	debugger := self waitForDebugger.
	[ self denyIsNil: self debugTestProcesses ] ensure: [
			self destroy: debugger.
			(Delay forMilliseconds: 250) wait.
			self destroy: debugger. "just in case"
			self assertIsNil: self debugTestProcesses ]
]

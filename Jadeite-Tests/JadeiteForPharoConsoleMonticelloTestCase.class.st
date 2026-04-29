Class {
	#name : 'JadeiteForPharoConsoleMonticelloTestCase',
	#superclass : 'JadeiteForPharoGUITestCase',
	#instVars : [
		'repositoriesBrowser',
		'monticelloBrowser'
	],
	#category : 'Jadeite-Tests',
	#package : 'Jadeite-Tests'
}

{ #category : 'coverage' }
JadeiteForPharoConsoleMonticelloTestCase class >> codeCoverageClasses [

	^ {
		  JadeiteConsoleMonticello.
		  JadeiteMonticelloAllRepositoriesBrowser } asOrderedCollection
]

{ #category : 'coverage' }
JadeiteForPharoConsoleMonticelloTestCase class >> primaryTestClass [

	^ JadeiteConsoleMonticello
]

{ #category : 'testing' }
JadeiteForPharoConsoleMonticelloTestCase class >> runAsDataCurator [

	^ true
]

{ #category : 'testing' }
JadeiteForPharoConsoleMonticelloTestCase class >> runAsSystemUser [

	^ false
]

{ #category : 'support' }
JadeiteForPharoConsoleMonticelloTestCase >> monticelloPackageListPresenter [

	^ jadeiteShell monticelloPackageListPresenter
]

{ #category : 'support' }
JadeiteForPharoConsoleMonticelloTestCase >> performTest [

	JadeitePreferences isSeaside ifFalse: [
		^ self skip: 'Not in Seaside/Monticello mode. Test not run' ].
	^ super performTest
]

{ #category : 'support' }
JadeiteForPharoConsoleMonticelloTestCase >> setUp [

	user := 'DataCurator'.
	super setUp
]

{ #category : 'support' }
JadeiteForPharoConsoleMonticelloTestCase >> tearDown [

	repositoriesBrowser ifNotNil: [ self destroy: repositoriesBrowser ].
	monticelloBrowser ifNotNil: [ self destroy: monticelloBrowser ].
	super tearDown
]

{ #category : 'tests' }
JadeiteForPharoConsoleMonticelloTestCase >> test_addAndRemoveRepository [
	"Add a test HTTP repository, verify it appears and is selected,
	 then remove it to restore the original state.
	 After each action command, updateMonticelloPackages re-fetches package
	 data from the server (action commands do not return updated services).
	 A fresh browser is opened each time so it reads the current packages."

	| monticelloService testUrl initialCount repoService |
	self deny: self monticelloPackageListPresenter items isEmpty.
	testUrl := 'http://test.jadeiteforpharo.internal/ss/TestRepo'.

	repositoriesBrowser := self
		                       waitForNewPresenter:
		                       JadeiteMonticelloAllRepositoriesBrowser
		                       while: [ jadeiteShell browseAllRepositories ].
	initialCount := (repositoriesBrowser repositoriesPresenter items
		                 reject: [ :item | item isSeparator ]) size.
	self destroy: repositoriesBrowser.
	repositoriesBrowser := nil.
	monticelloService := RowanMonticelloService new.
	[
		monticelloService
			command: #addHttpRepository:;
			commandArgs: (Array with: testUrl).
		self issueCommand: monticelloService onCompletion: [ ].
		repositoriesBrowser := self
			                       waitForNewPresenter:
			                       JadeiteMonticelloAllRepositoriesBrowser
			                       while: [ jadeiteShell browseAllRepositories ].
		(Delay forMilliseconds: 100) wait.
		self assert:
			(repositoriesBrowser repositoriesPresenter items reject: [ :item |
				 item isSeparator ]) size > initialCount.
		repositoriesBrowser updateRepositoriesSelectingUrl: testUrl.
		repoService := repositoriesBrowser repositoriesPresenter
			               selectedItem.
		self
			assert:
			repositoriesBrowser repositoriesPresenter selectedItem description
			equals: testUrl.
		self destroy: repositoriesBrowser ] ensure: [
			repositoriesBrowser := nil.
			monticelloService
				command: #removeRepository:;
				commandArgs: (Array with: repoService).
			self issueCommand: monticelloService onCompletion: [
					repositoriesBrowser := self
						                       waitForNewPresenter:
						                       JadeiteMonticelloAllRepositoriesBrowser
						                       while: [
						                       jadeiteShell browseAllRepositories ].
					(Delay forMilliseconds: 100) wait.
					self
						assert:
							(repositoriesBrowser repositoriesPresenter items reject: [
								 :item | item isSeparator ]) size
						equals: initialCount ] ]
]

{ #category : 'tests' }
JadeiteForPharoConsoleMonticelloTestCase >> test_browseAllRepositoriesOpens [

	self deny: self monticelloPackageListPresenter items isEmpty.
	repositoriesBrowser := self
		                       waitForNewPresenter:
		                       JadeiteMonticelloAllRepositoriesBrowser
		                       while: [ jadeiteShell browseAllRepositories ].
	self assert:
		(repositoriesBrowser isKindOf: JadeiteMonticelloAllRepositoriesBrowser).
	self assert: repositoriesBrowser window isOpen.
	self deny: repositoriesBrowser repositoriesPresenter items isEmpty
]

{ #category : 'tests' }
JadeiteForPharoConsoleMonticelloTestCase >> test_browseAllRepositoriesPackagePaneLoads [

	| firstRepo |
	self deny: self monticelloPackageListPresenter items isEmpty.
	repositoriesBrowser := self
		                       waitForNewPresenter:
		                       JadeiteMonticelloAllRepositoriesBrowser
		                       while: [ jadeiteShell browseAllRepositories ].
	firstRepo := repositoriesBrowser repositoriesPresenter items
		             detect: [ :item | item isSeparator not ]
		             ifNone: [ nil ].
	self denyIsNil: firstRepo.
	repositoriesBrowser repositoriesPresenter selectItem: firstRepo.
	self
		waitFor: [ repositoriesBrowser packagesPresenter items isEmpty ]
		errorMessage: 'Timed out waiting for packages pane to populate'.
	self deny: repositoriesBrowser packagesPresenter items isEmpty
]

{ #category : 'tests' }
JadeiteForPharoConsoleMonticelloTestCase >> test_browsePackageRepositoriesOpens [

	| packageWithSource |
	packageWithSource := self monticelloPackageListPresenter items
		                     detect: [ :pkg | pkg sourceRepository notNil ]
		                     ifNone: [ nil ].
	packageWithSource ifNil: [
		^ self skip: 'No package with a source repository found' ].
	self monticelloPackageListPresenter selectItem: packageWithSource.
	monticelloBrowser := self
		                     waitForNewPresenter: JadeiteMonticelloBrowser
		                     while: [ jadeiteShell browsePackageRepositories ].
	self assert: (monticelloBrowser isKindOf: JadeiteMonticelloBrowser).
	self assert: monticelloBrowser window isOpen
]

{ #category : 'tests' }
JadeiteForPharoConsoleMonticelloTestCase >> test_browsePackageRepositoriesWindowTitle [

	| packageWithSource |
	packageWithSource := self monticelloPackageListPresenter items
		                     detect: [ :pkg | pkg sourceRepository notNil ]
		                     ifNone: [ nil ].
	packageWithSource ifNil: [
		^ self skip: 'No package with a source repository found' ].
	self monticelloPackageListPresenter selectItem: packageWithSource.
	monticelloBrowser := self
		                     waitForNewPresenter: JadeiteMonticelloBrowser
		                     while: [ jadeiteShell browsePackageRepositories ].
	self assert: (monticelloBrowser window title includesSubstring:
			 packageWithSource description)
]

{ #category : 'tests' }
JadeiteForPharoConsoleMonticelloTestCase >> test_packagesLoaded [

	self deny: self monticelloPackageListPresenter items isEmpty
]

{ #category : 'tests' }
JadeiteForPharoConsoleMonticelloTestCase >> test_updateRepositoriesSelectsExistingUrl [
	"updateRepositoriesSelectingUrl: should select the repo whose description
	 matches the given URL, whether it was just added or was already present."

	| firstRepo |
	repositoriesBrowser := self
		                       waitForNewPresenter:
		                       JadeiteMonticelloAllRepositoriesBrowser
		                       while: [ jadeiteShell browseAllRepositories ].
	firstRepo := repositoriesBrowser repositoriesPresenter items
		             detect: [ :item | item isSeparator not ]
		             ifNone: [ nil ].
	self denyIsNil: firstRepo.
	repositoriesBrowser repositoriesPresenter unselectAll.
	repositoriesBrowser updateRepositoriesSelectingUrl:
		firstRepo description.
	self
		assert: repositoriesBrowser repositoriesPresenter selectedItem
		equals: firstRepo
]

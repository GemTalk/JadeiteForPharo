Class {
	#name : 'JadeiteForPharoAllRepositoriesBrowserTestCase',
	#superclass : 'JadeiteForPharoGUITestCase',
	#instVars : [
		'repositoriesBrowser'
	],
	#category : 'Jadeite-Tests',
	#package : 'Jadeite-Tests'
}

{ #category : 'coverage' }
JadeiteForPharoAllRepositoriesBrowserTestCase class >> codeCoverageClasses [

	^ { JadeiteMonticelloAllRepositoriesBrowser } asOrderedCollection
]

{ #category : 'testing' }
JadeiteForPharoAllRepositoriesBrowserTestCase class >> primaryTestClass [

	^ JadeiteMonticelloAllRepositoriesBrowser
]

{ #category : 'testing' }
JadeiteForPharoAllRepositoriesBrowserTestCase class >> runAsDataCurator [

	^ true
]

{ #category : 'testing' }
JadeiteForPharoAllRepositoriesBrowserTestCase class >> runAsSystemUser [

	^ false
]

{ #category : 'support' }
JadeiteForPharoAllRepositoriesBrowserTestCase >> monticelloPackageListPresenter [

	^ jadeiteShell monticelloPackageListPresenter
]

{ #category : 'support' }
JadeiteForPharoAllRepositoriesBrowserTestCase >> performTest [

	JadeitePreferences isSeaside ifFalse: [
		^ self skip: 'Not in Seaside/Monticello mode. Test not run' ].
	^ super performTest
]

{ #category : 'support' }
JadeiteForPharoAllRepositoriesBrowserTestCase >> setUp [

	user := 'DataCurator'.
	super setUp
]

{ #category : 'support' }
JadeiteForPharoAllRepositoriesBrowserTestCase >> tearDown [

	repositoriesBrowser ifNotNil: [ self destroy: repositoriesBrowser ].
	super tearDown
]

{ #category : 'tests' }
JadeiteForPharoAllRepositoriesBrowserTestCase >> test_browsePackageRepositoriesDisabledForUnloadedPackage [

	| packages firstRepo loadedDescs unloadedPackage |
	packages := self monticelloPackageListPresenter items.
	self deny: packages isEmpty.
	repositoriesBrowser := self
		                       waitForNewPresenter: JadeiteMonticelloAllRepositoriesBrowser
		                       while: [
			                       JadeiteMonticelloAllRepositoriesBrowser
				                       showOnPackages: packages
				                       application: jadeiteShell application ].
	firstRepo := repositoriesBrowser repositoriesPresenter items
		             detect: [ :item | item isSeparator not ]
		             ifNone: [ nil ].
	self denyIsNil: firstRepo.
	repositoriesBrowser repositoriesPresenter selectItem: firstRepo.
	[ repositoriesBrowser packagesPresenter items isEmpty ] whileTrue: [
		(Delay forMilliseconds: 50) wait ].
	loadedDescs := packages collect: [ :pkg | pkg descriptionInsideParens ].
	unloadedPackage := repositoriesBrowser packagesPresenter items
		                   detect: [ :pkg |
			                   (loadedDescs includes: pkg descriptionInsideParens) not ]
		                   ifNone: [ nil ].
	unloadedPackage ifNil: [ ^ self skip: 'No unloaded packages found in repository' ].
	repositoriesBrowser packagesPresenter selectItem: unloadedPackage.
	self assertIsNil:
		(repositoriesBrowser loadedPackageFor: unloadedPackage)
]

{ #category : 'tests' }
JadeiteForPharoAllRepositoriesBrowserTestCase >> test_browsePackageRepositoriesEnabledForLoadedPackage [

	| packages firstRepo loadedPackage |
	packages := self monticelloPackageListPresenter items.
	self deny: packages isEmpty.
	repositoriesBrowser := self
		                       waitForNewPresenter: JadeiteMonticelloAllRepositoriesBrowser
		                       while: [
			                       JadeiteMonticelloAllRepositoriesBrowser
				                       showOnPackages: packages
				                       application: jadeiteShell application ].
	firstRepo := repositoriesBrowser repositoriesPresenter items
		             detect: [ :item | item isSeparator not ]
		             ifNone: [ nil ].
	self denyIsNil: firstRepo.
	repositoriesBrowser repositoriesPresenter selectItem: firstRepo.
	[ repositoriesBrowser packagesPresenter items isEmpty ] whileTrue: [
		(Delay forMilliseconds: 50) wait ].
	loadedPackage := repositoriesBrowser packagesPresenter items
		                 detect: [ :pkg |
			                 (repositoriesBrowser loadedPackageFor: pkg) notNil ]
		                 ifNone: [ nil ].
	loadedPackage ifNil: [ ^ self skip: 'No loaded packages found in repository' ].
	repositoriesBrowser packagesPresenter selectItem: loadedPackage.
	self denyIsNil:
		(repositoriesBrowser loadedPackageFor: loadedPackage)
]

{ #category : 'tests' }
JadeiteForPharoAllRepositoriesBrowserTestCase >> test_browsePackageRepositoriesOpensBrowser [

	| packages firstRepo loadedPackage monticelloBrowser |
	packages := self monticelloPackageListPresenter items.
	self deny: packages isEmpty.
	repositoriesBrowser := self
		                       waitForNewPresenter: JadeiteMonticelloAllRepositoriesBrowser
		                       while: [
			                       JadeiteMonticelloAllRepositoriesBrowser
				                       showOnPackages: packages
				                       application: jadeiteShell application ].
	firstRepo := repositoriesBrowser repositoriesPresenter items
		             detect: [ :item | item isSeparator not ]
		             ifNone: [ nil ].
	self denyIsNil: firstRepo.
	repositoriesBrowser repositoriesPresenter selectItem: firstRepo.
	[ repositoriesBrowser packagesPresenter items isEmpty ] whileTrue: [
		(Delay forMilliseconds: 50) wait ].
	loadedPackage := repositoriesBrowser packagesPresenter items
		                 detect: [ :pkg |
			                 (repositoriesBrowser loadedPackageFor: pkg) notNil ]
		                 ifNone: [ nil ].
	loadedPackage ifNil: [ ^ self skip: 'No loaded packages found in repository' ].
	repositoriesBrowser packagesPresenter selectItem: loadedPackage.
	monticelloBrowser := self
		                     waitForNewPresenter: JadeiteMonticelloBrowser
		                     while: [
			                     repositoriesBrowser browsePackageRepositories ].
	self assert: monticelloBrowser isKindOf: JadeiteMonticelloBrowser.
	self assert: monticelloBrowser window isOpen.
	self destroy: monticelloBrowser
]

{ #category : 'tests' }
JadeiteForPharoAllRepositoriesBrowserTestCase >> test_browserOpens [

	| packages |
	packages := self monticelloPackageListPresenter items.
	self deny: packages isEmpty.
	repositoriesBrowser := self
		                       waitForNewPresenter: JadeiteMonticelloAllRepositoriesBrowser
		                       while: [
			                       JadeiteMonticelloAllRepositoriesBrowser
				                       showOnPackages: packages
				                       application: jadeiteShell application ].
	self assert: repositoriesBrowser isKindOf: JadeiteMonticelloAllRepositoriesBrowser.
	self assert: repositoriesBrowser window isOpen
]

{ #category : 'tests' }
JadeiteForPharoAllRepositoriesBrowserTestCase >> test_repositoriesPopulated [

	| packages |
	packages := self monticelloPackageListPresenter items.
	self deny: packages isEmpty.
	repositoriesBrowser := self
		                       waitForNewPresenter: JadeiteMonticelloAllRepositoriesBrowser
		                       while: [
			                       JadeiteMonticelloAllRepositoriesBrowser
				                       showOnPackages: packages
				                       application: jadeiteShell application ].
	self deny: repositoriesBrowser repositoriesPresenter items isEmpty
]

{ #category : 'tests' }
JadeiteForPharoAllRepositoriesBrowserTestCase >> test_selectRepositoryDisplaysPackages [

	| packages firstRepo |
	packages := self monticelloPackageListPresenter items.
	self deny: packages isEmpty.
	repositoriesBrowser := self
		                       waitForNewPresenter: JadeiteMonticelloAllRepositoriesBrowser
		                       while: [
			                       JadeiteMonticelloAllRepositoriesBrowser
				                       showOnPackages: packages
				                       application: jadeiteShell application ].
	firstRepo := repositoriesBrowser repositoriesPresenter items
		             detect: [ :item | item isSeparator not ]
		             ifNone: [ nil ].
	self denyIsNil: firstRepo.
	repositoriesBrowser repositoriesPresenter selectItem: firstRepo.
	[ repositoriesBrowser packagesPresenter items isEmpty ] whileTrue: [
		(Delay forMilliseconds: 50) wait ].
	self deny: repositoriesBrowser packagesPresenter items isEmpty
]

{ #category : 'tests' }
JadeiteForPharoAllRepositoriesBrowserTestCase >> test_shellName [

	| packages |
	packages := self monticelloPackageListPresenter items.
	repositoriesBrowser := self
		                       waitForNewPresenter: JadeiteMonticelloAllRepositoriesBrowser
		                       while: [
			                       JadeiteMonticelloAllRepositoriesBrowser
				                       showOnPackages: packages
				                       application: jadeiteShell application ].
	self
		assert: repositoriesBrowser shellName
		equals: 'Jadeite Monticello Repository Browser'
]

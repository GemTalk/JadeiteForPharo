Class {
	#name : 'JadeiteForPharoAllRepositoriesBrowserTestCase',
	#superclass : 'JadeiteForPharoConsoleTestCase',
	#instVars : [
		'repositoriesBrowser'
	],
	#category : 'Jadeite-Tests',
	#package : 'Jadeite-Tests'
}

{ #category : 'coverage' }
JadeiteForPharoAllRepositoriesBrowserTestCase class >> codeCoverageClasses [

	^ { JadeiteAllRepositoriesBrowser } asOrderedCollection
]

{ #category : 'testing' }
JadeiteForPharoAllRepositoriesBrowserTestCase class >> primaryTestClass [

	^ JadeiteAllRepositoriesBrowser
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
JadeiteForPharoAllRepositoriesBrowserTestCase >> test_browserOpens [

	| packages |
	packages := self monticelloPackageListPresenter items.
	self deny: packages isEmpty.
	repositoriesBrowser := self
		                       waitForNewPresenter: JadeiteAllRepositoriesBrowser
		                       while: [
			                       JadeiteAllRepositoriesBrowser
				                       showOnPackages: packages
				                       application: jadeiteShell application ].
	self assert: repositoriesBrowser isKindOf: JadeiteAllRepositoriesBrowser.
	self assert: repositoriesBrowser window isOpen
]

{ #category : 'tests' }
JadeiteForPharoAllRepositoriesBrowserTestCase >> test_repositoriesPopulated [

	| packages |
	packages := self monticelloPackageListPresenter items.
	self deny: packages isEmpty.
	repositoriesBrowser := self
		                       waitForNewPresenter: JadeiteAllRepositoriesBrowser
		                       while: [
			                       JadeiteAllRepositoriesBrowser
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
		                       waitForNewPresenter: JadeiteAllRepositoriesBrowser
		                       while: [
			                       JadeiteAllRepositoriesBrowser
				                       showOnPackages: packages
				                       application: jadeiteShell application ].
	self deny: repositoriesBrowser repositoriesPresenter items isEmpty.
	firstRepo := repositoriesBrowser repositoriesPresenter items first.
	repositoriesBrowser repositoriesPresenter selectItem: firstRepo.
	self deny: repositoriesBrowser packagesPresenter items isEmpty
]

{ #category : 'tests' }
JadeiteForPharoAllRepositoriesBrowserTestCase >> test_shellName [

	| packages |
	packages := self monticelloPackageListPresenter items.
	repositoriesBrowser := self
		                       waitForNewPresenter: JadeiteAllRepositoriesBrowser
		                       while: [
			                       JadeiteAllRepositoriesBrowser
				                       showOnPackages: packages
				                       application: jadeiteShell application ].
	self
		assert: repositoriesBrowser shellName
		equals: 'Jadeite Monticello Repository Browser'
]

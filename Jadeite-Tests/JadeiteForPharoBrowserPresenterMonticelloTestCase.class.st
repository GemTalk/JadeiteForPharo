Class {
	#name : 'JadeiteForPharoBrowserPresenterMonticelloTestCase',
	#superclass : 'JadeiteForPharoBrowserWithoutRowanTestCase',
	#category : 'Jadeite-Tests',
	#package : 'Jadeite-Tests'
}

{ #category : 'coverage' }
JadeiteForPharoBrowserPresenterMonticelloTestCase class >> codeCoverageClasses [
	"classes that are tested by this test class."

	^ {
		  JadeiteBrowserMonticello.
		  JadeiteBrowserPresenterMonticello } asOrderedCollection
]

{ #category : 'coverage' }
JadeiteForPharoBrowserPresenterMonticelloTestCase class >> primaryTestClass [

	^ JadeiteBrowserMonticello
]

{ #category : 'support' }
JadeiteForPharoBrowserPresenterMonticelloTestCase >> performTest [

	JadeitePreferences isSeaside ifFalse: [
		^ self skip: 'Not in Seaside/Monticello mode. Test not run' ].
	^ super performTest
]

{ #category : 'support' }
JadeiteForPharoBrowserPresenterMonticelloTestCase >> selectServiceNamed: name in: presenter [

	| service |
	service := presenter list
		           detect: [ :monticelloPackageService |
		           monticelloPackageService name = name ]
		           ifNone: [
		           self error: 'Service expected to be in list not found' ].
	presenter selectItem: service
]

{ #category : 'support' }
JadeiteForPharoBrowserPresenterMonticelloTestCase >> setUp [

	user := 'DataCurator'.
	super setUp
]

{ #category : 'tests' }
JadeiteForPharoBrowserPresenterMonticelloTestCase >> test_basicProjectTabLabel [

	| packageListPresenter firstClass |
	packageListPresenter := self projectsPresenter monticelloPackageListPresenter.
	self
		assert: self projectsPresenter basicProjectTabLabel
		equals: 'Projects'.
	self selectServiceNamed: 'Announcements' in: packageListPresenter.
	self
		assert: self projectsPresenter basicProjectTabLabel
		equals: 'Announcements'.
	firstClass := self classListPresenter items first.
	self selectServiceNamed: firstClass name in: self classListPresenter.
	self
		assert: self projectsPresenter basicProjectTabLabel
		equals: firstClass name
]

{ #category : 'tests' }
JadeiteForPharoBrowserPresenterMonticelloTestCase >> test_extensionClassesDisplayWithColor [
	"Covers two behaviors:
	 1. classDisplayColor: returns the extension color for extension classes and nil for regular ones.
	 2. monticelloPackageChanged: merges svc classes and svc extensionClasses so both appear in the list."

	| packageListPresenter classListPresenter |
	packageListPresenter := self projectsPresenter monticelloPackageListPresenter.
	classListPresenter := self classListPresenter.
	packageListPresenter items
		detect: [ :packageService |
			self selectServiceNamed: packageService name in: packageListPresenter.
			classListPresenter items anySatisfy: [ :cs | cs isExtension ] ]
		ifNone: [ ^ self skip: 'No package with extension classes found' ].
	self deny: (classListPresenter items select: [ :cs | cs isExtension ]) isEmpty.
	classListPresenter items do: [ :classService |
		classService isExtension
			ifTrue: [ self denyIsNil: (classListPresenter displayColor value: classService) ]
			ifFalse: [
				self assertIsNil: (classListPresenter displayColor value: classService) ] ]
]

{ #category : 'tests' }
JadeiteForPharoBrowserPresenterMonticelloTestCase >> test_findClassInMonticelloPackage [

	self projectsPresenter
		updateAfterFindClass: (RowanClassService new name: 'Announcer')
		methodService: nil
		onCompletion: [  ].
	self
		assert: self classListPresenter selectedItem name
		equals: 'Announcer'.
	self
		assert: self projectsPresenter monticelloPackageListPresenter selectedItem name
		equals: 'Announcements'
]

{ #category : 'tests' }
JadeiteForPharoBrowserPresenterMonticelloTestCase >> test_findClassNotInMonticelloPackage [

	| browsersBefore newBrowser |
	browsersBefore := JadeiteBrowserWithoutRowan allInstances asArray.
	self projectsPresenter
		updateAfterFindClass:
		(RowanClassService new name: 'OrderedCollection')
		methodService: nil
		onCompletion: [
				newBrowser := JadeiteBrowserWithoutRowan allInstances detect: [
					              :browser | (browsersBefore includes: browser) not ].
				[
					self
						assert:
						newBrowser activePresenter classListPresenter selectedItem name
						equals: 'OrderedCollection' ] ensure: [
					self destroy: newBrowser ] ]
]

{ #category : 'tests' }
JadeiteForPharoBrowserPresenterMonticelloTestCase >> test_hasChangesDisplaysBoldWithAsterix [

	| packageListPresenter |
	packageListPresenter := self projectsPresenter monticelloPackageListPresenter.
	packageListPresenter items do: [ :packageService |
		packageService hasChanges
			ifTrue: [
				self assert: packageService description first equals: $*.
				self assert: (packageListPresenter displayBold value: packageService) ]
			ifFalse: [
				self deny: packageService description first equals: $*.
				self deny: (packageListPresenter displayBold value: packageService) ] ]
]

{ #category : 'tests' }
JadeiteForPharoBrowserPresenterMonticelloTestCase >> test_selectPackageDisplaysClasses [

	self
		selectServiceNamed: 'Announcements'
		in: self projectsPresenter monticelloPackageListPresenter.
	self deny: self classListPresenter items isEmpty
]

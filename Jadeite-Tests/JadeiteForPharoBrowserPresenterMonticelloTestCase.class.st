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

{ #category : 'tests' }
JadeiteForPharoBrowserPresenterMonticelloTestCase >> test_selectPackageDisplaysClasses [

	self selectServiceNamed: 'Announcements' in: self dictionaryListPresenter.
	self deny: self classListPresenter items isEmpty
]

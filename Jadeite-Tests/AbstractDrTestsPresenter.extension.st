Extension { #name : 'AbstractDrTestsPresenter' }

{ #category : '*Jadeite-Tests' }
AbstractDrTestsPresenter >> runPluginWithSeed [

	JadeiteTestSuite randomSeed: nil.
	self runPluginFor: self testsConfiguration
]

Class {
	#name : 'JadeiteForPharoRowanQueryServiceTestCase',
	#superclass : 'JadeiteForPharoRowanServiceTestCase',
	#category : 'Jadeite-Tests',
	#package : 'Jadeite-Tests'
}

{ #category : 'tests' }
JadeiteForPharoRowanQueryServiceTestCase >> test_compileErrorHandled [
	"create any service, verify that the instantiated class is *Client"

	| service handledCompileError compileError |
	handledCompileError := false.
	service := RowanQueryService
		           command: #literalReferences:
		           withArgs: (Array with: '3 +').
	service compileErrorHandler: [ :ex |
		compileError := ex.
		handledCompileError := true ].
	updater issueCommand: service session: session.
	self assert: handledCompileError.
	self assert: (compileError isKindOf: GsCompileError).
	self
		assert: compileError gsArguments first last
		equals: 'expected a primary expression'
]

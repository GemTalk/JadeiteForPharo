Class {
	#name : 'JadeiteForPharoRowanQueryServiceTestCase',
	#superclass : 'JadeiteForPharoRowanServiceTestCase',
	#category : 'Jadeite-Tests',
	#package : 'Jadeite-Tests'
}

{ #category : 'tests' }
JadeiteForPharoRowanQueryServiceTestCase >> test_compileErrorHandled [

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

{ #category : 'tests' }
JadeiteForPharoRowanQueryServiceTestCase >> test_results [

	| service nonExistantSymbol |
	service := RowanQueryService
		           command: #literalReferences:
		           withArgs: (Array with: ''',''').
	updater issueCommand: service session: session.
	self assert: service hasResults.
	service queryResults do: [ :methodService |
		self assert: ('*'',''*' match: methodService source) ].
	self assert: service queryResults identicalTo: service answer.

	nonExistantSymbol := '#zwork_betterN0tBeTh3r3'.
	service commandArgs: (Array with: nonExistantSymbol).
	updater issueCommand: service session: session.
	self deny: service hasResults.
	self assert: service queryResults isEmpty.
	self assert: service answer isEmpty
]

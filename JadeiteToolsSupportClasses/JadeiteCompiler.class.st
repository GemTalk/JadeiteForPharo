Class {
	#name : 'JadeiteCompiler',
	#superclass : 'OpalCompiler',
	#category : 'JadeiteToolsSupportClasses'
}

{ #category : 'plugins' }
JadeiteCompiler >> compilationContextClass [

	^JadeiteCompilationContext
]

{ #category : 'public access' }
JadeiteCompiler >> parse [
	| parser |
	[
		parser := self createParser.
		ast := self semanticScope parseASTBy: parser.

		ast methodNode compilationContext: self compilationContext.
		self callParsePlugins.
		self doSemanticAnalysis ]
	on: ReparseAfterSourceEditing do: [:notification |
			self source: notification newSource.
			notification retry ].

	^ ast
]

Class {
	#name : 'JadeiteCodeTextStyler',
	#superclass : 'SpMorphicCodeTextStyler',
	#category : 'Jadeite-ToolsSupportClasses'
}

{ #category : 'private' }
JadeiteCodeTextStyler >> privateStyle: aText [
	| compiler |
	true ifTrue:[^super privateStyle: aText]. 
	aText ifEmpty: [ ^ self ].
	compiler := JadeiteCompiler new
		source: aText asString;
		noPattern: self isForWorkspace ;
		options:  #(+ optionParseErrors + optionSkipSemanticWarnings);
		requestor: workspace.

	self plugins do: [ :each | compiler addParsePlugin: each ].

	^ self
		style: aText
		ast: compiler parse
]

{ #category : 'visiting' }
JadeiteCodeTextStyler >> visitMessageNode: aMessageNode [
	| style link |

	style := true "Jadeite doesn't yet validate selectors on the server"
		ifTrue: [ #selector ]
		ifFalse: [ self formatIncompleteSelector: aMessageNode ].

	link := TextMethodLink sourceNode: aMessageNode.
	self styleOpenParenthese: aMessageNode.

	aMessageNode selectorParts
		with: aMessageNode keywordsPositions
		do: [ :keyword :position |
			self
				addStyle: style
				attribute: link
				from: position
				to: position + keyword size - 1 ].

	(aMessageNode isCascaded not or: [ aMessageNode isFirstCascaded ])
		ifTrue: [ self visitNode: aMessageNode receiver ].

	aMessageNode arguments do: [ :each | self visitNode: each ].
	self styleCloseParenthese: aMessageNode
]

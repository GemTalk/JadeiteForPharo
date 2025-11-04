Extension { #name : 'JadeiteMethodSourcePane' }

{ #category : '*Jadeite-SupportClasses' }
JadeiteMethodSourcePane class >> registerFormatSourceCommandWith: commandGroup [

	commandGroup register: JadeiteFormatSourceCommand forSpec
]

{ #category : '*Jadeite-SupportClasses' }
JadeiteMethodSourcePane class >> registerSourceActionsWithCommandGroup: commandGroup presenter: presenter [

	| lastClickPosition |
	lastClickPosition := (presenter adapter isNil or: [
		                      presenter adapter widget isNil ])
		                     ifTrue: [ 0 @ 0 ]
		                     ifFalse: [
			                     presenter adapter widget scrollPane textArea
				                     lastClickPosition ifNil: [ 0 @ 0 ] ].
	self registerFormatSourceCommandWith: commandGroup.
	commandGroup
		register: (JadeiteAddBreakpointCommand
				 forSpecContext: presenter
				 lastClickPosition: lastClickPosition);
		register: (JadeiteClearBreakpointCommand
				 forSpecContext: presenter
				 lastClickPosition: lastClickPosition);
		register: JadeiteMethodClearBreakpointsCommand forSpec
]

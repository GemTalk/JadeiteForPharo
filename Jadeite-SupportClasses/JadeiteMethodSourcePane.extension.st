Extension { #name : 'JadeiteMethodSourcePane' }

{ #category : '*Jadeite-SupportClasses' }
JadeiteMethodSourcePane class >> registerSourceActionsWithCommandGroup: commandGroup presenter: presenter [

	| group |
	commandGroup register: JadeiteFormatSourceCommand forSpec.
	group := (CmCommandGroup named: 'Breakpoints') asSpecGroup
		         register:
			         (JadeiteAddBreakpointCommand forSpecContext: presenter);
		         register:
			         (JadeiteClearBreakpointCommand forSpecContext: presenter);
		         register: JadeiteMethodClearBreakpointsCommand forSpec;
		         yourself.
	commandGroup register: group
]

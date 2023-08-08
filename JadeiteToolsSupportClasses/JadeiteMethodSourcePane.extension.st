Extension { #name : 'JadeiteMethodSourcePane' }

{ #category : '*JadeiteToolsSupportClasses' }
JadeiteMethodSourcePane class >> registerSourceActionsWithCommandGroup: commandGroup [

	| group |
	commandGroup register: JadeiteFormatSourceCommand forSpec.
	group := (CmCommandGroup named: 'Breakpoints') asSpecGroup
		         register: JadeiteAddBreakpointCommand forSpec;
		         register: JadeiteClearBreakpointCommand forSpec;
		         register: JadeiteMethodClearBreakpointsCommand forSpec;
		         yourself.
	commandGroup register: group
]

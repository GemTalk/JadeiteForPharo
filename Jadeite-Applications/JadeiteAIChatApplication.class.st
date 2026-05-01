Class {
	#name : 'JadeiteAIChatApplication',
	#superclass : 'JadeiteApplication',
	#category : 'Jadeite-Applications',
	#package : 'Jadeite-Applications'
}

{ #category : 'accessing' }
JadeiteAIChatApplication >> presenterClass [

	^ JadeiteAIChatPresenter
]

{ #category : 'actions' }
JadeiteAIChatApplication >> start [

	| inst windowPresenter resolvedAdapter |
	inst := self new: self presenterClass.
	resolvedAdapter := JadeiteAISettings resolveAdapter.
	resolvedAdapter ifNil: [
			UIManager default alert: JadeiteAISettings configurationHelpMessage.
			^ nil ].

	inst
		addStyle: 'jadeiteTextBackgroundColor';
		gciSession: gciSession;
		llmAdapter: resolvedAdapter.

	windowPresenter := inst open.
	self addBorderStyleTo: windowPresenter presenter: inst.
	^ inst
]

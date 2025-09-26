Class {
	#name : 'JadeiteTestsRunnerPluginPresenter',
	#superclass : 'DTDefaultPluginPresenter',
	#instVars : [
		'startButtonWithSeed'
	],
	#category : 'Jadeite-Tests',
	#package : 'Jadeite-Tests'
}

{ #category : 'initialization' }
JadeiteTestsRunnerPluginPresenter >> defaultLayout [

	| box |
	box := self newBoxLayoutLeftToRight.
	box
		add: startButton expand: true;
		add: startButtonWithSeed expand: true.
	^ SpBoxLayout newTopToBottom
		  add: (SpPanedLayout newLeftToRight
				   add: (SpPanedLayout newLeftToRight
						    add: packagesList;
						    add: itemsList;
						    yourself);
				   add: (SpBoxLayout newTopToBottom
						    spacing: 5;
						    add: resultViewsDropList expand: false;
						    add: resultLabel expand: false;
						    add: resultsList;
						    yourself);
				   yourself);
		  add: box expand: false;
		  yourself
]

{ #category : 'initialization' }
JadeiteTestsRunnerPluginPresenter >> initializePresenters [

	super initializePresenters.

	self
		initializePackagesListAndLabel;
		initializeItemsListAndLabel;
		initializeResultsTreeAndLabel;
		initializeResultViewsDropList.

	startButton := self newButton.
	startButton action: [ drTests runPlugin ].

	startButtonWithSeed := self newButton.
	startButtonWithSeed
		action: [ drTests runPluginWithSeed ];
		label: 'Run Tests with random seed ...'
]

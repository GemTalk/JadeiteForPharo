Class {
	#name : 'JadeiteNotebookPageLabelPresenter',
	#superclass : 'SpNotebookPageLabelPresenter',
	#category : 'Jadeite-SupportClasses',
	#package : 'Jadeite-SupportClasses'
}

{ #category : 'initialization' }
JadeiteNotebookPageLabelPresenter >> initializePresenters [
	"copy of super class method but iconPresenter always gets created"
	self layout: (SpBoxLayout newLeftToRight
			 spacing: 3;
			 yourself).
	self layout
		add: (iconPresenter := self newImage image: self model icon)
		expand: false.

	self layout
		vAlignCenter;
		add: (labelPresenter := self newLabel
				                   label: self model title asString;
				                   yourself)
		expand: false.

	self model isCloseable ifTrue: [
		self layout
			addLast: (self newButton
					 addStyle: 'small';
					 addStyle: 'flat';
					 icon: (self iconNamed: #windowCloseInactive);
					 action: [ self model removeFromNotebook ];
					 yourself)
			expand: false ]

	"self eventHandler whenDoubleClickDo: [ :event | 'ok' crTrace  ]."
]

{ #category : 'private - updating' }
JadeiteNotebookPageLabelPresenter >> updateIcon [

	iconPresenter ifNotNil: [ iconPresenter image: self model icon ]
]

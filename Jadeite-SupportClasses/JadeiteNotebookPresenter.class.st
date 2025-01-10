Class {
	#name : 'JadeiteNotebookPresenter',
	#superclass : 'SpNotebookPresenter',
	#category : 'Jadeite-SupportClasses',
	#package : 'Jadeite-SupportClasses'
}

{ #category : 'testing' }
JadeiteNotebookPresenter >> canDiscardEdits [

	^self owner canDiscardEdits
]

{ #category : 'testing' }
JadeiteNotebookPresenter >> canDiscardSelectionEdits [

	^self owner canDiscardSelectionEdits
]

{ #category : 'accessing' }
JadeiteNotebookPresenter >> currentCard [
	^self selectedPage
]

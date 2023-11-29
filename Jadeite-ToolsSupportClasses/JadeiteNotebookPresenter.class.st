Class {
	#name : 'JadeiteNotebookPresenter',
	#superclass : 'SpNotebookPresenter',
	#category : 'Jadeite-ToolsSupportClasses'
}

{ #category : 'accessing' }
JadeiteNotebookPresenter >> currentCard [
	^self selectedPage
]

{ #category : 'testing' }
JadeiteNotebookPresenter >> okToDiscardMethodChanges [

	^self owner okToDiscardMethodChanges
]

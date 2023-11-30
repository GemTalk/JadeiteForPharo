Class {
	#name : 'JadeiteNotebookPresenter',
	#superclass : 'SpNotebookPresenter',
	#category : 'Jadeite-SupportClasses'
}

{ #category : 'accessing' }
JadeiteNotebookPresenter >> currentCard [
	^self selectedPage
]

{ #category : 'testing' }
JadeiteNotebookPresenter >> okToChangeSelections [

	^self owner okToChangeSelections
]

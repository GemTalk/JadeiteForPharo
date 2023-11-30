Class {
	#name : 'JadeiteNotebookPresenter',
	#superclass : 'SpNotebookPresenter',
	#category : 'Jadeite-SupportClasses'
}

{ #category : 'testing' }
JadeiteNotebookPresenter >> canDiscardEdits [

	^self owner canDiscardEdits
]

{ #category : 'accessing' }
JadeiteNotebookPresenter >> currentCard [
	^self selectedPage
]

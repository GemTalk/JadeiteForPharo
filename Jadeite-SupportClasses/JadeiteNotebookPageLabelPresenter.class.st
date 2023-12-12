Class {
	#name : 'JadeiteNotebookPageLabelPresenter',
	#superclass : 'SpNotebookPageLabelPresenter',
	#category : 'Jadeite-SupportClasses'
}

{ #category : 'initialization' }
JadeiteNotebookPageLabelPresenter >> initializePresenters [

	super initializePresenters.
	iconPresenter := self newImage image: self model icon
]

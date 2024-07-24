Class {
	#name : 'JadeiteNotebookPage',
	#superclass : 'SpNotebookPage',
	#category : 'Jadeite-SupportClasses',
	#package : 'Jadeite-SupportClasses'
}

{ #category : 'accessing' }
JadeiteNotebookPage >> labelPresenter [

	^labelPresenter
]

{ #category : 'accessing' }
JadeiteNotebookPage >> name [

	^self title
]

{ #category : 'private - factory' }
JadeiteNotebookPage >> newLabelPresenterFor: ownerPresenter [
	"override this to implement custom labels"

	^ ownerPresenter 
		instantiate: JadeiteNotebookPageLabelPresenter 
		on: self
]

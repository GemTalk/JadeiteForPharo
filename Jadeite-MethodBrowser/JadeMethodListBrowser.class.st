Class {
	#name : 'JadeMethodListBrowser',
	#superclass : 'SpAbstractWidgetPresenter',
	#category : 'Jadeite-MethodBrowser',
	#package : 'Jadeite-MethodBrowser'
}

{ #category : 'as yet unclassified' }
JadeMethodListBrowser >> defaultPresenterName [

	^JadeMethodListPresenter getJadeShellViewName

]

{ #category : 'as yet unclassified' }
JadeMethodListBrowser >> presenterClass [

	 "^JadeMethodListPresenter."

	"^JadeTreeMethodListPresenter."

	^JadeMethodListPresenter getJadeMethodBrowserPresenterClass

]

{ #category : 'as yet unclassified' }
JadeMethodListBrowser >> shellName [
	^'Jadeite Method List Browser'.

]

{ #category : 'as yet unclassified' }
JadeMethodListBrowser >> statusBarText [
	^(self view viewNamed: 'statusBarField') 
]

{ #category : 'as yet unclassified' }
JadeMethodListBrowser >> statusBarText: aString [
	(self view viewNamed: 'statusBarField') model: (ValueHolder with: aString)
]

{ #category : 'as yet unclassified' }
JadeMethodListBrowser >> switchToListView [

	JadeMethodListPresenter setListView.

	self view destroy.
]

{ #category : 'as yet unclassified' }
JadeMethodListBrowser >> switchToTreeView [

	JadeMethodListPresenter setTreeView.

	self view destroy.

]

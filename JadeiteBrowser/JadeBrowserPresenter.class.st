Class {
	#name : 'JadeBrowserPresenter',
	#superclass : 'JadeitePresenter',
	#category : 'JadeiteBrowser'
}

{ #category : 'as yet unclassified' }
JadeBrowserPresenter >> onDragClass: aSession className: class [
	| list |
	list := Array with: ((aSession newDragObject: class)
						format: #class data: class;
						yourself).
	aSession
		dragObjects: list;
		supportedOperations: #(#move #copy);
		defaultOperation: #move;
		yourself
]

{ #category : 'as yet unclassified' }
JadeBrowserPresenter >> selectedClassName [

	self subclassResponsibility
]

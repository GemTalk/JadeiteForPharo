Class {
	#name : 'RowanMonticelloPackageServiceClient',
	#superclass : 'RowanMonticelloPackageService',
	#instVars : [
		'inCommand',
		'serviceCompletionBlock',
		'catchBlock'
	],
	#category : 'Jadeite-RowanClientServicesClient',
	#package : 'Jadeite-RowanClientServicesClient'
}

{ #category : 'as yet unclassified' }
RowanMonticelloPackageServiceClient >> allClassesSorted [

	| sorted |
	sorted := SortedCollection sortBlock: [ :x :y | x name < y name ].
	sorted
		addAll: self classes;
		addAll: self extensionClasses.
	^ sorted asArray
]

{ #category : 'accessing' }
RowanMonticelloPackageServiceClient >> catchBlock [

	^ catchBlock ifNil: [ super catchBlock ]
]

{ #category : 'accessing' }
RowanMonticelloPackageServiceClient >> catchBlock: anObject [

	catchBlock := anObject
]

{ #category : 'accessing' }
RowanMonticelloPackageServiceClient >> descriptionInsideParens [

	| abbrevDescription indexOfLeftParen indexOfRightParen |
	indexOfLeftParen := self description indexOf: $(. "if not found copy from start of string"
	indexOfRightParen := self description indexOf: $).
	indexOfRightParen := indexOfRightParen = 0
		                     ifTrue: [ self description size ]
		                     ifFalse: [ indexOfRightParen - 1 ].
	abbrevDescription := self description
		                     copyFrom: indexOfLeftParen + 1
		                     to: indexOfRightParen.

	^ abbrevDescription
]

{ #category : 'accessing' }
RowanMonticelloPackageServiceClient >> inCommand [

	^ inCommand ifNil: [ inCommand := RowanSemaphore new ]
]

{ #category : 'accessing' }
RowanMonticelloPackageServiceClient >> inCommand: anObject [

	inCommand := anObject
]

{ #category : 'accessing' }
RowanMonticelloPackageServiceClient >> serviceCompletionBlock [

	^ serviceCompletionBlock
]

{ #category : 'accessing' }
RowanMonticelloPackageServiceClient >> serviceCompletionBlock: anObject [

	serviceCompletionBlock := anObject
]

{ #category : 'accessing' }
RowanMonticelloPackageServiceClient >> tabLabel [

	^ self name
]

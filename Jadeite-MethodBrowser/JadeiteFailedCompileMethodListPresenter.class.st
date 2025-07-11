Class {
	#name : 'JadeiteFailedCompileMethodListPresenter',
	#superclass : 'JadeiteMethodListPresenter',
	#traits : 'JadeiteMethodsTrait + JadeiteToolbarTrait',
	#classTraits : 'JadeiteMethodsTrait classTrait + JadeiteToolbarTrait classTrait',
	#pools : [
		'ScintillaConstants'
	],
	#category : 'Jadeite-MethodBrowser',
	#package : 'Jadeite-MethodBrowser'
}

{ #category : 'actions' }
JadeiteFailedCompileMethodListPresenter >> handleMethodNotInListIn: classService statusBarText: text [
	"Any methods compiled in the failed compile list will not be in the method list"

	| methodService |
	methodService := classService selectedMethods first.
	methodListPresenter selectedItem selector: methodService selector.
	methodListPresenter selectedItem replicateFrom: methodService.
	methodListPresenter refresh. 
	self resetVisibleMethodDetails
]

{ #category : 'registration' }
JadeiteFailedCompileMethodListPresenter >> registerMethodPresentersForUpdates [
]

{ #category : 'registration' }
JadeiteFailedCompileMethodListPresenter >> registerPresentersForUpdates [
]

{ #category : 'selecting' }
JadeiteFailedCompileMethodListPresenter >> selectFirstReference: methodService [

	methodService ifNil: [ ^ self ].
	methodService firstReference
		ifNil: [
			firstReferenceString ifNotNil: [
				methodService source ifNotNil: [
					self selecting:
						(methodService source indexOfSubCollection: firstReferenceString) ] ] ]
		ifNotNil: [ :index |
			| range |
			index = 0 ifFalse: [
				methodService searchString ifNotNil: [
					range := Interval
						         from: index
						         to: methodService searchString size + index - 1.
					methodSourcePresenter selectionInterval: range ] ] ]
]

{ #category : 'constants' }
JadeiteFailedCompileMethodListPresenter >> shellName [
	^'Jadeite Failed Compile Method List Browser'
]

{ #category : 'updates' }
JadeiteFailedCompileMethodListPresenter >> updateMethodSource [

	firstReferenceString := self methodListPresenter selectedItem
		                        ifNil: [ String new ]
		                        ifNotNil: [ :item | item searchString ].
	^ super updateMethodSource
]

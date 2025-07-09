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

{ #category : 'registration' }
JadeiteFailedCompileMethodListPresenter >> registerMethodPresentersForUpdates [
]

{ #category : 'registration' }
JadeiteFailedCompileMethodListPresenter >> registerPresentersForUpdates [
]

{ #category : 'as yet unclassified' }
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

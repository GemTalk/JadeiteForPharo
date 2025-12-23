Class {
	#name : 'JadeiteBackend',
	#superclass : 'SpMorphicBackend',
	#category : 'Jadeite-SupportClasses',
	#package : 'Jadeite-SupportClasses'
}

{ #category : 'accessing' }
JadeiteBackend class >> backendName [

	^ #JadeiteBackend
]

{ #category : 'as yet unclassified' }
JadeiteBackend >> executeOpenDirectoryDialog: aFileDialog [

	| directoryPresenter |
	directoryPresenter := StOpenDirectoryPresenter new.
	directoryPresenter
		defaultFolder:
			(aFileDialog path ifNil: [ StFileSystemModel defaultDirectory ]);
		title: (aFileDialog title ifNil: [ 'Choose Directory' translated ]);
		openModal.
	^ directoryPresenter cancelled
		  ifTrue: [ nil ]
		  ifFalse: [ directoryPresenter selectedEntry ]
]

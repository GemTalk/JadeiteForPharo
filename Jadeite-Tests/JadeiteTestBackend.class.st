Class {
	#name : 'JadeiteTestBackend',
	#superclass : 'SpMorphicBackend',
	#category : 'Jadeite-Tests',
	#package : 'Jadeite-Tests'
}

{ #category : 'accessing' }
JadeiteTestBackend class >> backendName [

	^ #JadeiteTest
]

{ #category : 'ui - dialogs' }
JadeiteTestBackend >> openFileDialog: aFileDialog [

	ProvideAnswerNotification signal ifNotNil: [ :answer | ^ answer ].
	^ super openFileDialog: aFileDialog
]

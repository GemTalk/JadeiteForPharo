Class {
	#name : 'JadeiteFailedCompileMethodListBrowser',
	#superclass : 'JadeiteMethodListBrowser',
	#category : 'Jadeite-MethodBrowser',
	#package : 'Jadeite-MethodBrowser'
}

{ #category : 'accessing' }
JadeiteFailedCompileMethodListBrowser class >> presenterClass [

	^ #JadeiteFailedCompileMethodListPresenter
]

{ #category : 'as yet unclassified' }
JadeiteFailedCompileMethodListBrowser >> shellName [

	^'Jadeite Failed Compile Method List Browser'.
]

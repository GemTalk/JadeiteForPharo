Class {
	#name : 'JadeiteFetcher',
	#superclass : 'CoFetcher',
	#instVars : [
		'symbols'
	],
	#category : 'JadeiteToolsSupportClasses'
}

{ #category : 'enumerating' }
JadeiteFetcher >> entriesDo: aBlock [

	symbols do: [ :symbol | aBlock value: symbol ]
]

{ #category : 'accessing' }
JadeiteFetcher >> symbols [

	^ symbols
]

{ #category : 'accessing' }
JadeiteFetcher >> symbols: anObject [

	symbols := anObject
]

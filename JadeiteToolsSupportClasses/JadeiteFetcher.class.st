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

	symbols do:[:symbol | 
			| necEntry |
			necEntry := JadeiteNECEntry contents: symbol node: nil. 
			aBlock value: necEntry]
]

{ #category : 'accessing' }
JadeiteFetcher >> symbols [

	^ symbols
]

{ #category : 'accessing' }
JadeiteFetcher >> symbols: anObject [

	symbols := anObject
]

Class {
	#name : 'JadeiteFetcher',
	#superclass : 'CoFetcher',
	#instVars : [
		'symbols'
	],
	#category : 'Jadeite-SupportClasses',
	#package : 'Jadeite-SupportClasses'
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

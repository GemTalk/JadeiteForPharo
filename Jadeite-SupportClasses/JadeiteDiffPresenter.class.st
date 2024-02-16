Class {
	#name : 'JadeiteDiffPresenter',
	#superclass : 'SpDiffPresenter',
	#category : 'Jadeite-SupportClasses'
}

{ #category : 'specs' }
JadeiteDiffPresenter class >> adapterName [

	^ #JadeiteDiffAdapter
]

{ #category : 'actions' }
JadeiteDiffPresenter >> clear [

	leftText := String new. 
	rightText := String new
]

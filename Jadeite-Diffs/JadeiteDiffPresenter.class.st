Class {
	#name : 'JadeiteDiffPresenter',
	#superclass : 'SpDiffPresenter',
	#category : 'Jadeite-Diffs',
	#package : 'Jadeite-Diffs'
}

{ #category : 'specs' }
JadeiteDiffPresenter class >> adapterName [

	^ #JadeiteDiffAdapter
]

{ #category : 'accessing' }
JadeiteDiffPresenter >> addStyle: aString [
	
	super addStyle: aString. 
	adapter ifNotNil: [:a | a addStyle: aString].
]

{ #category : 'actions' }
JadeiteDiffPresenter >> clear [

	leftText := String new. 
	rightText := String new
]

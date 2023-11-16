Class {
	#name : 'JadeiteStatusBarPresenter',
	#superclass : 'SpStatusBarPresenter',
	#category : 'Jadeite-Inspector'
}

{ #category : 'accessing' }
JadeiteStatusBarPresenter >> value: aString [

	self message: aString
]

Class {
	#name : 'JadeiteStatusBarPresenter',
	#superclass : 'SpStatusBarPresenter',
	#category : 'JadeiteInspector'
}

{ #category : 'accessing' }
JadeiteStatusBarPresenter >> value: aString [

	self message: aString
]

Class {
	#name : 'JadeiteAutoRefreshPresenter',
	#superclass : 'JadeiteSessionPresenter',
	#traits : 'JadeiteToolbarTrait',
	#classTraits : 'JadeiteToolbarTrait classTrait',
	#instVars : [
		'autoRefreshPresenter',
		'autoRefreshProcess'
	],
	#category : 'Jadeite-MiscellaneousBrowsers',
	#package : 'Jadeite-MiscellaneousBrowsers'
}

{ #category : 'initialization' }
JadeiteAutoRefreshPresenter >> connectPresenters [

	super connectPresenters.
	autoRefreshPresenter whenChangedDo: [ :state |
		self toggleAutoRefreshProcess: state ]
]

{ #category : 'initialization' }
JadeiteAutoRefreshPresenter >> initializeWindow: aWindowPresenter [

	super initializeWindow: aWindowPresenter.
	aWindowPresenter whenClosedDo: [ self stopAutoRefresh ]
]

{ #category : 'actions' }
JadeiteAutoRefreshPresenter >> refresh [

	self subclassResponsibility
]

{ #category : 'actions' }
JadeiteAutoRefreshPresenter >> startAutoRefresh [
	"subclasses should name the auto refresh process appropriately"

	autoRefreshProcess := [
	                      [
	                      self refresh.
	                      (Delay forSeconds: 2) wait ] repeat ]
		                      newProcess.
	^ autoRefreshProcess resume
]

{ #category : 'actions' }
JadeiteAutoRefreshPresenter >> stopAutoRefresh [

	^ [ autoRefreshProcess ifNotNil: [ :proc | proc terminate ] ]
		  ensure: [ autoRefreshProcess := nil ]
]

{ #category : 'actions' }
JadeiteAutoRefreshPresenter >> toggleAutoRefreshProcess: state [

	^ state
		  ifTrue: [ self startAutoRefresh ]
		  ifFalse: [ self stopAutoRefresh ]
]

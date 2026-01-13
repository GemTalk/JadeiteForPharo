"
Only allow mouse clicks -  space bar or command return should not initiate a button 
"
Class {
	#name : 'JadeiteClickOnlyButtonPresenter',
	#superclass : 'SpButtonPresenter',
	#category : 'Jadeite-SupportClasses',
	#package : 'Jadeite-SupportClasses'
}

{ #category : 'specs' }
JadeiteClickOnlyButtonPresenter class >> adapterName [

	^ #JadeiteClickOnlyButtonAdapter
]

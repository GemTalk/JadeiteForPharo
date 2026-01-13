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

{ #category : 'accessing' }
JadeiteClickOnlyButtonPresenter >> performAction: event [

	event isKeyboard ifTrue: [ ^ self ].
	self action value.
	" Here I set a dummy value just to make the holder raise an event"
	actionPerformed := nil
]

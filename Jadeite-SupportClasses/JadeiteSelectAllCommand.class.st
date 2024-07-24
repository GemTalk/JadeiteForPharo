Class {
	#name : 'JadeiteSelectAllCommand',
	#superclass : 'JadeiteCommand',
	#category : 'Jadeite-SupportClasses',
	#package : 'Jadeite-SupportClasses'
}

{ #category : 'default' }
JadeiteSelectAllCommand class >> defaultName [
	^'Select All'
]

{ #category : 'execution' }
JadeiteSelectAllCommand >> execute [ 
	^context selectAll
]

{ #category : 'accessing' }
JadeiteSelectAllCommand >> shortcutKey [

	^ $a meta
]

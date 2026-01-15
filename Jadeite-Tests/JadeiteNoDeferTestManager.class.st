"
Don't defer blocks to the morphic threads. 
Use carefully, expected windows may not open in tests. 
"
Class {
	#name : 'JadeiteNoDeferTestManager',
	#superclass : 'JadeiteTestManager',
	#category : 'Jadeite-Tests',
	#package : 'Jadeite-Tests'
}

{ #category : 'ui process' }
JadeiteNoDeferTestManager >> defer: aBlock [
	"do not defer "

	aBlock value
]

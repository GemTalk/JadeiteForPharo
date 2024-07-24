Class {
	#name : 'JadeiteSTON',
	#superclass : 'STON',
	#category : 'Jadeite-RowanClientServicesClient',
	#package : 'Jadeite-RowanClientServicesClient'
}

{ #category : 'accessing' }
JadeiteSTON class >> reader [
	"Shortcut to create a new STONReader instance"

	^ JadeiteSTONReader new
]

{ #category : 'accessing' }
JadeiteSTON class >> writer [
	^JadeiteSTONWriter basicNew initialize
]

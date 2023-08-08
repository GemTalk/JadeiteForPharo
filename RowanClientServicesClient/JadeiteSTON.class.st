Class {
	#name : 'JadeiteSTON',
	#superclass : 'STON',
	#category : 'RowanClientServicesClient'
}

{ #category : 'accessing' }
JadeiteSTON class >> writer [
	^JadeiteSTONWriter basicNew initialize
]

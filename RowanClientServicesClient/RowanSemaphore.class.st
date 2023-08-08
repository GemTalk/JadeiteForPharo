Class {
	#name : 'RowanSemaphore',
	#superclass : 'Semaphore',
	#instVars : [
		'lockingProcess'
	],
	#category : 'RowanClientServicesClient'
}

{ #category : 'as yet unclassified' }
RowanSemaphore class >> guid: id [
]

{ #category : 'process synchronisation' }
RowanSemaphore >> critical: aBlock [
	lockingProcess := Processor activeProcess.
	[aBlock value] ensure: [lockingProcess := nil]
]

{ #category : 'accessing' }
RowanSemaphore >> lockingProcess [
	"Private - for testing"

	^lockingProcess
]

Class {
	#name : 'RowanSemaphore',
	#superclass : 'Semaphore',
	#instVars : [
		'lockingProcess'
	],
	#category : 'Jadeite-RowanClientServicesClient',
	#package : 'Jadeite-RowanClientServicesClient'
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

{ #category : 'accessing' }
RowanSemaphore >> lockingProcess: anObject [

	^ lockingProcess := anObject
]

{ #category : 'process synchronisation' }
RowanSemaphore >> wait [

	lockingProcess := Processor activeProcess.
	[ super wait ] ensure: [ lockingProcess := nil ]
]

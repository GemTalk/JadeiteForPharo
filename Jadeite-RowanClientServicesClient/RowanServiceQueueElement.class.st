Class {
	#name : 'RowanServiceQueueElement',
	#superclass : 'Model',
	#instVars : [
		'service',
		'priority',
		'completionBlock',
		'command',
		'commandArgs'
	],
	#category : 'Jadeite-RowanClientServicesClient'
}

{ #category : 'accessing' }
RowanServiceQueueElement >> command [

	^ command
]

{ #category : 'accessing' }
RowanServiceQueueElement >> command: anObject [

	command := anObject
]

{ #category : 'accessing' }
RowanServiceQueueElement >> commandArgs [

	^ commandArgs
]

{ #category : 'accessing' }
RowanServiceQueueElement >> commandArgs: anObject [

	commandArgs := anObject
]

{ #category : 'accessing' }
RowanServiceQueueElement >> completionBlock [

	^ completionBlock
]

{ #category : 'accessing' }
RowanServiceQueueElement >> completionBlock: anObject [

	completionBlock := anObject
]

{ #category : 'accessing' }
RowanServiceQueueElement >> priority [

	^ priority
]

{ #category : 'accessing' }
RowanServiceQueueElement >> priority: anObject [

	priority := anObject
]

{ #category : 'accessing' }
RowanServiceQueueElement >> service [

	^ service
]

{ #category : 'accessing' }
RowanServiceQueueElement >> service: anObject [

	service := anObject
]

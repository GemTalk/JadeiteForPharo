Class {
	#name : 'JadeiteAtomicSharedQueue',
	#superclass : 'AtomicSharedQueue',
	#category : 'Jadeite-SupportClasses'
}

{ #category : 'as yet unclassified' }
JadeiteAtomicSharedQueue >> nextPutFirst: value [
	" Add new item to queue in the first slot.
	AtomicSharedQueue does not seem to have a way to reorder the queue
	so just start a new queue with our guy on top "

	RowanServiceUpdater current newServiceQueueWithFirst: value
]

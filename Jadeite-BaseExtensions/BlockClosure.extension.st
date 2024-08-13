Extension { #name : 'BlockClosure' }

{ #category : '*Jadeite-BaseExtensions' }
BlockClosure >> jadeiteSchedule [
	"Jadeite extension - execute block in forked process using serviceQueue"
	
	RowanServiceUpdater current serviceQueuePut: self
]

{ #category : '*Jadeite-BaseExtensions' }
BlockClosure >> jadeiteScheduleFirst [
	RowanServiceUpdater current serviceQueuePutFirst: self
]

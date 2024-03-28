Extension { #name : 'BlockClosure' }

{ #category : '*Jadeite-BaseExtensions' }
BlockClosure >> schedule [
	"Jadeite extension - execute block in forked process using serviceQueue"
	
	RowanServiceUpdater current serviceQueuePut: self
]

{ #category : '*Jadeite-BaseExtensions' }
BlockClosure >> scheduleInUI [
	"Jadeite extension - execute block in UI process using serviceQueue"
	
	RowanServiceUpdater current serviceQueueUIPut: self
]

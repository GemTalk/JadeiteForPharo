Extension { #name : 'Process' }

{ #category : '*Jadeite-BaseExtensions' }
Process >> jadeiteLog: message [

	| stream |
	stream := WriteStream on: String new.
	self printOn: stream.
	stream
		tab;
		nextPutAll: message.
	RowanServiceUpdater current logComment: stream contents
]

{ #category : '*Jadeite-BaseExtensions' }
Process >> jadeiteTranscriptWrite: message [

	| stream |
	stream := WriteStream on: String new.
	self printOn: stream.
	stream
		tab;
		nextPutAll: message.
	Transcript
		cr;
		show: stream contents;
		flush.
	^ stream contents
]

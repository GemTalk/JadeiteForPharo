Extension { #name : 'Process' }

{ #category : '*Jadeite-BaseExtensions' }
Process >> jadeitePrintOn: aStream [

	self printOn: aStream.
	aStream
		space;
		nextPut: ${;
		nextPutAll: self identityHash printString;
		nextPut: $}
]

{ #category : '*Jadeite-BaseExtensions' }
Process >> jadeiteTranscriptWrite: message [

	| stream |
	stream := WriteStream on: String new.
	self jadeitePrintOn: stream.
	stream
		tab;
		nextPutAll: message.
	Transcript cr; show: stream contents; flush. 
	^ stream contents
]

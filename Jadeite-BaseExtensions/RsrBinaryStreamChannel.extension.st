Extension { #name : 'RsrBinaryStreamChannel' }

{ #category : '*Jadeite-BaseExtensions' }
RsrBinaryStreamChannel >> close [
	"Shutdown the Command sink and source."

	'Shutting down Channel' traceCr.
	[
	source stop.
	sink stop.
	outStream
		flush;
		close.
	inStream close.
	'Shutdown successfully' traceCr ] ifCurtailed: [
		RsrProcessModel currentStackDump traceCr.
		self halt ]
]

{ #category : '*Jadeite-BaseExtensions' }
RsrBinaryStreamChannel >> open [
	"Ensure the Command sink and source are running"
	
	'Starting channel' traceCr.
	source start.
	sink start.
	'Sink/source started' traceCr
]

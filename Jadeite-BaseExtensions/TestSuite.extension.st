Extension { #name : 'TestSuite' }

{ #category : '*Jadeite-BaseExtensions' }
TestSuite >> printOn: aStream [

	super printOn: aStream.
	aStream
		space;
		nextPut: $(;
		nextPutAll: name;
		nextPut: $)
]

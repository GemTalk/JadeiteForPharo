Extension { #name : 'RsrDecodingRaisedException' }

{ #category : '*Jadeite-BaseExtensions' }
RsrDecodingRaisedException >> description [

	| ws |
	ws := WriteStream on: String new.
	ws
		nextPut: $(;
		nextPutAll: super description;
		nextPut: $);
		space;
		nextPutAll: self exception messageText.
	^ ws contents
]

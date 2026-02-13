Extension { #name : 'RsrRemoteException' }

{ #category : '*Jadeite-BaseExtensions' }
RsrRemoteException >> description [

	| ws |
	ws := WriteStream on: String new.
	ws
		nextPut: $(;
		nextPutAll: super description;
		nextPut: $);
		space;
		nextPutAll: messageText.
	^ ws contents
]

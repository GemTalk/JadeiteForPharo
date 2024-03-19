Extension { #name : 'RsrConnectionClosedBeforeReceivingResponse' }

{ #category : '*Jadeite-BaseExtensions' }
RsrConnectionClosedBeforeReceivingResponse >> tag [
	"this object can be received in an RsrPromise catch: block
	which expects the `tag` variable to be there."
	^'rsrProcessTerminated'
]

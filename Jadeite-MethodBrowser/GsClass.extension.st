Extension { #name : 'GsClass' }

{ #category : '*Jadeite-MethodBrowser' }
GsClass >> sourceFor: anObject [

	^gciSession
		serverPerform: #'sourceFor:in:'
		with: anObject
		with: self.

]

{ #category : '*Jadeite-MethodBrowser' }
GsClass >> stepPointsFor: aGsMethod [

	^gciSession
		serverPerform: #'stepPointsFor:in:'
		with: aGsMethod
		with: self.

]
